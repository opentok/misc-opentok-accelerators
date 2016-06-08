
#import <UIKit/UIKit.h>

@interface ScreenSharer : NSObject

@property (readonly, nonatomic) BOOL isScreenSharing;

+ (instancetype)screenSharer;
+ (void) setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token;

- (void)connectWithView:(UIView *)view;

- (void)disconnect;

@end
