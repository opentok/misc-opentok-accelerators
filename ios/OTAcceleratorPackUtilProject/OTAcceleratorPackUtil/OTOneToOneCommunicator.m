//
//  TextChatComponentChatView.h
//  TextChatComponent
//
//  Created by Xi Huang on 2/23/16.
//  Copyright © 2016 Tokbox. All rights reserved.
//

#import "OTOneToOneCommunicator.h"
#import "OTAcceleratorSession.h"

#import <Opentok/OpenTok.h>
#import <OTKAnalytics/OTKLogger.h>

static NSString* const KLogClientVersion = @"ios-vsol-1.0.0";
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
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OTOneToOneCommunicator alloc] init];
        sharedInstance.session = [OTAcceleratorSession getAcceleratorPackSession];
    });
    return sharedInstance;
}

+ (void)setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token {

    [OTAcceleratorSession setOpenTokApiKey:apiKey sessionId:sessionId token:token];
    
    LoggingWrapper *loggingWrapper = [LoggingWrapper sharedInstance];
    [loggingWrapper.logger logEventAction:KLogActionInitialize variation:KLogVariationAttempt completion:nil];
    OTOneToOneCommunicator *sharedInstance = [OTOneToOneCommunicator sharedInstance];
    if (sharedInstance) {
        [loggingWrapper.logger logEventAction:KLogActionInitialize variation:KLogVariationSuccess completion:nil];
    }
    else {
        [loggingWrapper.logger logEventAction:KLogActionInitialize variation:KLogVariationFailure completion:nil];
    }
    
    // update session in case of changing credentials
    [OTOneToOneCommunicator sharedInstance].session = [OTAcceleratorSession getAcceleratorPackSession];
}

- (void)connect {
    
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
    
    // need to explcitly publish and subscribe if the communicator joins/rejoins a connected session
    if (self.session.sessionConnectionStatus == OTSessionConnectionStatusConnected &&
        self.session.streams[self.publisher.stream.streamId]) {
        
        OTError *error = nil;
        [self.session publish:self.publisher error:&error];
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
    }
    
    if (self.session.sessionConnectionStatus == OTSessionConnectionStatusConnected &&
        self.session.streams[self.subscriber.stream.streamId]) {
        
        OTError *error = nil;
        [self.session subscribe:self.subscriber error:&error];
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
    }
    
    self.isCallEnabled = YES;
}

- (void)connectWithHandler:(OTOneToOneCommunicatorBlock)handler {

    self.handler = handler;
    [self connect];
}

- (void)disconnect {
    
    // need to explicitly unpublish and unsubscriber if the communicator is the only part to dismiss from the accelerator session
    // when there are multiple accelerator packs, the accelerator session will not call the disconnect method until the last delegate object is removed
    if (self.publisher) {
        
        OTError *error = nil;
        [self.publisher.view removeFromSuperview];
        [self.session unpublish:self.publisher error:&error];
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
    }
    
    if (self.subscriber) {
        
        OTError *error = nil;
        [self.subscriber.view removeFromSuperview];
        [self.session unsubscribe:self.subscriber error:&error];
        if (error) {
            NSLog(@"%@", error.localizedDescription);
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
    
    NSLog(@"OneToOneCommunicator sessionDidConnect:");
    [[LoggingWrapper sharedInstance].logger setSessionId:session.sessionId
                                            connectionId:session.connection.connectionId
                                               partnerId:@([self.session.apiKey integerValue])];
    
    if (!self.publisher) {
        NSString *deviceName = [UIDevice currentDevice].name;
        self.publisher = [[OTPublisher alloc] initWithDelegate:self name:deviceName];
    }
    
    OTError *error;
    [self.session publish:self.publisher error:&error];
    if (error) {
        [self notifiyAllWithSignal:OTSessionDidConnect
                             error:error];
    }
    else {
        [self notifiyAllWithSignal:OTSessionDidConnect
                             error:nil];
    }
}

- (void)sessionDidDisconnect:(OTSession *)session {

    NSLog(@"OneToOneCommunicator sessionDidDisconnect:");

    self.publisher = nil;
    self.subscriber = nil;
    
    [self notifiyAllWithSignal:OTSessionDidDisconnect
                         error:nil];
}

- (void)session:(OTSession *)session streamCreated:(OTStream *)stream {

    NSLog(@"session streamCreated (%@)", stream.streamId);
    
    OTError *error;
    self.subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
    [self.session subscribe:self.subscriber error:&error];
    [self notifiyAllWithSignal:OTSessionStreamCreated
                         error:error];
}

- (void)session:(OTSession *)session streamDestroyed:(OTStream *)stream {
    NSLog(@"session streamDestroyed (%@)", stream.streamId);

    if (self.subscriber.stream && [self.subscriber.stream.streamId isEqualToString:stream.streamId]) {
        [self.subscriber.view removeFromSuperview];
        self.subscriber = nil;
        [self notifiyAllWithSignal:OTSessionStreamDestroyed
                             error:nil];
    }
}

- (void)session:(OTSession *)session didFailWithError:(OTError *)error {
    NSLog(@"session did failed with error: (%@)", error);
    [self notifiyAllWithSignal:OTSessionDidFail
                         error:error];
}

#pragma mark - OTPublisherDelegate
- (void)publisher:(OTPublisherKit *)publisher didFailWithError:(OTError *)error {
    NSLog(@"publisher did failed with error: (%@)", error);
    [self notifiyAllWithSignal:OTPublisherDidFail
                         error:error];
}

- (void)publisher:(OTPublisherKit*)publisher streamCreated:(OTStream*)stream {
    [self notifiyAllWithSignal:OTPublisherStreamCreated
                         error:nil];
}

- (void)publisher:(OTPublisherKit*)publisher streamDestroyed:(OTStream*)stream {
    [self notifiyAllWithSignal:OTPublisherStreamDestroyed
                         error:nil];
}

#pragma mark - OTSubscriberKitDelegate
-(void) subscriberDidConnectToStream:(OTSubscriberKit*)subscriber {
    [self notifiyAllWithSignal:OTSubscriberConnect
                         error:nil];
}

-(void)subscriberVideoDisabled:(OTSubscriber *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    [self notifiyAllWithSignal:OTSubscriberVideoDisabled
                         error:nil];
}

- (void)subscriberVideoEnabled:(OTSubscriberKit *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    [self notifiyAllWithSignal:OTSubscriberVideoEnabled
                         error:nil];
}

-(void) subscriberVideoDisableWarning:(OTSubscriber *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    [self notifiyAllWithSignal:OTSubscriberVideoDisableWarning
                         error:nil];
}

-(void) subscriberVideoDisableWarningLifted:(OTSubscriberKit *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    [self notifiyAllWithSignal:OTSubscriberVideoDisableWarningLifted
                         error:nil];
}

- (void)subscriber:(OTSubscriberKit *)subscriber didFailWithError:(OTError *)error {
    NSLog(@"subscriber did failed with error: (%@)", error);
    [self notifiyAllWithSignal:OTSubscriberDidFail
                         error:error];
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
    return _subscriber.subscribeToAudio;
}

- (void)setSubscribeToVideo:(BOOL)subscribeToVideo {
    _subscriber.subscribeToVideo = subscribeToVideo;
}

- (BOOL)isSubscribeToVideo {
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
