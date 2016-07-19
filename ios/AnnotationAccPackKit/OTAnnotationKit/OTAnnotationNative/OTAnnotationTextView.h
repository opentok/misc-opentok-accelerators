//
//  ScreenShareTextView.h
//
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <OTAnnotationKit/OTAnnotatable.h>

@interface OTAnnotationTextView: UITextView <OTAnnotatable>

+ (instancetype)defaultWithTextColor:(UIColor *)textColor;

- (instancetype)initWithText:(NSString *)text
                   textColor:(UIColor *)textColor
                    fontSize:(CGFloat)fontSize;

- (void)commit;

@end
