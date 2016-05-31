
#import "ScreenCapture.h"
#import "ScreenCaptureHandler.h"
#import "OTAcceleratorSession.h"

@interface ScreenCaptureHandler()<OTSessionDelegate, OTPublisherDelegate, OTSubscriberDelegate>
@property (nonatomic) OTPublisher *publisher;
@property (nonatomic) OTSubscriber *subscriber;
@property (nonatomic) OTAcceleratorSession *session;

@property (strong, nonatomic) ScreenCapture *screenCapture;

@end

@implementation ScreenCaptureHandler


+ (instancetype)screenCaptureHandler {
    return [ScreenCaptureHandler sharedInstance];
}

+ (instancetype)sharedInstance {
    
    static ScreenCaptureHandler *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ScreenCaptureHandler alloc] init];
        sharedInstance.isScreenSharing = NO;
        sharedInstance.session = [OTAcceleratorSession getAcceleratorPackSession];
    });
    return sharedInstance;
}

- (void)setScreenCaptureSource:(ScreenCapture *)screenCapture {
    [OTAcceleratorSession registerWithAccePack:self];
    // need to explcitly publish and subscribe if the communicator joins/rejoins a connected session
    self.screenCapture = screenCapture;
}

- (void)setVideoSourceToScreenShare; {
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

- (void)removeVideoSourceScreenShare; {
    OTError *error;
    [OTAcceleratorSession deregisterWithAccePack:self];
    if (self.publisher){
        [self.session unpublish:self.publisher error:&error];
        if (error) NSLog(@"ERROR removing the videoCapture Source %@", error);
        self.isScreenSharing = NO;
    }
    self.publisher = nil;
}

- (void)sessionDidConnect:(OTSession *)session {
    [self setVideoSourceToScreenShare];
    NSLog(@" %@ ,  %@", [self class], NSStringFromSelector(_cmd));
}
- (void)sessionDidDisconnect:(OTSession *)session {
    [self removeVideoSourceScreenShare];
    NSLog(@" %@ ,  %@", [self class], NSStringFromSelector(_cmd));
}
- (void)session:(OTSession *)session streamCreated:(OTStream *)stream {
    if ([self.publisher.stream.streamId isEqualToString: stream.streamId]) {
        NSLog(@"session streamCreated (%@)", stream.streamId);
        
        OTError *error;
        self.subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
        [self.session subscribe:self.subscriber error:&error];
        if (error) NSLog(@"ERROR adding screenshare subscriber %@", error);
    }

}
- (void)session:(OTSession *)session streamDestroyed:(OTStream *)stream {
    NSLog(@"session streamDestroyed (%@)", stream.streamId);
    
    if ([self.subscriber.stream.streamId isEqualToString:stream.streamId]) {
        [self.session unsubscribe:self.subscriber error:nil];
        [self.subscriber.view removeFromSuperview];
        self.subscriber = nil;
    }

}
- (void)session:(OTSession *)session didFailWithError:(OTError *)error { NSLog(@" DidfailWithError (%@)", error); }
- (void)publisher:(OTPublisherKit *)publisher didFailWithError:(OTError *)error { NSLog(@" fail Handler (%@)", error);}
@end