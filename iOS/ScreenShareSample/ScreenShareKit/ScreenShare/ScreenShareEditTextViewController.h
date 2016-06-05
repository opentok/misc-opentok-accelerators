//
//  ScreenShareEditTextViewController.h
//  ScreenShareSample
//
//  Created by Xi Huang on 6/2/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnnotationTextView.h"

@class ScreenShareEditTextViewController;
@protocol ScreenShareEditTextViewProtocol <NSObject>
- (void)screenShareEditTextViewController:(ScreenShareEditTextViewController *)editTextViewController
                         didFinishEditing:(AnnotationTextView *)annotationTextView;
@end


@interface ScreenShareEditTextViewController : UIViewController

@property (weak, nonatomic) id<ScreenShareEditTextViewProtocol> delegate;

+ (instancetype)defaultWithTextColor:(UIColor *)textColor;

- (instancetype)initWithText:(NSString *)text
                   textColor:(UIColor *)textColor
                    fontSize:(CGFloat)fontSize;

@end
