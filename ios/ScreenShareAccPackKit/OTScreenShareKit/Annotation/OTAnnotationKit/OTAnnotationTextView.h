//
//  OTAnnotationTextView.h
//  
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotatable.h"

@interface OTAnnotationTextView: UITextView <OTAnnotatable>

+ (instancetype)defaultWithTextColor:(UIColor *)textColor;

- (instancetype)initWithText:(NSString *)text
                   textColor:(UIColor *)textColor
                    fontSize:(CGFloat)fontSize;

- (void)commit;

@end
