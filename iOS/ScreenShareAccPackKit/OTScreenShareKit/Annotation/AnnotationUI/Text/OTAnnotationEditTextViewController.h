//
//  ScreenShareEditTextViewController.h
//  ScreenShareSample
//
//  Created by Xi Huang on 6/2/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTAnnotationTextView.h"

@class OTAnnotationEditTextViewController;
@protocol OTAnnotationEditTextViewProtocol <NSObject>
- (void)annotationEditTextViewController:(OTAnnotationEditTextViewController *)editTextViewController
                        didFinishEditing:(OTAnnotationTextView *)annotationTextView;
@end


@interface OTAnnotationEditTextViewController : UIViewController

@property (weak, nonatomic) id<OTAnnotationEditTextViewProtocol> delegate;

+ (instancetype)defaultWithTextColor:(UIColor *)textColor;

- (instancetype)initWithText:(NSString *)text
                   textColor:(UIColor *)textColor
                    fontSize:(CGFloat)fontSize;

@end
