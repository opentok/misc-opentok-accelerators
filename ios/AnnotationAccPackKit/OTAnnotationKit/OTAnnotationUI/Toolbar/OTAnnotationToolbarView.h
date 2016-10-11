//
//  OTAnnotationToolbarView.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OTAnnotationToolbarView;
@protocol OTAnnotationToolbarViewDataSource <NSObject>
- (UIView *)annotationToolbarViewForRootViewForScreenShot:(OTAnnotationToolbarView *)toolbarView;
@end

@protocol OTAnnotationToolbarViewDelegate <NSObject>
- (void)annotationToolbarView:(OTAnnotationToolbarView *)toolbarView didPressToolbarViewItemButtonAtIndexPath:(NSIndexPath *)indexPath;
@end

typedef NS_ENUM(NSUInteger, OTAnnotationToolbarViewOrientation) {
    OTAnnotationToolbarViewOrientationPortraitlBottom = 0,
    OTAnnotationToolbarViewOrientationLandscapeLeft,
    OTAnnotationToolbarViewOrientationLandscapeRight
};

@interface OTAnnotationToolbarView : UIView

/**
 *  The object that acts as the data source of the annotation toolbar view.
 *
 *  The delegate must adopt the OTAnnotationToolbarViewDataSource protocol. The data source is not retained.
 */
@property (weak, nonatomic) id<OTAnnotationToolbarViewDataSource> toolbarViewDataSource;

/**
 *  The object that acts as the delegate of the annotation toolbar view.
 *
 *  The delegate must adopt the OTAnnotationToolbarViewDelegate protocol. The delegate is not retained.
 */
@property (weak, nonatomic) id<OTAnnotationToolbarViewDelegate> toolbarViewDelegate;

/**
 *  The orientation of this annotation toolbar.
 *
 *  @discussion The default value is OTAnnotationToolbarViewOrientationPortraitlBottom. It assumes the position of toolbar view is at the bottom and all assosiated animation will be performed upwards.
 *  Set it to OTAnnotationToolbarViewOrientationLandscapeLeft, it assumes the position of toolbar view is on the left and all assosiated animation will be performed towards right.
 *  Set it to OTAnnotationToolbarViewOrientationLandscapeRight, it assumes the position of toolbar view is on the right and all assosiated animation will be performed towards left.
 *
 */
@property (nonatomic) OTAnnotationToolbarViewOrientation toolbarViewOrientation;

@end
