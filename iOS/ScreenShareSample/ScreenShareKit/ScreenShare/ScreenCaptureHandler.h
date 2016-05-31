

#import <Foundation/Foundation.h>
#import "ScreenCapture.h"

@interface ScreenCaptureHandler : NSObject

@property (nonatomic) BOOL isScreenSharing;

/**
 * Use shared session from Accelerator pack.
 */
+ (instancetype)screenCaptureHandler;

+ (void)setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token;

+ (instancetype)sharedInstance;

/**
 * returns the publisher to be able to add it to the subview that correspond 
 * @param screenCapture is and instance with the view to share
 */

- (void)setScreenCaptureSource:(ScreenCapture *)screenCapture ;

- (void)setVideoSourceToScreenShare;
- (void)removeVideoSourceScreenShare;

@end
