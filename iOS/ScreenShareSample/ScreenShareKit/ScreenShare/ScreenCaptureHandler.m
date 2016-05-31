
#import "ScreenCapture.h"
#import "ScreenCaptureHandler.h"
#import "OTAcceleratorSession.h"

@interface ScreenCaptureHandler()<OTSessionDelegate, OTPublisherDelegate>
@property (nonatomic) OTPublisher *screenShare;
@property (nonatomic) OTAcceleratorSession *session;

@property (strong, nonatomic) ScreenCapture *screenCapture;

@end

@implementation ScreenCaptureHandler


+ (instancetype)screenCaptureHandler {
    return [ScreenCaptureHandler sharedInstance];
}

+ (void)setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token {

    [OTAcceleratorSession setOpenTokApiKey:apiKey sessionId:sessionId token:token];
    [ScreenCaptureHandler sharedInstance];
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
    if (!self.screenShare) {
        self.screenShare = [[OTPublisher alloc] initWithDelegate:self name:@"ScreenShareS" audioTrack:NO videoTrack:YES];
    }
    // Additionally, the publisher video type can be updated to signal to
    // receivers that the video is from a screencast. This value also disables
    // some downsample scaling that is used to adapt to changing network
    // conditions. We will send at a lower framerate to compensate for this.
    [self.screenShare setVideoType:OTPublisherKitVideoTypeScreen];
    
    // This disables the audio fallback feature when using routed sessions.
    self.screenShare.audioFallbackEnabled = NO;
    
    // Finally, wire up the video source.
    [self.screenShare setVideoCapture: (id)self.screenCapture];
    [self.session publish:self.screenShare error:&error];
    if (error) NSLog(@"ERROR adding the videoCapture Source %@", error);
    self.isScreenSharing = YES;
}

- (void)removeVideoSourceScreenShare; {
    OTError *error;
    [self.screenShare setVideoType:OTPublisherKitVideoTypeCamera];
    
    [OTAcceleratorSession deregisterWithAccePack:self];
    if (self.screenShare){
        [self.session unpublish:self.screenShare error:&error];
        if (error) NSLog(@"ERROR removing the videoCapture Source %@", error);
        self.isScreenSharing = NO;
        self.screenShare = nil;
    }
}

- (void)sessionDidConnect:(OTSession *)session {
    [self setVideoSourceToScreenShare];
    NSLog(@" %@ ,  %@", [self class], NSStringFromSelector(_cmd));
}
- (void)sessionDidDisconnect:(OTSession *)session {
    [self removeVideoSourceScreenShare];
    NSLog(@" %@ ,  %@", [self class], NSStringFromSelector(_cmd));
}
- (void)session:(OTSession *)session streamCreated:(OTStream *)stream {}
- (void)session:(OTSession *)session streamDestroyed:(OTStream *)stream {}
- (void)session:(OTSession *)session didFailWithError:(OTError *)error { NSLog(@" DidfailWithError (%@)", error); }
- (void)publisher:(OTPublisherKit *)publisher didFailWithError:(OTError *)error { NSLog(@" fail Handler (%@)", error);}
@end