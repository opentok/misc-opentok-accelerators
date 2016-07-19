//
//  OTAnnotationScrollView.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotationScrollView.h"
#import "OTAnnotationPath.h"
#import "OTAnnotationView.h"
#import "OTAnnotationTextView.h"

#import "OTAnnotationEditTextViewController.h"
#import "OTAnnotationScreenCaptureViewController.h"

#import "OTAnnotationScrollView_Private.h"
#import "OTAnnotationToolbarView_Private.h"

#import "UIViewController+Helper.h"
#import <OTKAnalytics/OTKLogger.h>

#import "Constants.h"

@interface OTAnnotationScrollView() <UIScrollViewDelegate>
@property (nonatomic) OTAnnotationView *annotationView;
@property (nonatomic) OTAnnotationDataManager *annotationDataManager;
@property (nonatomic) OTAnnotationToolbarView *toolbarView;

@property (nonatomic) NSLayoutConstraint *annotationScrollViewWidth;
@property (nonatomic) NSLayoutConstraint *annotationScrollViewHeigth;
@end

@implementation OTAnnotationScrollView

- (OTAnnotationDataManager *)annotationDataManager {
    return _annotationView.annotationDataManager;
}

- (void)setAnnotating:(BOOL)annotating {
    _annotating = annotating;
    
    if (self.scrollView.contentSize.width > CGRectGetWidth(self.frame) || self.scrollView.contentSize.height > CGRectGetHeight(self.frame)) {
        self.scrollView.scrollEnabled = !_annotating;
    }
    
    if (self.zoomEnabled) {
        self.scrollView.pinchGestureRecognizer.enabled = !annotating;
    }
    
    if (!_annotating) {
        [self.annotationView setCurrentAnnotatable:nil];
    }
}

- (void)setZoomEnabled:(BOOL)zoomEnabled {
    _zoomEnabled = zoomEnabled;
    
    if (_zoomEnabled) {
        _scrollView.maximumZoomScale = 3.0f;
    }
    else {
        _scrollView.maximumZoomScale = 1.0f;
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.scrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void)setAnnotationColor:(UIColor *)annotationColor {
    [self.annotationView setCurrentAnnotatable:[OTAnnotationPath pathWithStrokeColor:annotationColor]];
    [OTKLogger logEventAction:KLogActionPickerColor variation:KLogVariationSuccess completion:nil];
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        // scroll view
        _zoomEnabled = YES;
        _scrollView = [[UIScrollView alloc] init];
        [_scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
        _scrollView.maximumZoomScale = 3.0f;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        [NSLayoutConstraint constraintWithItem:_scrollView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_scrollView
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1.0
                                      constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_scrollView
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0
                                      constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_scrollView
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1.0
                                      constant:0.0].active = YES;
        
        // scroll content view
        _scrollContentView  = [[UIView alloc] init];
        [_scrollContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_scrollView addSubview:_scrollContentView];
        [NSLayoutConstraint constraintWithItem:_scrollContentView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_scrollView
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_scrollContentView
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_scrollView
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1.0
                                      constant:0.0].active = YES;
        _annotationScrollViewWidth = [NSLayoutConstraint constraintWithItem:_scrollContentView
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0
                                                                       constant:CGRectGetWidth(frame)];
        _annotationScrollViewWidth.active = YES;
        _annotationScrollViewHeigth = [NSLayoutConstraint constraintWithItem:_scrollContentView
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0
                                                                       constant:CGRectGetHeight(frame)];
        _annotationScrollViewHeigth.active = YES;
        
        // annotation view
        _annotationView = [[OTAnnotationView alloc] init];
        [_annotationView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_scrollContentView addSubview:_annotationView];
        [NSLayoutConstraint constraintWithItem:_annotationView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_scrollContentView
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_annotationView
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_scrollContentView
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1.0
                                      constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_annotationView
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_scrollContentView
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0
                                      constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_annotationView
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_scrollContentView
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1.0
                                      constant:0.0].active = YES;
    }
    return self;
}

- (void)addSubview:(UIView *)view {
    if ([view conformsToProtocol:@protocol(OTAnnotatable)] && !self.annotating) return;
    [super addSubview:view];
}

- (void)addContentView:(UIView *)view {

    CGFloat width = CGRectGetWidth(view.bounds) > self.annotationScrollViewWidth.constant ? CGRectGetWidth(view.bounds) : self.annotationScrollViewWidth.constant;
    CGFloat height = CGRectGetHeight(view.bounds) > self.annotationScrollViewHeigth.constant ? CGRectGetHeight(view.bounds) : self.annotationScrollViewHeigth.constant;
    
    [self.scrollView setContentSize:CGSizeMake(width, height)];
    [self.scrollContentView insertSubview:view belowSubview:self.annotationView];
    
    self.annotationScrollViewWidth.constant = width;
    self.annotationScrollViewHeigth.constant = height;
}

- (void)initializeToolbarView {
    CGRect mainBounds = [UIScreen mainScreen].bounds;
    self.toolbarView = [[OTAnnotationToolbarView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(mainBounds), DefaultToolbarHeight) annotationScrollView:self];
    [OTKLogger logEventAction:KLogActionUseToolbar variation:KLogVariationSuccess completion:nil];
}

- (void)startDrawing {
    [self.annotationView setCurrentAnnotatable:[OTAnnotationPath pathWithStrokeColor:self.annotationColor]];
}

- (void)drawWithAnnotatable:(id<OTAnnotatable>)annotatable {
    [self.annotationView addAnnotatable:annotatable];
}

- (void)addTextAnnotation:(OTAnnotationTextView *)annotationTextView {
    [self.scrollView setZoomScale:1.0 animated:NO];   // this will need to reset in case that added text view is out of bound
    annotationTextView.frame = CGRectMake(self.scrollView.contentOffset.x + LeadingPaddingOfAnnotationTextView,
                                          self.scrollView.contentOffset.y + annotationTextView.frame.origin.y,
                                          CGRectGetWidth(annotationTextView.bounds),
                                          CGRectGetHeight(annotationTextView.bounds));
    [self.annotationView addAnnotatable:annotationTextView];
    [self.annotationView setCurrentAnnotatable:annotationTextView];
}

- (UIImage *)captureScreen {
    [OTKLogger logEventAction:KLogActionScreenCapture variation:KLogVariationSuccess completion:nil];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContext(screenRect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextFillRect(ctx, screenRect);
    [self.window.layer renderInContext:ctx];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)erase {
    [self.annotationView undoAnnotatable];
    [OTKLogger logEventAction:KLogActionErase variation:KLogVariationSuccess completion:nil];
}

- (void)eraseAll {
    [self.annotationView removeAllAnnotatables];
    [OTKLogger logEventAction:KLogActionErase variation:KLogVariationSuccess completion:nil];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.scrollContentView;
}

@end
