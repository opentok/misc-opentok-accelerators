//
//  OTAnnotationEditTextViewController.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTAnnotationTextView.h"

@class OTAnnotationEditTextViewController;

/**
 *  The delegate of an OTAnnotationEditTextViewController object must conform to the OTAnnotationEditTextViewProtocol protocol.
 *  Methods of the protocol allow the delegate to notify that text editing is finished.
 */
@protocol OTAnnotationEditTextViewProtocol <NSObject>

/**
 *  Notifies the delegate that the edit text view controller has finished editing the text.
 *
 *  @param editTextViewController The edit text view controller object.
 *  @param annotationTextView     The annotation text view object that checks if the user finished editing the text.
 */
- (void)annotationEditTextViewController:(OTAnnotationEditTextViewController *)editTextViewController
                        didFinishEditing:(OTAnnotationTextView *)annotationTextView;
@end


@interface OTAnnotationEditTextViewController : UIViewController

/**
 *  The object that acts as the delegate of the edit text view controller.
 *
 *  The delegate must adopt the OTAnnotationEditTextViewProtocol protocol. The delegate is not retained.
 */
@property (weak, nonatomic) id<OTAnnotationEditTextViewProtocol> delegate;

/**
 *  Initializer Factory method to set the default color for the text.
 *
 *  @param textColor The default text color.
 *
 *  @return A text object initialized with the default color.
 */
+ (instancetype)defaultWithTextColor:(UIColor *)textColor;

- (instancetype)initWithText:(NSString *)text
                   textColor:(UIColor *)textColor;

/**
 *  Creates a new annotation edit text object initialized with text, color, and font size.
 *
 *  @param text      The text string.
 *  @param textColor The text color.
 *  @param fontSize  The text font size.
 *
 *  @return The initialized edit text object.
 */
- (instancetype)initWithText:(NSString *)text
                   textColor:(UIColor *)textColor
                    fontSize:(CGFloat)fontSize
__attribute__((deprecated("use initWithText:textColor: instead")));

@end
