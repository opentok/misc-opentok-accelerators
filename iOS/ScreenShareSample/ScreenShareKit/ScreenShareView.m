//
//  ScreenShareView.m
//  ScreenShareSample
//
//  Created by Xi Huang on 4/26/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "ScreenShareView.h"
#import "ScreenSharePath.h"

#import "ScreenShareAnnotationView.h"

@interface ScreenShareView() <UIScrollViewDelegate>

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *scrollContentView;    // this is for encapsulating internally scroll view
@property (nonatomic) ScreenShareAnnotationView *annotationView;
@end

@implementation ScreenShareView

- (UIColor *)strokeColor {
    return _annotationView.drawingPath.strokeColor;
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    [_annotationView.drawingPath setStrokeColor:strokeColor];
}

- (BOOL)scrollEnabled {
    return _scrollView.scrollEnabled;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    [_scrollView setScrollEnabled:scrollEnabled];
}

+ (instancetype)viewWithStrokeColor:(UIColor *)color {
    
    ScreenShareView *view = [[ScreenShareView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [view initializeWithStrokeColor:color];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializeWithStrokeColor:[UIColor blackColor]];
    }
    return self;
}

- (void)awakeFromNib {
    [self initializeWithStrokeColor:[UIColor blackColor]];
}

- (void)initializeWithStrokeColor:(UIColor *)strokeColor {
    // scroll view
    CGRect deviceBounds = [UIScreen mainScreen].bounds;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(deviceBounds), CGRectGetHeight(deviceBounds))];
    [_scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    _scrollView.maximumZoomScale = 3.0f;
    _scrollView.delegate = self;
    [self addSubview:_scrollView];
    
    _scrollContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(deviceBounds), CGRectGetHeight(deviceBounds))];
    [_scrollView addSubview:_scrollContentView];
    
    // annotation view
    _annotationView = [[ScreenShareAnnotationView alloc] initWithFrame:deviceBounds strokeColor:[UIColor blackColor]];
    [_scrollContentView addSubview:_annotationView];
}


#pragma mark - UIView
- (void)addSubview:(UIView *)view {
    
    if (view == _scrollView || view == _annotationView) {
        [super addSubview:view];
        return;
    }
    
    CGFloat width = _scrollView.contentSize.width > CGRectGetWidth(view.bounds) ? _scrollView.contentSize.width : CGRectGetWidth(view.bounds);
    CGFloat height = _scrollView.contentSize.height > CGRectGetHeight(view.bounds) ? _scrollView.contentSize.height : CGRectGetHeight(view.bounds);
    [_scrollView setContentSize:CGSizeMake(width, height)];
    [_scrollContentView setFrame:CGRectMake(0, 0, width, height)];
    [_scrollContentView insertSubview:view belowSubview:_annotationView];
    [_annotationView setFrame:CGRectMake(0, 0, width, height)];
    
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.scrollContentView;
}
@end
