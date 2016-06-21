//
//  ScreenShareView.m
//  ScreenShareSample
//
//  Created by Xi Huang on 4/26/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "ScreenShareView.h"
#import "AnnotationPath.h"
#import "AnnotationView.h"
#import "AnnotationTextView.h"

#import "ScreenShareEditTextViewController.h"
#import "ScreenShareCaptureViewController.h"

#import "UIViewController+Helper.h"

#import "Constants.h"

@interface ScreenShareView() <UIScrollViewDelegate>

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *scrollContentView;
@property (nonatomic) AnnotationView *annotationView;
@end

@implementation ScreenShareView

- (void)setAnnotating:(BOOL)annotating {
    _annotating = annotating;
    self.scrollView.scrollEnabled = !_annotating;
    self.scrollView.pinchGestureRecognizer.enabled = !annotating;
    if (!_annotating) {
        [self.annotationView setCurrentAnnotatable:nil];
    }
}

+ (instancetype)view {
    return [[ScreenShareView alloc] init];
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        CGRect mainScreenBounds = [UIScreen mainScreen].bounds;
        self.frame = CGRectMake(0, 0, CGRectGetWidth(mainScreenBounds), CGRectGetHeight(mainScreenBounds));
        
        // scroll view
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        _scrollView.maximumZoomScale = 3.0f;
        _scrollView.delegate = self;
        _scrollView.contentSize = self.frame.size;
        [self addSubview:_scrollView];
        
        // scroll content view
        _scrollContentView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        [_scrollView addSubview:_scrollContentView];
        
        // annotation view
        _annotationView = [[AnnotationView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        [_scrollContentView addSubview:_annotationView];
    }
    return self;
}

//- (void)testAnnotating {
//    AnnotationPoint *p1 = [[AnnotationPoint alloc] initWithX:119 andY:16];
//    AnnotationPoint *p2 = [[AnnotationPoint alloc] initWithX:122 andY:16];
//    AnnotationPoint *p3 = [[AnnotationPoint alloc] initWithX:126 andY:18];
//    AnnotationPoint *p4 = [[AnnotationPoint alloc] initWithX:134 andY:21];
//    AnnotationPoint *p5 = [[AnnotationPoint alloc] initWithX:144 andY:28];
//    AnnotationPath *path = [AnnotationPath pathWithPoints:@[p1, p2, p3, p4, p5] strokeColor:nil];
//    [self.annotationView addAnnotatable:path];
//
//    AnnotationTextField *textField = [AnnotationTextField textField];
//    [self.annotationView addAnnotatable:textField];
//}

- (void)addContentView:(UIView *)view {
    
    CGFloat width = self.scrollView.contentSize.width > CGRectGetWidth(view.bounds) ? self.scrollView.contentSize.width : CGRectGetWidth(view.bounds);
    CGFloat height = self.scrollView.contentSize.height > CGRectGetHeight(view.bounds) ? self.scrollView.contentSize.height : CGRectGetHeight(view.bounds);
    [self.scrollView setContentSize:CGSizeMake(width, height)];
    [self.scrollContentView insertSubview:view belowSubview:self.annotationView];
    [self.scrollContentView setFrame:CGRectMake(0, 0, width, height)];
    [self.annotationView setFrame:CGRectMake(0, 0, width, height)];
}

- (void)addTextAnnotation:(AnnotationTextView *)annotationTextView {
    
    [self.scrollView setZoomScale:1.0 animated:NO];   // this will need to reset in case that added text view is out of bound
    annotationTextView.frame = CGRectMake(self.scrollView.contentOffset.x, annotationTextView.frame.origin.y, CGRectGetWidth(annotationTextView.bounds), CGRectGetHeight(annotationTextView.bounds));
    [self.annotationView addAnnotatable:annotationTextView];
    [self.annotationView setCurrentAnnotatable:annotationTextView];
}

- (void)selectColor:(UIColor *)selectedColor {
    if (self.isAnnotating) {
        [self.annotationView setCurrentAnnotatable:[AnnotationPath pathWithStrokeColor:selectedColor]];
    }
}

- (UIImage *)captureScreen {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size,
                                           NO, [UIScreen mainScreen].scale);
    [self drawViewHierarchyInRect:self.bounds
               afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)erase {
    [self.annotationView undoAnnotatable];
}

- (void)eraseAll {
    [self.annotationView removeAllAnnotatables];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.scrollContentView;
}
@end
