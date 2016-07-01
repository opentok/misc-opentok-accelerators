//
//  OTAnnotationEditTextViewController.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
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
