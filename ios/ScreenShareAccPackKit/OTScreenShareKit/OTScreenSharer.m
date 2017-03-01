//
//  OTScreenSharer.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAcceleratorSession.h"
#import <OTKAnalytics/OTKLogger.h>
#import "OTScreenSharer.h"
#import "OTScreenCapture.h"

static NSString * const kLogComponentIdentifier = @"screenSharingAccPack";
static NSString * const KLogClientVersion = @"ios-vsol-2.0.0";
static NSString * const KLogActionInitialize = @"Init";
static NSString * const KLogActionStart = @"Start";
static NSString * const KLogActionEnd = @"End";
static NSString * const KLogActionEnableAudioScreensharing = @"EnableScreensharingAudio";
static NSString * const KLogActionDisableAudioScreensharing = @"DisableScreensharingAudio";
static NSString * const KLogVariationAttempt = @"Attempt";
static NSString * const KLogVariationSuccess = @"Success";
static NSString * const KLogVariationFailure = @"Failure";

@interface SSLoggingWrapper: NSObject
@property (nonatomic) OTKLogger *logger;
@end

@implementation SSLoggingWrapper

+ (instancetype)sharedInstance {
    
    static SSLoggingWrapper *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SSLoggingWrapper alloc] init];
        sharedInstance.logger = [[OTKLogger alloc] initWithClientVersion:KLogClientVersion
                                                                  source:[[NSBundle mainBundle] bundleIdentifier]
                                                             componentId:kLogComponentIdentifier
                                                                    guid:[[NSUUID UUID] UUIDString]];
    });
    return sharedInstance;
}

@end

@interface OTScreenSharer()<OTSessionDelegate, OTPublisherDelegate, OTSubscriberKitDelegate, OTVideoViewProtocol>

@property (nonatomic) BOOL isScreenSharing;

@property (nonatomic) CGSize subscriberVideoDimension;
@property (nonatomic) OTSubscriber *subscriber;
@property (nonatomic) OTAcceleratorSession *session;
@property (nonatomic) OTPublisher *publisher;

@property (nonatomic) UIView *publisherView;
@property (nonatomic) UIView *subscriberView;

@property (strong, nonatomic) OTScreenShareBlock handler;

@property (nonatomic) OTVideoView *publisherView;
@property (nonatomic) OTVideoView *subscriberView;

@property (strong, nonatomic) OTCommunicatorBlock handler;

@end

@implementation OTScreenSharer

- (void)setDataSource:(id<OTScreenShareDataSource>)dataSource {
    if (!dataSource) return;
    _dataSource = dataSource;
    _session = [_dataSource sessionOfOTScreenSharer:self];
}

- (instancetype)init {
    
    return [self initWithName:[NSString stringWithFormat:@"%@-%@", [UIDevice currentDevice].systemName, [UIDevice currentDevice].name]];
}

- (instancetype)initWithName:(NSString *)name {
    
    if (self = [super init]) {
        _name = name;
        [[SSLoggingWrapper sharedInstance].logger logEventAction:KLogActionInitialize variation:KLogVariationSuccess completion:nil];
    }
    return self;
}

- (NSError *)connectWithView:(UIView *)view {
    
    SSLoggingWrapper *loggingWrapper = [SSLoggingWrapper sharedInstance];
    if (view) {
        self.screenCapture = [[OTScreenCapture alloc] initWithView:view];
    }
    [loggingWrapper.logger logEventAction:KLogActionStart
                    variation:KLogVariationAttempt
                   completion:nil];
    NSError *registerError = [self.session registerWithAccePack:self];
    if(registerError){
        [loggingWrapper.logger logEventAction:KLogActionStart
                        variation:KLogVariationFailure
                       completion:nil];
    } else {
        [loggingWrapper.logger logEventAction:KLogActionStart
                        variation:KLogVariationSuccess
                       completion:nil];
    }
    
    return registerError;
}

- (void)connectWithView:(UIView *)view
                handler:(OTCommunicatorBlock)handler {
    
    if (!handler) return;
    
    self.handler = handler;
    NSError *error = [self connectWithView:view];
    if (error) {
        self.handler(OTCommunicationError, error);
    }
}

- (NSError *)disconnect {
    
    SSLoggingWrapper *loggingWrapper = [SSLoggingWrapper sharedInstance];
    [loggingWrapper.logger logEventAction:KLogActionEnd
                                variation:KLogVariationAttempt
                               completion:nil];
    if (self.publisher) {
        
        OTError *error = nil;
        [self.publisher.view removeFromSuperview];
        [self.session unpublish:self.publisher error:&error];
        if (error) {
            NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
        }
        self.publisher = nil;
        self.publisherView = nil;
    }

    if (self.subscriber) {

        OTError *error = nil;
        [self.subscriber.view removeFromSuperview];
        [self.session unsubscribe:self.subscriber error:&error];
        if (error) {
            NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
        }
        self.subscriber = nil;
        self.subscriberView = nil;
    }

    NSError *disconnectError = [self.session deregisterWithAccePack:self];
    if (!disconnectError) {
        [loggingWrapper.logger logEventAction:KLogActionEnd
                                    variation:KLogVariationSuccess
                                   completion:nil];
    }
    else {
        [loggingWrapper.logger logEventAction:KLogActionEnd
                                    variation:KLogVariationFailure
                                   completion:nil];
    }
    
    self.isScreenSharing = NO;
    return disconnectError;
}

- (void)updateView:(UIView *)view {
    if (self.isScreenSharing) {
        self.screenCapture.view = view;
    }
}

- (void)notifiyAllWithSignal:(OTCommunicationSignal)signal error:(NSError *)error {

    if (self.handler) {
        self.handler(signal, error);
    }
}

- (void) sessionDidConnect:(OTSession *)session {
    //Init otkanalytics. Internal use
    [[SSLoggingWrapper sharedInstance].logger setSessionId:session.sessionId connectionId:session.connection.connectionId partnerId:@([self.session.apiKey integerValue])];

    if (!self.publisher) {
        
        if (!self.publisherName) {
            self.publisherName = [NSString stringWithFormat:@"%@-%@", [UIDevice currentDevice].systemName, [UIDevice currentDevice].name];
        }
        self.publisher = [[OTPublisher alloc] initWithDelegate:self
                                                          name:self.publisherName
                                                    audioTrack:YES
                                                    videoTrack:YES];
        
        [self.publisher setVideoType:OTPublisherKitVideoTypeScreen];
        self.publisher.audioFallbackEnabled = NO;
        [self.publisher setVideoCapture:self.screenCapture];
    }

    OTError *error;
    [self.session publish:self.publisher error:&error];
    if (error) {
        [self notifiyAllWithSignal:OTCommunicationError
                             error:error];
    }
    else {
        self.isScreenSharing = YES;
        if (!self.publisherView) {
            self.publisherView = [[OTVideoView alloc] initWithPublisher:self.publisher];
            self.publisherView.delegate = self;
        }
        [self notifiyAllWithSignal:OTPublisherCreated
                             error:nil];
    }
}

- (void) sessionDidDisconnect:(OTSession *)session {
    [self notifiyAllWithSignal:OTScreenShareSignalSessionDidDisconnect
                         error:nil];
}

- (void)session:(OTSession *)session streamCreated:(OTStream *)stream {

    // we always subscribe one stream for this acc pack
    // please see - subscribeToStreamWithName: to switch subscription
    if (self.subscriber) {
        NSError *unsubscribeError;
        [self.session unsubscribe:self.subscriber error:&unsubscribeError];
        if (unsubscribeError) {
            NSLog(@"%@", unsubscribeError);
        }
    }
    
    OTError *subscrciberError;
    self.subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
    if (self.subscriberVideoContentMode == OTVideoViewFit) {
        self.subscriber.viewScaleBehavior = OTVideoViewScaleBehaviorFit;
    }
    else {
        self.subscriber.viewScaleBehavior = OTVideoViewScaleBehaviorFill;
    }
    [self.session subscribe:self.subscriber error:&subscrciberError];
    [self notifiyAllWithSignal:OTScreenShareSignalSessionStreamCreated
                         error:subscrciberError];
}

- (void) session:(OTSession *)session streamDestroyed:(OTStream *)stream {

    if (self.subscriber.stream && [self.subscriber.stream.streamId isEqualToString:stream.streamId]) {
        [self notifiyAllWithSignal:OTSubscriberDestroyed
                             error:nil];
        [self cleanupSubscriber];
    }
}

- (void)session:(OTSession *)session didFailWithError:(OTError *)error {
    [self notifiyAllWithSignal:OTCommunicationError
                         error:error];
}

- (void)sessionDidBeginReconnecting:(OTSession *)session {
    [self notifiyAllWithSignal:OTSessionDidBeginReconnecting
                         error:nil];
}

- (void)sessionDidReconnect:(OTSession *)session {
    [self notifiyAllWithSignal:OTSessionDidReconnect
                         error:nil];
}

#pragma mark - OTPublisherDelegate

- (void)publisher:(OTPublisherKit *)publisher didFailWithError:(OTError *)error {
    if (publisher == self.publisher) {
        [self notifiyAllWithSignal:OTCommunicationError
                             error:error];
    }
}

#pragma mark - OTSubscriberKitDelegate
-(void) subscriberDidConnectToStream:(OTSubscriberKit*)subscriber {
    if (subscriber == self.subscriber) {
        _subscriberView = [[OTVideoView alloc] initWithSubscriber:self.subscriber];
        _subscriberView.delegate = self;
        [self notifiyAllWithSignal:OTSubscriberReady
                             error:nil];
    }
}

-(void)subscriberVideoDisabled:(OTSubscriber *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    if (subscriber != self.subscriber) return;
    
    if (reason == OTSubscriberVideoEventPublisherPropertyChanged) {
        [self notifiyAllWithSignal:OTSubscriberVideoDisabledByPublisher
                             error:nil];
    }
    else if (reason == OTSubscriberVideoEventSubscriberPropertyChanged) {
        [self notifiyAllWithSignal:OTSubscriberVideoDisabledBySubscriber
                             error:nil];
    
    }
    else if (reason == OTSubscriberVideoEventQualityChanged) {
        [self notifiyAllWithSignal:OTSubscriberVideoDisabledByBadQuality
                             error:nil];
    }
}

- (void)subscriberVideoEnabled:(OTSubscriberKit *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    if (subscriber != self.subscriber) return;
    
    if (reason == OTSubscriberVideoEventPublisherPropertyChanged) {
        [self notifiyAllWithSignal:OTSubscriberVideoEnabledByPublisher
                             error:nil];
    }
    else if (reason == OTSubscriberVideoEventSubscriberPropertyChanged) {
        [self notifiyAllWithSignal:OTSubscriberVideoEnabledBySubscriber
                             error:nil];
    }
    else if (reason == OTSubscriberVideoEventQualityChanged) {
        [self notifiyAllWithSignal:OTSubscriberVideoEnabledByGoodQuality
                             error:nil];
    }
}

-(void) subscriberVideoDisableWarning:(OTSubscriber *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    if (subscriber == self.subscriber) {
        [self notifiyAllWithSignal:OTSubscriberVideoDisableWarning
                             error:nil];
    }
}

-(void) subscriberVideoDisableWarningLifted:(OTSubscriberKit *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    if (subscriber == self.subscriber) {
        [self notifiyAllWithSignal:OTSubscriberVideoDisableWarningLifted
                             error:nil];
    }
}

- (void)subscriber:(OTSubscriberKit *)subscriber didFailWithError:(OTError *)error {
    if (subscriber == self.subscriber) {
        [self notifiyAllWithSignal:OTCommunicationError
                             error:error];
    }
}

#pragma mark - Setters and Getters

- (BOOL)isRemoteAudioAvailable {
    if (!_subscriber) return NO;
    return _subscriber.stream.hasAudio;
}

- (BOOL)isRemoteVideoAvailable {
    if (!_subscriber) return NO;
    return _subscriber.stream.hasVideo;
}

- (BOOL)isRemoteAudioAvailable {
    if (!_subscriber) return NO;
    return _subscriber.stream.hasAudio;
}

- (BOOL)isRemoteVideoAvailable {
    if (!_subscriber) return NO;
    return _subscriber.stream.hasVideo;
}

- (void)setSubscribeToAudio:(BOOL)subscribeToAudio {
    if (!_subscriber) return;
    _subscriber.subscribeToAudio = subscribeToAudio;
}

- (BOOL)isSubscribeToAudio {
    if (!_subscriber) return NO;
    return _subscriber.subscribeToAudio;
}

- (void)setSubscribeToVideo:(BOOL)subscribeToVideo {
    if (!_subscriber) return;
    _subscriber.subscribeToVideo = subscribeToVideo;
}

- (BOOL)isSubscribeToVideo {
    if (!_subscriber) return NO;
    return _subscriber.subscribeToVideo;
}

- (void)setPublishAudio:(BOOL)publishAudio {
    if (!_publisher) return;
    _publisher.publishAudio = publishAudio;
}

- (BOOL)isPublishAudio {
    if (!_publisher) return NO;
    return _publisher.publishAudio;
}

- (void)setPublishVideo:(BOOL)publishVideo {
    if (!_publisher) return;
    _publisher.publishVideo = publishVideo;
}

- (BOOL)isPublishVideo {
    if (!_publisher) return NO;
    return _publisher.publishVideo;
}

- (CGSize)subscriberVideoDimension {
    if (!self.subscriber || !self.subscriberView) {
        return CGSizeZero;
    }
    return self.subscriber.stream.videoDimensions;
}

- (void)setSubscriberVideoContentMode:(OTVideoViewContentMode)subscriberVideoContentMode {
    
    _subscriberVideoContentMode = subscriberVideoContentMode;
    
    if (self.subscriber) {
        if (_subscriberVideoContentMode == OTVideoViewFit) {
            self.subscriber.viewScaleBehavior = OTVideoViewScaleBehaviorFit;
        }
        else {
            self.subscriber.viewScaleBehavior = OTVideoViewScaleBehaviorFill;
        }
    }
}

#pragma mark - advanced

- (NSError *)subscribeToStreamWithName:(NSString *)name {
    for (OTStream *stream in self.session.streams.allValues) {
        if ([stream.name isEqualToString:name]) {
            NSError *unsubscribeError;
            [self.session unsubscribe:self.subscriber error:&unsubscribeError];
            if (unsubscribeError) {
                NSLog(@"%@", unsubscribeError);
            }
            
            NSError *subscrciberError;
            self.subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
            [self.session subscribe:self.subscriber error:&subscrciberError];
            return subscrciberError;
        }
    }
    
    return [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"There is no such stream with name: %@", name]}];
}

- (NSError *)subscribeToStreamWithStreamId:(NSString *)streamId {
    for (OTStream *stream in self.session.streams.allValues) {
        if ([stream.streamId isEqualToString:streamId]) {
            NSError *unsubscribeError;
            [self.session unsubscribe:self.subscriber error:&unsubscribeError];
            if (unsubscribeError) {
                NSLog(@"%@", unsubscribeError);
            }
            
            NSError *subscrciberError;
            self.subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
            [self.session subscribe:self.subscriber error:&subscrciberError];
            return subscrciberError;
        }
    }
    
    return [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"There is no such stream with streamId: %@", streamId]}];
}

@end
