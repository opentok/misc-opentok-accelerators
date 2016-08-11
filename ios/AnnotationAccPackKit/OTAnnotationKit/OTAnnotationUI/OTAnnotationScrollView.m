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
@property (nonatomic) OTAnnotationToolbarView *toolbarView;

@property (nonatomic) NSLayoutConstraint *annotationScrollViewWidth;
@property (nonatomic) NSLayoutConstraint *annotationScrollViewHeigth;
@end

@implementation OTAnnotationScrollView
- (void)setAnnotatable:(BOOL)annotatable {
    _annotatable = annotatable;
    
    if (self.scrollView.contentSize.width > CGRectGetWidth(self.frame) || self.scrollView.contentSize.height > CGRectGetHeight(self.frame)) {
        self.scrollView.scrollEnabled = !_annotatable;
    }
    
    if (self.zoomEnabled) {
        self.scrollView.pinchGestureRecognizer.enabled = !_annotatable;
    }
    
    if (!_annotatable) {
        [self.annotationView setCurrentAnnotatable:nil];
        [self.annotationView setUserInteractionEnabled:NO];
    }
    else {
        [self.annotationView setUserInteractionEnabled:YES];
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
    self.annotationScrollViewWidth.constant = frame.size.width;
    self.annotationScrollViewHeigth.constant = frame.size.height;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        // scroll view
        _zoomEnabled = YES;
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
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
        _scrollContentView.translatesAutoresizingMaskIntoConstraints = NO;
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
        [self.scrollView setContentSize:CGSizeMake(self.annotationScrollViewWidth.constant, self.annotationScrollViewHeigth.constant)];
        
        // annotation view
        _annotationView = [[OTAnnotationView alloc] init];
        _annotationView.translatesAutoresizingMaskIntoConstraints = NO;
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
        
        self.annotatable = NO;
    }
    return self;
}

- (void)addSubview:(UIView *)view {
    if ([view conformsToProtocol:@protocol(OTAnnotatable)] && !self.annotatable) return;
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

- (void)addTextAnnotation:(OTAnnotationTextView *)annotationTextView {
    [self.scrollView setZoomScale:1.0 animated:NO];   // this will need to reset in case that added text view is out of bound
    annotationTextView.frame = CGRectMake(self.scrollView.contentOffset.x + LeadingPaddingOfAnnotationTextView,
                                          self.scrollView.contentOffset.y + annotationTextView.frame.origin.y,
                                          CGRectGetWidth(annotationTextView.bounds),
                                          CGRectGetHeight(annotationTextView.bounds));
    [self.annotationView setCurrentAnnotatable:annotationTextView];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.scrollContentView;
}

@end
