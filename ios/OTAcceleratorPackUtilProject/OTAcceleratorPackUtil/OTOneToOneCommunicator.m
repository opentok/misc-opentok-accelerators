//
//  OTOneToOneCommunicator.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTOneToOneCommunicator.h"
#import "OTAcceleratorSession.h"
#import "OTAcceleratorPackUtilBundle.h"

#import <Opentok/OpenTok.h>
#import <OTKAnalytics/OTKLogger.h>

static NSString* const KLogClientVersion = @"ios-vsol-1.1.0";
static NSString* const kLogComponentIdentifier = @"oneToOneCommunication";
static NSString* const KLogActionInitialize = @"Init";
static NSString* const KLogActionStartCommunication = @"StartComm";
static NSString* const KLogActionEndCommunication = @"EndComm";
static NSString* const KLogVariationAttempt = @"Attempt";
static NSString* const KLogVariationSuccess = @"Success";
static NSString* const KLogVariationFailure = @"Failure";

@interface UIView (Helper)

- (void)addAttachedLayoutConstantsToSuperview;

@end

@implementation UIView (Helper)

- (void)addAttachedLayoutConstantsToSuperview {
    
    if (!self.superview) {
        return;
    }
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.superview
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:0.0];
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:self
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.superview
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1.0
                                                                constant:0.0];
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:self
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.superview
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1.0
                                                                 constant:0.0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.superview
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0.0];
    [NSLayoutConstraint activateConstraints:@[top, leading, trailing, bottom]];
}

@end

@interface LoggingWrapper: NSObject
@property (nonatomic) OTKLogger *logger;
@end

@implementation LoggingWrapper

+ (instancetype)sharedInstance {
    
    static LoggingWrapper *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LoggingWrapper alloc] init];
        sharedInstance.logger = [[OTKLogger alloc] initWithClientVersion:KLogClientVersion
                                                                  source:[[NSBundle mainBundle] bundleIdentifier]
                                                             componentId:kLogComponentIdentifier
                                                                    guid:[[NSUUID UUID] UUIDString]];
    });
    return sharedInstance;
}

@end

@interface OTOneToOneCommunicator() <OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate>
@property (nonatomic) BOOL isCallEnabled;
@property (nonatomic) NSString *name;
@property (nonatomic) OTSubscriber *subscriber;
@property (nonatomic) OTPublisher *publisher;
@property (weak, nonatomic) OTAcceleratorSession *session;

@property (nonatomic) UIView *subscriberView;
@property (nonatomic) UIView *publisherView;

@property (strong, nonatomic) OTOneToOneCommunicatorBlock handler;
@property (nonatomic) UIImageView *publisherPlaceHolderImageView;
@property (nonatomic) UIImageView *subscriberPlaceHolderImageView;
@end

@implementation OTOneToOneCommunicator

- (UIImageView *)publisherPlaceHolderImageView {
    if (!_publisherPlaceHolderImageView) {
        
        _publisherPlaceHolderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar" inBundle:[OTAcceleratorPackUtilBundle acceleratorPackUtilBundle] compatibleWithTraitCollection:nil]];
        _publisherPlaceHolderImageView.backgroundColor = [UIColor grayColor];
        _publisherPlaceHolderImageView.contentMode = UIViewContentModeScaleAspectFit;
        _publisherPlaceHolderImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _publisherPlaceHolderImageView;
}

- (UIImageView *)subscriberPlaceHolderImageView {
    if (!_subscriberPlaceHolderImageView) {
        
        _subscriberPlaceHolderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar" inBundle:[OTAcceleratorPackUtilBundle acceleratorPackUtilBundle] compatibleWithTraitCollection:nil]];
        _subscriberPlaceHolderImageView.backgroundColor = [UIColor grayColor];
        _subscriberPlaceHolderImageView.contentMode = UIViewContentModeScaleAspectFit;
        _subscriberPlaceHolderImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _subscriberPlaceHolderImageView;
}

- (void)setDataSource:(id<OTOneToOneCommunicatorDataSource>)dataSource {
    _dataSource = dataSource;
    _session = [_dataSource sessionOfOTOneToOneCommunicator:self];
}

- (instancetype)init {
    
    return [self initWithName:[NSString stringWithFormat:@"%@-%@", [UIDevice currentDevice].systemName, [UIDevice currentDevice].name]];
}

- (instancetype)initWithName:(NSString *)name {
    
    [[LoggingWrapper sharedInstance].logger logEventAction:KLogActionInitialize variation:KLogVariationAttempt completion:nil];
    
    if (self = [super init]) {
        _name = name;
        _handlePublisherViewAudioVideoOnOff = YES;
        _handleSubscriberViewAudioVideoOnOff = YES;
        [[LoggingWrapper sharedInstance].logger logEventAction:KLogActionInitialize variation:KLogVariationSuccess completion:nil];
    }
    else {
        [[LoggingWrapper sharedInstance].logger logEventAction:KLogActionInitialize variation:KLogVariationFailure completion:nil];
    }
    return self;
}

- (NSError *)connect {
    
    LoggingWrapper *loggingWrapper = [LoggingWrapper sharedInstance];
    [loggingWrapper.logger logEventAction:KLogActionStartCommunication
                                variation:KLogVariationAttempt
                               completion:nil];
    
    NSError *connectError = [self.session registerWithAccePack:self];
    if (!connectError) {
        [loggingWrapper.logger logEventAction:KLogActionStartCommunication
                                    variation:KLogVariationSuccess
                                   completion:nil];
    }
    else {
        [loggingWrapper.logger logEventAction:KLogActionStartCommunication
                                    variation:KLogVariationFailure
                                   completion:nil];
    }
    
    return connectError;
}

- (void)connectWithHandler:(OTOneToOneCommunicatorBlock)handler {

    if (!handler) return;
    
    self.handler = handler;
    NSError *error = [self connect];
    if (error) {
        self.handler(OTOneToOneCommunicationError, error);
    }
}

- (NSError *)disconnect {
    
    // need to explicitly unpublish and unsubscriber if the communicator is the only accelerator to dismiss from the common session
    // when there are multiple accelerator packs, the common session will not call the disconnect method until the last delegate object is removed
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
    
    LoggingWrapper *loggingWrapper = [LoggingWrapper sharedInstance];
    NSError *disconnectError = [self.session deregisterWithAccePack:self];
    if (!disconnectError) {
        [loggingWrapper.logger logEventAction:KLogActionEndCommunication
                                    variation:KLogVariationSuccess
                                   completion:nil];
    }
    else {
        [loggingWrapper.logger logEventAction:KLogActionEndCommunication
                                    variation:KLogVariationFailure
                                   completion:nil];
    }
    
    self.isCallEnabled = NO;
    return disconnectError;
}

- (void)notifiyAllWithSignal:(OTOneToOneCommunicationSignal)signal error:(NSError *)error {
    
    if (self.handler) {
        self.handler(signal, error);
    }
}

#pragma mark - OTSessionDelegate
-(void)sessionDidConnect:(OTSession*)session {
    
    [[LoggingWrapper sharedInstance].logger setSessionId:session.sessionId
                                            connectionId:session.connection.connectionId
                                               partnerId:@([self.session.apiKey integerValue])];
    
    if (!self.publisher) {
        self.publisher = [[OTPublisher alloc] initWithDelegate:self
                                                          name:self.name];
    }
    
    OTError *error;
    [self.session publish:self.publisher error:&error];
    if (error) {
        [self notifiyAllWithSignal:OTOneToOneCommunicationError
                             error:error];
    }
    else {
        self.isCallEnabled = YES;
        [self notifiyAllWithSignal:OTPublisherCreated
                             error:nil];
    }
}

- (void)sessionDidDisconnect:(OTSession *)session {
    [self notifiyAllWithSignal:OTPublisherDestroyed
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
    [self.session subscribe:self.subscriber error:&subscrciberError];
}

- (void)session:(OTSession *)session streamDestroyed:(OTStream *)stream {

    if (self.subscriber.stream && [self.subscriber.stream.streamId isEqualToString:stream.streamId]) {
        [self.subscriber.view removeFromSuperview];
        self.subscriber = nil;
    }
}

- (void)session:(OTSession *)session didFailWithError:(OTError *)error {
    [self notifiyAllWithSignal:OTOneToOneCommunicationError
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
        [self notifiyAllWithSignal:OTOneToOneCommunicationError
                             error:error];
    }
}

- (void)publisher:(OTPublisherKit *)publisher streamCreated:(OTStream *)stream {
    [self handlePublisherViewAudioVideoOnOff];
}

#pragma mark - OTSubscriberKitDelegate
- (void)subscriberDidConnectToStream:(OTSubscriberKit*)subscriber {

    if (subscriber == self.subscriber) {
        [self notifiyAllWithSignal:OTSubscriberDidConnect
                             error:nil];
    }
}

- (void)subscriberDidDisconnectFromStream:(OTSubscriberKit *)subscriber {
    if (subscriber == self.subscriber) {
        [self notifiyAllWithSignal:OTSubscriberDidDidconnect
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
    [self handleAdditionalUserInterfaceOnSubscriber];
}

- (void)subscriberVideoEnabled:(OTSubscriberKit *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    
    if (subscriber != self.subscriber) return;
    
    if (reason == OTSubscriberVideoEventPublisherPropertyChanged) {
        [self notifiyAllWithSignal:OTSubscriberVideoEnabledByPublisher
                             error:nil];
    }
    else if (reason == OTSubscriberVideoEventSubscriberPropertyChanged) {
        [self notifiyAllWithSignal:OTSubscriberVideoEnabledByGoodQuality
                             error:nil];
    }
    else if (reason == OTSubscriberVideoEventQualityChanged) {
        [self notifiyAllWithSignal:OTSubscriberVideoEnabledByGoodQuality
                             error:nil];
    }
    [self handleAdditionalUserInterfaceOnSubscriber];
}

-(void)subscriberVideoDisableWarning:(OTSubscriber *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    if (subscriber == self.subscriber) {
        [self notifiyAllWithSignal:OTSubscriberVideoDisableWarning
                             error:nil];
    }
}

-(void)subscriberVideoDisableWarningLifted:(OTSubscriberKit *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    if (subscriber == self.subscriber) {
        [self notifiyAllWithSignal:OTSubscriberVideoDisableWarningLifted
                             error:nil];
    }
}

- (void)subscriber:(OTSubscriberKit *)subscriber didFailWithError:(OTError *)error {
    if (subscriber == self.subscriber) {
        [self notifiyAllWithSignal:OTOneToOneCommunicationError
                             error:error];
    }
}

- (void)handleAdditionalUserInterfaceOnPublisher {
    
    if (!self.isCallEnabled || !self.publisher || !self.publisherView) return;
    
    if (self.handlePublisherViewAudioVideoOnOff) {
        if (self.publishVideo) {
            [self.publisherPlaceHolderImageView removeFromSuperview];
        }
        else {
            [self.publisherView addSubview:self.publisherPlaceHolderImageView];
            [self.publisherPlaceHolderImageView addAttachedLayoutConstantsToSuperview];
        }
    }
}

- (void)handleAdditionalUserInterfaceOnSubscriber {
    
    if (!self.isCallEnabled || !self.subscriber || !self.subscriberView) return;
    
    if (self.handleSubscriberViewAudioVideoOnOff) {
        if (self.subscribeToVideo && self.isRemoteVideoAvailable) {
            [self.subscriberPlaceHolderImageView removeFromSuperview];
        }
        else {
            [self.subscriberView addSubview:self.subscriberPlaceHolderImageView];
            [self.subscriberPlaceHolderImageView addAttachedLayoutConstantsToSuperview];
        }
    }
}

#pragma mark - advanced
- (NSError *)subscribeToStreamWithName:(NSString *)name {
    for (OTStream *stream in self.session.streams.allValues) {
        if ([stream.name isEqualToString:name]) {
            [self.subscriberView removeFromSuperview];
            self.subscriberView = nil;
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

#pragma mark - Setters and Getters
- (UIView *)subscriberView {
    return _subscriber.view;
}

- (UIView *)publisherView {
    return _publisher.view;
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
    [self handleAdditionalUserInterfaceOnSubscriber];
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
    [self handleAdditionalUserInterfaceOnPublisher];
}

- (BOOL)isPublishVideo {
    if (!_publisher) return NO;
    return _publisher.publishVideo;
}

- (AVCaptureDevicePosition)cameraPosition {
    return _publisher.cameraPosition;
}

- (void)setCameraPosition:(AVCaptureDevicePosition)cameraPosition {
    _publisher.cameraPosition = cameraPosition;
}

@end
