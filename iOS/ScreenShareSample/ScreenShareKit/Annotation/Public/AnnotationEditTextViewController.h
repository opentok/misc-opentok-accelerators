//
//  ScreenShareEditTextViewController.h
//  ScreenShareSample
//
//  Created by Xi Huang on 6/2/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnnotationTextView.h"

@class AnnotationEditTextViewController;
@protocol AnnotationEditTextViewProtocol <NSObject>
- (void)annotationEditTextViewController:(AnnotationEditTextViewController *)editTextViewController
                        didFinishEditing:(AnnotationTextView *)annotationTextView;
@end


@interface AnnotationEditTextViewController : UIViewController

@property (weak, nonatomic) id<AnnotationEditTextViewProtocol> delegate;

+ (instancetype)defaultWithTextColor:(UIColor *)textColor;

- (instancetype)initWithText:(NSString *)text
                   textColor:(UIColor *)textColor
                    fontSize:(CGFloat)fontSize;

@end
