//
//  OTOneToOneCommunicator.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTOneToOneCommunicator.h"
#import "OTAcceleratorSession.h"

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
@property (nonatomic) OTSubscriber *subscriber;
@property (nonatomic) OTPublisher *publisher;
@property (nonatomic) OTAcceleratorSession *session;

@property (strong, nonatomic) OTOneToOneCommunicatorBlock handler;
@end

@implementation OTOneToOneCommunicator

+ (instancetype)sharedInstance {

    static OTOneToOneCommunicator *sharedInstance;
    static dispatch_once_t onceToken;
    
    if (!sharedInstance) {
        [[LoggingWrapper sharedInstance].logger logEventAction:KLogActionInitialize variation:KLogVariationAttempt completion:nil];
    }
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OTOneToOneCommunicator alloc] init];
        sharedInstance.session = [OTAcceleratorSession getAcceleratorPackSession];
        
        if (sharedInstance && sharedInstance.session) {
            [[LoggingWrapper sharedInstance].logger logEventAction:KLogActionInitialize variation:KLogVariationSuccess completion:nil];
        }
        else {
            [[LoggingWrapper sharedInstance].logger logEventAction:KLogActionInitialize variation:KLogVariationFailure completion:nil];
        }
    });
    return sharedInstance;
}

- (NSError *)connect {
    
    // refresh in case of credentials update
    self.session = [OTAcceleratorSession getAcceleratorPackSession];
    
    LoggingWrapper *loggingWrapper = [LoggingWrapper sharedInstance];
    [loggingWrapper.logger logEventAction:KLogActionStartCommunication
                                variation:KLogVariationAttempt
                               completion:nil];
    
    NSError *connectError = [OTAcceleratorSession registerWithAccePack:self];
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
        self.handler(OTSessionDidFail, error);
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
            self.publisher = nil;
            NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
        }
    }
    
    if (self.subscriber) {
        
        OTError *error = nil;
        [self.subscriber.view removeFromSuperview];
        [self.session unsubscribe:self.subscriber error:&error];
        if (error) {
            self.subscriber = nil;
            NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
        }
    }
    
    LoggingWrapper *loggingWrapper = [LoggingWrapper sharedInstance];
    NSError *disconnectError = [OTAcceleratorSession deregisterWithAccePack:self];
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
    
    if (self.delegate) {
        [self.delegate oneToOneCommunicationWithSignal:signal error:error];
    }
}

#pragma mark - OTSessionDelegate
-(void)sessionDidConnect:(OTSession*)session {
    
    [[LoggingWrapper sharedInstance].logger setSessionId:session.sessionId
                                            connectionId:session.connection.connectionId
                                               partnerId:@([self.session.apiKey integerValue])];
    
    if (!self.publisher) {
        
        if (self.publisherName) {
            self.publisher = [[OTPublisher alloc] initWithDelegate:self name:self.publisherName];
        }
        else {
            self.publisher = [[OTPublisher alloc] initWithDelegate:self name:[UIDevice currentDevice].name];
        }
    }
    
    OTError *error;
    [self.session publish:self.publisher error:&error];
    if (error) {
        [self notifiyAllWithSignal:OTSessionDidConnect
                             error:error];
    }
    else {
        self.isCallEnabled = YES;
        [self notifiyAllWithSignal:OTSessionDidConnect
                             error:nil];
    }
}

- (void)sessionDidDisconnect:(OTSession *)session {

    self.publisher = nil;
    self.subscriber = nil;
    
    [self notifiyAllWithSignal:OTSessionDidDisconnect
                         error:nil];
}

- (void)session:(OTSession *)session streamCreated:(OTStream *)stream {
    
    OTError *error;
    self.subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
    [self.session subscribe:self.subscriber error:&error];
    [self notifiyAllWithSignal:OTSessionStreamCreated
                         error:error];
}

- (void)session:(OTSession *)session streamDestroyed:(OTStream *)stream {

    if (self.subscriber.stream && [self.subscriber.stream.streamId isEqualToString:stream.streamId]) {
        [self.subscriber.view removeFromSuperview];
        self.subscriber = nil;
        [self notifiyAllWithSignal:OTSessionStreamDestroyed
                             error:nil];
    }
}

- (void)session:(OTSession *)session didFailWithError:(OTError *)error {
    [self notifiyAllWithSignal:OTSessionDidFail
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

- (void)sessionDidBeginReconnecting:(OTSession *)session {
    [self notifiyAllWithSignal:OTSessionConnectionDidBeginReconnecting
                         error:nil];
}

- (void)sessionDidReconnect:(OTSession *)session {
    [self notifiyAllWithSignal:OTSessionConnectionDidReconnect
                         error:nil];
}
#pragma mark - OTPublisherDelegate
- (void)publisher:(OTPublisherKit *)publisher didFailWithError:(OTError *)error {
    if (publisher == self.publisher) {
        [self notifiyAllWithSignal:OTPublisherDidFail
                             error:error];
    }
}

- (void)publisher:(OTPublisherKit*)publisher streamCreated:(OTStream*)stream {
    if (publisher == self.publisher) {
        [self notifiyAllWithSignal:OTPublisherStreamCreated
                             error:nil];
    }
}

- (void)publisher:(OTPublisherKit*)publisher streamDestroyed:(OTStream*)stream {
    if (publisher == self.publisher) {
        [self notifiyAllWithSignal:OTPublisherStreamDestroyed
                             error:nil];
    }
}

#pragma mark - OTSubscriberKitDelegate
-(void) subscriberDidConnectToStream:(OTSubscriberKit*)subscriber {
    
    if (subscriber == self.subscriber) {
        [self notifiyAllWithSignal:OTSubscriberDidConnect
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
        [self notifiyAllWithSignal:OTSubscriberVideoEnabledByGoodQuality
                             error:nil];
    }
    else if (reason == OTSubscriberVideoEventQualityChanged) {
        [self notifiyAllWithSignal:OTSubscriberVideoEnabledByGoodQuality
                             error:nil];
    }
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
        [self notifiyAllWithSignal:OTSubscriberDidFail
                             error:error];
    }
}

#pragma mark - Setters and Getters
- (UIView *)subscriberView {
    return _subscriber.view;
}

- (UIView *)publisherView {
    return _publisher.view;
}

- (void)setSubscribeToAudio:(BOOL)subscribeToAudio {
    _subscriber.subscribeToAudio = subscribeToAudio;
}

- (BOOL)isSubscribeToAudio {
    if (!_subscriber.stream.hasAudio) return NO;
    return _subscriber.subscribeToAudio;
}

- (void)setSubscribeToVideo:(BOOL)subscribeToVideo {
    _subscriber.subscribeToVideo = subscribeToVideo;
}

- (BOOL)isSubscribeToVideo {
    if (!_subscriber.stream.hasVideo) return NO;
    return _subscriber.subscribeToVideo;
}

- (void)setPublishAudio:(BOOL)publishAudio {
    _publisher.publishAudio = publishAudio;
}

- (BOOL)isPublishAudio {
    return _publisher.publishAudio;
}

- (void)setPublishVideo:(BOOL)publishVideo {
    _publisher.publishVideo = publishVideo;
}

- (BOOL)isPublishVideo {
    return _publisher.publishVideo;
}

- (AVCaptureDevicePosition)cameraPosition {
    return _publisher.cameraPosition;
}

- (void)setCameraPosition:(AVCaptureDevicePosition)cameraPosition {
    _publisher.cameraPosition = cameraPosition;
}

@end
