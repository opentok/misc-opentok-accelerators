//
//  ScreenShareView.h
//  ScreenShareSample
//
//  Created by Xi Huang on 4/26/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OTScreenShareKit/OTAnnotationTextView.h>
#import <OTScreenShareKit/OTAnnotationToolbarView.h>

@interface OTAnnotationScrollView : UIView

@property (nonatomic, getter = isAnnotating) BOOL annotating;

@property (nonatomic, getter = isZoomEnabled) BOOL zoomEnabled;

- (instancetype)init;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)addContentView:(UIView *)view;  // this will enable scrolling if image is larger than actual device screen

@property (readonly, nonatomic) OTAnnotationToolbarView *toolbarView;
- (void)initializeToolbarView;

#pragma mark - annotation
- (void)startDrawing;

@property (nonatomic) UIColor *annotationColor;

- (void)addTextAnnotation:(OTAnnotationTextView *)annotationTextView;

- (UIImage *)captureScreen;

- (void)erase;

- (void)eraseAll;

@end
