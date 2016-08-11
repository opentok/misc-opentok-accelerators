//
//  ScreenShareTextView.h
//
//  Copyright © 2016 Tokbox. All rights reserved.
//

#import <OTAnnotationKit/OTAnnotatable.h>

@class OTAnnotationTextView;

@protocol OTAnnotationTextViewDelegate <NSObject>

- (void)annotationTextViewDidFinishChange:(OTAnnotationTextView *)textView;

- (void)annotationTextViewDidCancel:(OTAnnotationTextView *)textView;

@end

/**
 *  The class describes a text annotation in an OTAnnotationView. The text view is draggable, resizable and rotatable.
 */
@interface OTAnnotationTextView: UITextView <OTAnnotatable>

extern NSString *const OTAnnotationTextViewDidFinishChangeNotification;
extern NSString *const OTAnnotationTextViewDidCancelChangeNotification;

/**
 *  A boolean value to indicate whether the text view is resizable by using pinch gesture on it.
 */
@property (nonatomic, getter=isResizable) BOOL resizable;

/**
 *  A boolean value to indicate whether the text view is draggable by using pan gesture on it.
 */
@property (nonatomic, getter=isDraggable) BOOL draggable;

/**
 *  A boolean value to indicate whether the text view is rotatable by using rotate gesture on it.
 */
@property (nonatomic, getter=isRotatable) BOOL rotatable;

@property (weak, nonatomic) id<OTAnnotationTextViewDelegate> annotationTextViewDelegate;

/**
 *  Initialize a text annotation with given textColor.
 *
 *  @param textColor The text color.
 *
 *  @return A new object of OTAnnotationTextView.
 */
+ (instancetype)defaultWithTextColor:(UIColor *)textColor;

/**
 *  Initialize a text annotation with given content, color and font size.
 *
 *  @param text      The content of the text view.
 *  @param textColor The text color.
 *  @param fontSize  The font size of the content.
 *
 *  @return A new object of OTAnnotationTextView
 */
- (instancetype)initWithText:(NSString *)text
                   textColor:(UIColor *)textColor
                    fontSize:(CGFloat)fontSize;
/**
 *  Commit the change.
 */
- (void)commit;

@end
