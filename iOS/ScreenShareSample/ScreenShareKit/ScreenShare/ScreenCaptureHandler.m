#import <OTAcceleratorPackUtil/OTAcceleratorPackUtil.h>
#import "ScreenCaptureHandler.h"

@interface ScreenCaptureHandler()<OTSessionDelegate, OTPublisherDelegate, OTSubscriberDelegate>
@property (nonatomic) OTSubscriber *subscriber;
@property (nonatomic) OTAcceleratorSession *session;
@property (nonatomic) OTPublisher *publisher;

@property (strong, nonatomic) ScreenCapture *screenCapture;

@property (strong, nonatomic) UIView *topScreen;

@end

@implementation ScreenCaptureHandler


+ (instancetype) screenCaptureHandler {
    return [ScreenCaptureHandler sharedInstance];
}

+ (void) setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token; {
    
    [OTAcceleratorSession setOpenTokApiKey:apiKey sessionId:sessionId token:token];
    [ScreenCaptureHandler sharedInstance];
}

+ (instancetype) sharedInstance {
    
    static ScreenCaptureHandler *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ScreenCaptureHandler alloc] init];
        sharedInstance.isScreenSharing = NO;
        sharedInstance.session = [OTAcceleratorSession getAcceleratorPackSession];
    });
    return sharedInstance;
}

- (void) setScreenCaptureSource:(ScreenCapture *)screenCapture {
    [OTAcceleratorSession registerWithAccePack:self];
    self.screenCapture = screenCapture;
    [self justFrame:YES andWhere:self.screenCapture.view];
}

- (void) setVideoSourceToScreenShare; {
    OTError *error;
    if (!self.publisher) {
        self.publisher = [[OTPublisher alloc] initWithDelegate:self name:@"screenshare" audioTrack:NO videoTrack:YES];
    }
    // Additionally, the publisher video type can be updated to signal to
    // receivers that the video is from a screencast. This value also disables
    // some downsample scaling that is used to adapt to changing network
    // conditions. We will send at a lower framerate to compensate for this.
    [self.publisher setVideoType:OTPublisherKitVideoTypeScreen];
    
    // This disables the audio fallback feature when using routed sessions.
    self.publisher.audioFallbackEnabled = NO;
    
    // Finally, wire up the video source.
    [self.publisher setVideoCapture: (id)self.screenCapture];
    [self.session publish:self.publisher error:&error];
    if (error) NSLog(@"ERROR adding the videoCapture Source %@", error);
    self.isScreenSharing = YES;
}

- (void) removeVideoSourceScreenShare; {
    [self justFrame:NO andWhere:self.screenCapture.view];
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
    
    self.isScreenSharing = NO;
    [OTAcceleratorSession deregisterWithAccePack:self];
    self.publisher = nil;
}

- (void) sessionDidConnect:(OTSession *)session {
    [self setVideoSourceToScreenShare];
    NSLog(@" %@ ,  %@", [self class], NSStringFromSelector(_cmd));
}

- (void) sessionDidDisconnect:(OTSession *)session {
    [self removeVideoSourceScreenShare];
    NSLog(@" %@ ,  %@", [self class], NSStringFromSelector(_cmd));
}

- (void) session:(OTSession *)session streamCreated:(OTStream *)stream {
    NSLog(@"(%@) session streamCreated (%@)", [self class], stream.streamId);
    if (self.publisher.stream.streamId && ![self.publisher.stream.streamId isEqualToString: stream.streamId]) {
        OTError *error;
        self.subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
        [self.session subscribe:self.subscriber error:&error];
        if (error) NSLog(@"ERROR adding screenshare subscriber %@", error);
    }
}

- (void) session:(OTSession *)session streamDestroyed:(OTStream *)stream {
    NSLog(@"screenshare session streamDestroyed (%@)", stream.streamId);
    
    if ([self.subscriber.stream.streamId isEqualToString:stream.streamId]) {
        [self.session unsubscribe:self.subscriber error:nil];
        [self.subscriber.view removeFromSuperview];
        self.subscriber = nil;
    }
}

- (void) session:(OTSession *)session didFailWithError:(OTError *)error { NSLog(@" screenshare DidfailWithError (%@)", error); }
- (void) publisher:(OTPublisherKit *)publisher didFailWithError:(OTError *)error { NSLog(@" screenshare publisher fail (%@)", error);}
- (void) subscriber:(OTSubscriberKit *)subscriber didFailWithError:(OTError *)error { NSLog(@" screenshare subscriber fail (%@)", error); }

- (void) subscriberDidConnectToStream:(OTSubscriberKit *)subscriber { NSLog(@" Screenshare subscriber connected to stream"); }
- (void) subscriberVideoDataReceived:(OTSubscriber *)subscriber { NSLog(@" Subscriber is receiving data");}

#pragma mark - other components

- (void) bringToFrontView: (NSArray *)views withSuperView: (UIView *)superView {
    for (UIView *current in views) {
        [superView bringSubviewToFront:current];
    }
}

- (void)justFrame:(BOOL)shoudlAdd andWhere:(UIView *)viewToAdd; {
    CGRect viewSize = CGRectMake(0, 0, viewToAdd.frame.size.width, 40);
    [viewToAdd setFrame:CGRectMake(0, 0, viewToAdd.frame.size.width, viewToAdd.frame.size.height)];
    UIColor *backgroundShare = [UIColor colorWithRed:102/255.0 green:173/255.0 blue:191/255.0 alpha:1];
    
    if (shoudlAdd){
        self.topScreen = [[UIView alloc] initWithFrame: viewSize];
        self.topScreen.backgroundColor = backgroundShare;
        
        UILabel *sharingScreenLabel = [[UILabel alloc] init];
        sharingScreenLabel.text = @"You are sharing your screen";
        sharingScreenLabel.font = [UIFont fontWithName:@"AvantGarde-Book" size:12.0];
        sharingScreenLabel.frame = viewSize;
        sharingScreenLabel.textAlignment = NSTextAlignmentCenter;
        sharingScreenLabel.textColor = [UIColor whiteColor];
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 8, 20, 18)];
        icon.image = [UIImage imageNamed:@"screenshare"];
        
        UIImageView *close = [[UIImageView alloc] initWithFrame:CGRectMake((viewToAdd.frame.size.width - 30), 14, 13, 13)];
        close.image = [UIImage imageNamed:@"smallClose"];
        [self.topScreen addSubview:icon];
        
        [self.topScreen addSubview:close];
        [self.topScreen addSubview:sharingScreenLabel];
        self.topScreen.translatesAutoresizingMaskIntoConstraints = NO;
        [viewToAdd addSubview:self.topScreen];
        
        viewToAdd.layer.borderWidth = 5;
        viewToAdd.layer.borderColor = backgroundShare.CGColor;
        
        viewToAdd.translatesAutoresizingMaskIntoConstraints = NO;
        [self addAttachedLayoutConstantsToSuperview: viewToAdd];
    } else {
        viewToAdd.layer.borderWidth = 0;
        [self.topScreen removeFromSuperview];
        
    }
}


- (void)superPositionElements: (UIView *)superViewScreenShare andElementsSendToFromt: (NSArray *)elements; {
    [self bringToFrontView:elements withSuperView:superViewScreenShare];
}

#pragma mark - private method
-(void)addAttachedLayoutConstantsToSuperview:(UIView *)view {
    
    if (!view.superview) {
        return;
    }
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:view
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:view.superview
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:0.0];
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:view
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:view.superview
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1.0
                                                                constant:0.0];
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:view
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:view.superview
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1.0
                                                                 constant:0.0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:view
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:view.superview
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0.0];
    [NSLayoutConstraint activateConstraints:@[top, leading, trailing, bottom]];
}

- (id) getPublisherStreamId; {
    return self.publisher.stream.streamId;
}

- (id) getSessionStreams; {
    return self.session.streams;
}

@end