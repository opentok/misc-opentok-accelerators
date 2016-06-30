//
//  ScreenShareTextView.h
//  ScreenShareSample
//
//  Created by Xi Huang on 4/27/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "OTAnnotatable.h"

@interface OTAnnotationTextView: UITextView <OTAnnotatable>

+ (instancetype)defaultWithTextColor:(UIColor *)textColor;

- (instancetype)initWithText:(NSString *)text
                   textColor:(UIColor *)textColor
                    fontSize:(CGFloat)fontSize;

- (void)commit;

@end
