
#import <Foundation/Foundation.h>
#import <ScreenShareKit/ScreenCapture.h>

@interface ScreenCaptureHandler : NSObject

@property (nonatomic) BOOL isScreenSharing;

/**
 * Use shared session from Accelerator pack.
 */
+ (instancetype) screenCaptureHandler;

/**
 *  Set the internal keys fro the session to be created, this information can be get from your
 *  TokBox account
 *
 *  @param apiKey    your APIKey
 *  @param sessionId your sessionId
 *  @param token     your token
 */
+ (void) setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token;

+ (instancetype) sharedInstance;

/**
 * returns the publisher to be able to add it to the subview that correspond 
 * @param screenCapture is and instance with the view to share
 */

- (void) setScreenCaptureSource:(ScreenCapture *)screenCapture ;

/**
 *  set the video source to screen share and set publisher to use the screen capture module
 */
- (void) setVideoSourceToScreenShare;

/**
 *  remove the publisher and subscriber that are wire to screen share
 */
- (void) removeVideoSourceScreenShare;

/**
 *  helper to superposition elements when screensharing
 *
 *  @param superViewScreenShare the view that needs to be super position at
 *  @param elements             array of elements that need to be super positioned
 */
- (void)superPositionElements: (UIView *)superViewScreenShare andElementsSendToFromt: (NSArray *)elements;

/**
 *  get the ScreenShare publisher streamId
 *
 *  @return the publisher streamId
 */
- (id) getPublisherStreamId;

/**
 *  get this session streams to compare them and know which is the screnshare one
 *
 *  @return all streams on the current session
 */
- (id) getSessionStreams;

@end
