#import <OTAcceleratorPackUtil/OTAcceleratorPackUtil.h>
#import "TBScreenCapture.h"
#import "ScreenSharer.h"

@interface ScreenSharer()<OTSessionDelegate, OTPublisherDelegate, OTSubscriberKitDelegate>

@property (nonatomic) BOOL isScreenSharing;

@property (nonatomic) OTSubscriber *subscriber;
@property (nonatomic) OTAcceleratorSession *session;
@property (nonatomic) OTPublisher *publisher;
@property (nonatomic) TBScreenCapture *screenCapture;
//@property (nonatomic) UIView *topScreen;

@property (strong, nonatomic) ScreenShareBlock handler;

@end

@implementation ScreenSharer

+ (instancetype)screenSharer {
    return [ScreenSharer sharedInstance];
}

+ (void)setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token; {
    
    [OTAcceleratorSession setOpenTokApiKey:apiKey sessionId:sessionId token:token];
    [ScreenSharer sharedInstance];
}

+ (instancetype) sharedInstance {
    
    static ScreenSharer *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ScreenSharer alloc] init];
        sharedInstance.session = [OTAcceleratorSession getAcceleratorPackSession];
    });
    return sharedInstance;
}

- (void)connectWithView:(UIView *)view {
    self.screenCapture = [[TBScreenCapture alloc] initWithView:view];
    [OTAcceleratorSession registerWithAccePack:self];
    
    // perhaps we need to work on something here
}

- (void)connectWithView:(UIView *)view
                handler:(ScreenShareBlock)handler {
    
    self.handler = handler;
    [self connectWithView:view];
}

- (void)disconnect {
    //    [self justFrame:NO andWhere:self.screenCapture.view];
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
    
    [OTAcceleratorSession deregisterWithAccePack:self];
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
    [self.session subscribe:self.subscriber error:&error];
    [self notifiyAllWithSignal:ScreenShareSignalSessionStreamCreated
                         error:error];
}

- (void) session:(OTSession *)session streamDestroyed:(OTStream *)stream {
    
    if (self.subscriber.stream && [self.subscriber.stream.streamId isEqualToString:stream.streamId]) {
        NSError *error = nil;
        [self.session unsubscribe:self.subscriber error:&error];
        [self.subscriber.view removeFromSuperview];
        self.subscriber = nil;
        
        [self notifiyAllWithSignal:ScreenShareSignalSessionStreamDestroyed
                             error:error];
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

#pragma mark - other components

//- (void) bringToFrontView: (NSArray *)views withSuperView: (UIView *)superView {
//    for (UIView *current in views) {
//        [superView bringSubviewToFront:current];
//    }
//}

//- (void)justFrame:(BOOL)shoudlAdd andWhere:(UIView *)viewToAdd; {
//    CGRect viewSize = CGRectMake(0, 0, viewToAdd.frame.size.width, 40);
//    [viewToAdd setFrame:CGRectMake(0, 0, viewToAdd.frame.size.width, viewToAdd.frame.size.height)];
//    UIColor *backgroundShare = [UIColor colorWithRed:102/255.0 green:173/255.0 blue:191/255.0 alpha:1];
//    
//    if (shoudlAdd){
//        self.topScreen = [[UIView alloc] initWithFrame: viewSize];
//        self.topScreen.backgroundColor = backgroundShare;
//        
//        UILabel *sharingScreenLabel = [[UILabel alloc] init];
//        sharingScreenLabel.text = @"You are sharing your screen";
//        sharingScreenLabel.font = [UIFont fontWithName:@"AvantGarde-Book" size:12.0];
//        sharingScreenLabel.frame = viewSize;
//        sharingScreenLabel.textAlignment = NSTextAlignmentCenter;
//        sharingScreenLabel.textColor = [UIColor whiteColor];
//        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 8, 20, 18)];
//        icon.image = [UIImage imageNamed:@"screenshare"];
//        
//        UIImageView *close = [[UIImageView alloc] initWithFrame:CGRectMake((viewToAdd.frame.size.width - 30), 14, 13, 13)];
//        close.image = [UIImage imageNamed:@"smallClose"];
//        [self.topScreen addSubview:icon];
//        
//        [self.topScreen addSubview:close];
//        [self.topScreen addSubview:sharingScreenLabel];
//        self.topScreen.translatesAutoresizingMaskIntoConstraints = NO;
//        [viewToAdd addSubview:self.topScreen];
//        
//        viewToAdd.layer.borderWidth = 5;
//        viewToAdd.layer.borderColor = backgroundShare.CGColor;
//        
//        viewToAdd.translatesAutoresizingMaskIntoConstraints = NO;
//        [self addAttachedLayoutConstantsToSuperview: viewToAdd];
//    } else {
//        viewToAdd.layer.borderWidth = 0;
//        [self.topScreen removeFromSuperview];
//        
//    }
//}


//- (void)superPositionElements: (UIView *)superViewScreenShare andElementsSendToFromt: (NSArray *)elements; {
//    [self bringToFrontView:elements withSuperView:superViewScreenShare];
//}
//
//#pragma mark - private method
//-(void)addAttachedLayoutConstantsToSuperview:(UIView *)view {
//    
//    if (!view.superview) {
//        return;
//    }
//    
//    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:view
//                                                           attribute:NSLayoutAttributeTop
//                                                           relatedBy:NSLayoutRelationEqual
//                                                              toItem:view.superview
//                                                           attribute:NSLayoutAttributeTop
//                                                          multiplier:1.0
//                                                            constant:0.0];
//    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:view
//                                                               attribute:NSLayoutAttributeLeading
//                                                               relatedBy:NSLayoutRelationEqual
//                                                                  toItem:view.superview
//                                                               attribute:NSLayoutAttributeLeading
//                                                              multiplier:1.0
//                                                                constant:0.0];
//    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:view
//                                                                attribute:NSLayoutAttributeTrailing
//                                                                relatedBy:NSLayoutRelationEqual
//                                                                   toItem:view.superview
//                                                                attribute:NSLayoutAttributeTrailing
//                                                               multiplier:1.0
//                                                                 constant:0.0];
//    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:view
//                                                              attribute:NSLayoutAttributeBottom
//                                                              relatedBy:NSLayoutRelationEqual
//                                                                 toItem:view.superview
//                                                              attribute:NSLayoutAttributeBottom
//                                                             multiplier:1.0
//                                                               constant:0.0];
//    [NSLayoutConstraint activateConstraints:@[top, leading, trailing, bottom]];
//}
//
//- (id) getSessionStreams; {
//    return self.session.streams;
//}

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

@end