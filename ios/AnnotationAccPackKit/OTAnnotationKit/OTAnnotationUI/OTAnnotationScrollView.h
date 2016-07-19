//
//  OTAnnotationScrollView.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <OTAnnotationKit/OTAnnotationView.h>
#import <OTAnnotationKit/OTAnnotationTextView.h>
#import <OTAnnotationKit/OTAnnotationToolbarView.h>
#import <OTAnnotationKit/OTAnnotationDataManager.h>

@interface OTAnnotationScrollView : UIView

@property (nonatomic, getter = isAnnotating) BOOL annotating;

@property (nonatomic, getter = isZoomEnabled) BOOL zoomEnabled;

@property (readonly, nonatomic) OTAnnotationView *annotationView;

@property (readonly, nonatomic) OTAnnotationDataManager *annotationDataManager;

- (instancetype)init;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)addContentView:(UIView *)view;  // this will enable scrolling if image is larger than actual device screen

@property (readonly, nonatomic) OTAnnotationToolbarView *toolbarView;
- (void)initializeToolbarView;

#pragma mark - Annotation
- (void)startDrawing;

- (void)drawWithAnnotatable:(id<OTAnnotatable>)annotatable;

@property (nonatomic) UIColor *annotationColor;

- (void)addTextAnnotation:(OTAnnotationTextView *)annotationTextView;

- (UIImage *)captureScreen;

- (void)erase;

- (void)eraseAll;

@end
