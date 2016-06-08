#import <OTAcceleratorPackUtil/OTAcceleratorPackUtil.h>
#import "ScreenCapture.h"
#import "ScreenSharer.h"

@interface ScreenSharer()<OTSessionDelegate, OTPublisherDelegate, OTSubscriberDelegate>

@property (nonatomic) BOOL isScreenSharing;

@property (nonatomic) OTSubscriber *subscriber;
@property (nonatomic) OTAcceleratorSession *session;
@property (nonatomic) OTPublisher *publisher;
@property (nonatomic) ScreenCapture *screenCapture;
//@property (nonatomic) UIView *topScreen;

@end

@implementation ScreenSharer

- (BOOL)isScreenSharing {
    return self.session.sessionConnectionStatus == OTSessionConnectionStatusConnected ? YES :  NO;
}

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
    self.screenCapture = [[ScreenCapture alloc] initWithView:view];
    [OTAcceleratorSession registerWithAccePack:self];
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

- (void) sessionDidConnect:(OTSession *)session {
    if (!self.publisher) {
        self.publisher = [[OTPublisher alloc] initWithDelegate:self name:@"screenshare" audioTrack:NO videoTrack:YES];
        [self.publisher setVideoType:OTPublisherKitVideoTypeScreen];
        self.publisher.audioFallbackEnabled = NO;
        [self.publisher setVideoCapture:self.screenCapture];
    }
    
    OTError *error;
    [self.session publish:self.publisher error:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
}

- (void) sessionDidDisconnect:(OTSession *)session {
    self.publisher = nil;
    self.subscriber = nil;
}

- (void)session:(OTSession *)session streamCreated:(OTStream *)stream {
    
    if (self.publisher.stream && [self.publisher.stream.streamId isEqualToString: stream.streamId]) {
        OTError *error;
        self.subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
        [self.session subscribe:self.subscriber error:&error];
        if (error) {
        
        }
    }
}

- (void) session:(OTSession *)session streamDestroyed:(OTStream *)stream {
    
    if (self.subscriber.stream && [self.subscriber.stream.streamId isEqualToString:stream.streamId]) {
        [self.session unsubscribe:self.subscriber error:nil];
        [self.subscriber.view removeFromSuperview];
        self.subscriber = nil;
    }
}

- (void) session:(OTSession *)session didFailWithError:(OTError *)error {
    NSLog(@"session did failed with error: (%@)", error);
}

- (void) publisher:(OTPublisherKit *)publisher didFailWithError:(OTError *)error {
    NSLog(@"publisher did failed with error: (%@)", error);
}

- (void) subscriber:(OTSubscriberKit *)subscriber didFailWithError:(OTError *)error {
   NSLog(@"subscriber did failed with error: (%@)", error);
}

- (void)subscriberVideoDataReceived:(OTSubscriber *)subscriber {
    
}

- (void)subscriberDidConnectToStream:(OTSubscriberKit *)subscriber {
    
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

@end