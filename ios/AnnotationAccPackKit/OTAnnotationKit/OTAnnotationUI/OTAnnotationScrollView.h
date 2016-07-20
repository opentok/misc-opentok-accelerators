//
//  OTAnnotationScrollView.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <OTAnnotationKit/OTAnnotationView.h>
#import <OTAnnotationKit/OTAnnotationTextView.h>
#import <OTAnnotationKit/OTAnnotationToolbarView.h>
#import <OTAnnotationKit/OTAnnotationDataManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface OTAnnotationScrollView : UIView

/**
 *  A boolean value to indicate whether the annotation scoll view is annotatable.
 */
@property (nonatomic, getter = isAnnotatable) BOOL annotatable;

/**
 *  A boolean value to indicate whether the annotation scroll view is zoomable.
 */
@property (nonatomic, getter = isZoomEnabled) BOOL zoomEnabled;

/**
 *  The associated annotation view.
 */
@property (readonly, nonatomic) OTAnnotationView *annotationView;

/**
 *  Initializes an annotataion scroll view with the specified frame rectangle.
 *
 *  @param frame The frame rectangle for the view, measured in points.
 *
 *  @return A new OTAnnotationScrollView object.
 */
- (instancetype)initWithFrame:(CGRect)frame;

/**
 *  Add the annotatable content with a given view. 
 *  Scrolling will be enabled automatically if the bounds rectangle of the given view is larger than the bounds rectangle of the annotation scroll view.
 *
 *  @param view The content view.
 */
- (void)addContentView:(UIView *)view;

#pragma mark - Tool bar
/**
 *  A tool bar view that has all essential operations to annotate. 
 *  This is optional, all operations can be performed programmatically.
 *  This will be nil until initializeToolbarView gets called.
 */
@property (nullable, readonly, nonatomic) OTAnnotationToolbarView *toolbarView;

/**
 *  Initializes the associated tool bar view.
 */
- (void)initializeToolbarView;

#pragma mark - Annotation
/**
 *  Add an adjusted text annotation to the annotation scroll view
 *
 *  @param annotationTextView The text annotation
 */
- (void)addTextAnnotation:(OTAnnotationTextView *)annotationTextView;

@end

NS_ASSUME_NONNULL_END
