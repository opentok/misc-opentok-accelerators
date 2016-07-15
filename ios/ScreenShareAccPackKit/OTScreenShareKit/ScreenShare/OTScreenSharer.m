//
//  OTScreenSharer.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <OTAcceleratorPackUtil/OTAcceleratorPackUtil.h>
#import <OTKAnalytics/OTKLogger.h>
#import "OTScreenSharer.h"
#import "JSON.h"

#import "OTScreenSharer_Private.h"
#import "OTScreenSharer_OTRemoteControl.h"
#import "OTRemoteAnnotator_Private.h"

static NSString * const kLogComponentIdentifier = @"screensharingAccPack";
static NSString * const KLogClientVersion = @"ios-vsol-1.0.0";
static NSString * const KLogActionInitialize = @"Init";
static NSString * const KLogActionStart = @"Start";
static NSString * const KLogActionStop = @"Stop";
static NSString * const KLogActionEnableAudioScreensharing = @"EnableScreensharingAudio";
static NSString * const KLogActionDisableAudioScreensharing = @"DisableScreensharingAudio";

static NSString * const KLogVariationAttempt = @"Attempt";
static NSString * const KLogVariationSuccess = @"Success";
static NSString * const KLogVariationFailure = @"Failure";

@interface OTScreenSharer()<OTSessionDelegate, OTPublisherDelegate, OTSubscriberKitDelegate>

@property (nonatomic) BOOL isScreenSharing;

@property (nonatomic) OTSubscriber *subscriber;
@property (nonatomic) OTAcceleratorSession *session;
@property (nonatomic) OTPublisher *publisher;
@property (nonatomic) ScreenShareBlock handler;

@end

@implementation OTScreenSharer

+ (instancetype)screenSharer {
    return [OTScreenSharer sharedInstance];
}

+ (void)setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token; {
    
    [OTAcceleratorSession setOpenTokApiKey:apiKey sessionId:sessionId token:token];
    [OTScreenSharer sharedInstance];
}

+ (instancetype) sharedInstance {
    [OTKLogger analyticsWithClientVersion:KLogClientVersion
                                   source:[[NSBundle mainBundle] bundleIdentifier]
                              componentId:kLogComponentIdentifier
                                     guid:[[NSUUID UUID] UUIDString]];
    
    [OTKLogger logEventAction:KLogActionInitialize variation:KLogVariationAttempt completion:nil];
    
    static OTScreenSharer *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OTScreenSharer alloc] init];
        sharedInstance.session = [OTAcceleratorSession getAcceleratorPackSession];
        [OTKLogger logEventAction:KLogActionInitialize variation:KLogVariationSuccess completion:nil];
    });
    
    if (!sharedInstance) {
        [OTKLogger logEventAction:KLogActionInitialize variation:KLogVariationFailure completion:nil];
    }
    return sharedInstance;
}

- (void)connectWithView:(UIView *)view {
    self.screenCapture = [[OTScreenCapture alloc] initWithView:view];
    [OTKLogger logEventAction:KLogActionStart
                    variation:KLogVariationAttempt
                   completion:nil];
    NSError *registerError = [OTAcceleratorSession registerWithAccePack:self];
    if(registerError){
        [OTKLogger logEventAction:KLogActionStart
                        variation:KLogVariationFailure
                       completion:nil];
    } else {
        [OTKLogger logEventAction:KLogActionStart
                        variation:KLogVariationSuccess
                       completion:nil];
    }
}

- (void)connectWithView:(UIView *)view
                handler:(ScreenShareBlock)handler {
    
    self.handler = handler;
    [self connectWithView:view];
}

- (void)disconnect {
    [OTKLogger logEventAction:KLogActionStop
                    variation:KLogVariationAttempt
                   completion:nil];
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
    
    NSError *disconnectError = [OTAcceleratorSession deregisterWithAccePack:self];
    if (!disconnectError) {
        [OTKLogger logEventAction:KLogActionStop
                        variation:KLogVariationSuccess
                       completion:nil];
    }
    else {
        [OTKLogger logEventAction:KLogActionStop
                        variation:KLogVariationFailure
                       completion:nil];
    }
}

- (void)updateView:(UIView *)view {
    if (self.isScreenSharing) {
        self.screenCapture.view = view;
    }
}

- (void)notifiyAllWithSignal:(ScreenShareSignal)signal error:(NSError *)error {
    
    if (self.handler) {
        self.handler(signal, error);
    }
    
    if (self.delegate) {
        [self.delegate screenShareWithSignal:signal error:error];
    }
}

- (void) sessionDidConnect:(OTSession *)session {
    //Init otkanalytics. Internal use
    [OTKLogger setSessionId:session.sessionId connectionId:session.connection.connectionId partnerId:@([self.session.apiKey integerValue])];
    
    if (!self.publisher) {
        NSString *deviceName = [UIDevice currentDevice].name;
        self.publisher = [[OTPublisher alloc] initWithDelegate:self
                                                          name:deviceName
                                                    audioTrack:YES
                                                    videoTrack:YES];
        [self.publisher setVideoType:OTPublisherKitVideoTypeScreen];
        self.publisher.audioFallbackEnabled = NO;
        [self.publisher setVideoCapture:self.screenCapture];
    }
    
    OTError *error;
    [self.session publish:self.publisher error:&error];
    if (error) {
        [self notifiyAllWithSignal:ScreenShareSignalSessionDidConnect
                             error:error];
    }
    else {
        self.isScreenSharing = YES;
        [self notifiyAllWithSignal:ScreenShareSignalSessionDidConnect
                             error:nil];
    }
}

- (void) sessionDidDisconnect:(OTSession *)session {
    self.publisher = nil;
    self.subscriber = nil;
    
    self.isScreenSharing = NO;
    [self notifiyAllWithSignal:ScreenShareSignalSessionDidDisconnect
                         error:nil];
}

- (void)session:(OTSession *)session streamCreated:(OTStream *)stream {
    
    OTError *error;
    self.subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
    self.subscriber.viewScaleBehavior = OTVideoViewScaleBehaviorFit;
    [self.session subscribe:self.subscriber error:&error];
    [self notifiyAllWithSignal:ScreenShareSignalSessionStreamCreated
                         error:error];
}

- (void) session:(OTSession *)session streamDestroyed:(OTStream *)stream {
    
    if (self.subscriber.stream && [self.subscriber.stream.streamId isEqualToString:stream.streamId]) {
        [self.subscriber.view removeFromSuperview];
        self.subscriber = nil;
        
        [self notifiyAllWithSignal:ScreenShareSignalSessionStreamDestroyed
                             error:nil];
    }
}

- (void)session:(OTSession *)session didFailWithError:(OTError *)error {
    NSLog(@"session did failed with error: (%@)", error);
    [self notifiyAllWithSignal:ScreenShareSignalSessionDidFail
                         error:error];
}

#pragma mark - OTPublisherDelegate

- (void)publisher:(OTPublisherKit *)publisher didFailWithError:(OTError *)error {
    NSLog(@"publisher did failed with error: (%@)", error);
    [self notifiyAllWithSignal:ScreenShareSignalPublisherDidFail
                         error:error];
}

#pragma mark - OTSubscriberKitDelegate
-(void) subscriberDidConnectToStream:(OTSubscriberKit*)subscriber {
    [self notifiyAllWithSignal:ScreenShareSignalSubscriberConnect
                         error:nil];
}

-(void)subscriberVideoDisabled:(OTSubscriber *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    [self notifiyAllWithSignal:ScreenShareSignalSubscriberVideoDisabled
                         error:nil];
}

- (void)subscriberVideoEnabled:(OTSubscriberKit *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    [self notifiyAllWithSignal:ScreenShareSignalSubscriberVideoEnabled
                         error:nil];
}

-(void) subscriberVideoDisableWarning:(OTSubscriber *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    [self notifiyAllWithSignal:ScreenShareSignalSubscriberVideoDisableWarning
                         error:nil];
}

-(void) subscriberVideoDisableWarningLifted:(OTSubscriberKit *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    [self notifiyAllWithSignal:ScreenShareSignalSubscriberVideoDisableWarningLifted
                         error:nil];
}

- (void)subscriber:(OTSubscriberKit *)subscriber didFailWithError:(OTError *)error {
    NSLog(@"subscriber did failed with error: (%@)", error);
    [self notifiyAllWithSignal:ScreenShareSignalSubscriberDidFail
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

- (BOOL)subscribeToAudio {
    return _subscriber.subscribeToAudio;
}

- (void)setSubscribeToVideo:(BOOL)subscribeToVideo {
    _subscriber.subscribeToVideo = subscribeToVideo;
}

- (BOOL)subscribeToVideo {
    return _subscriber.subscribeToVideo;
}

- (void)setPublishAudio:(BOOL)publishAudio {
    _publisher.publishAudio = publishAudio;
    if (publishAudio){
        [OTKLogger logEventAction:KLogActionEnableAudioScreensharing variation:KLogVariationSuccess completion:nil];
    } else {
        [OTKLogger logEventAction:KLogActionDisableAudioScreensharing variation:KLogVariationSuccess completion:nil];
    }
}

- (BOOL)publishAudio {
    return _publisher.publishAudio;
}

- (void)setPublishVideo:(BOOL)publishVideo {
    _publisher.publishVideo = publishVideo;
}

- (BOOL)publishVideo {
    return _publisher.publishVideo;
}

#pragma mark - Remote control
- (void)initializeRemoteAnnotator {
    
    if (self.isScreenSharing) {
        self.remoteAnnotator = [[OTRemoteAnnotator alloc] init];
        self.remoteAnnotator.annotationView = [[OTAnnotationView alloc] initWithFrame:self.screenCapture.view.bounds];
        self.remoteAnnotator.screenSharer = self;
    }
}

// OPENTOK SIGNALING
- (void)session:(OTSession*)session
receivedSignalType:(NSString*)type
 fromConnection:(OTConnection*)connection
     withString:(NSString*)string {
    
//    if (self.remoteAnnotator.isRemoteAnnotationEnabled) {
//        id json = [JSON parseJSON:string];
//        NSLog(@"%@", json);
//    }
    
//    OTAnnotationPoint *p1 = [[OTAnnotationPoint alloc] initWithX:119 andY:16];
//    OTAnnotationPoint *p2 = [[OTAnnotationPoint alloc] initWithX:122 andY:16];
//    OTAnnotationPoint *p3 = [[OTAnnotationPoint alloc] initWithX:126 andY:18];
//    OTAnnotationPoint *p4 = [[OTAnnotationPoint alloc] initWithX:134 andY:21];
//    OTAnnotationPoint *p5 = [[OTAnnotationPoint alloc] initWithX:144 andY:28];
//    OTAnnotationPath *path = [OTAnnotationPath pathWithPoints:@[p1, p2, p3, p4, p5] strokeColor:nil];
//    [self.remoteAnnotator.annotationView addAnnotatable:path];
//    
//    
//    OTAnnotationPoint *p6 = [[OTAnnotationPoint alloc] initWithX:160 andY:16];
//    OTAnnotationPoint *p7 = [[OTAnnotationPoint alloc] initWithX:160 andY:20];
//    OTAnnotationPoint *p8 = [[OTAnnotationPoint alloc] initWithX:160 andY:24];
//    OTAnnotationPoint *p9 = [[OTAnnotationPoint alloc] initWithX:160 andY:26];
//    OTAnnotationPoint *p10 = [[OTAnnotationPoint alloc] initWithX:160 andY:30];
//    OTAnnotationPath *path1 = [OTAnnotationPath pathWithPoints:@[p6, p7, p8, p9, p10] strokeColor:[UIColor yellowColor]];
//    [self.remoteAnnotator.annotationView addAnnotatable:path1];
    
}

@end
