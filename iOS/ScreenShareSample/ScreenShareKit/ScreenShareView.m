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

@interface ScreenShareView() <UIScrollViewDelegate>

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) AnnotationView *annotationView;
@end

@implementation ScreenShareView

- (BOOL)scrollEnabled {
    return self.scrollView.scrollEnabled;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    [self.scrollView setScrollEnabled:scrollEnabled];
}

+ (instancetype)view {
    return [[ScreenShareView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // scroll view
        CGRect deviceBounds = [UIScreen mainScreen].bounds;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(deviceBounds), CGRectGetHeight(deviceBounds))];
        [_scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
        _scrollView.maximumZoomScale = 3.0f;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        
        // annotation view
        _annotationView = [[AnnotationView alloc] initWithFrame:deviceBounds];
        [_scrollView addSubview:_annotationView];
    }
    return self;
}

- (void)addContentView:(UIView *)view {
    
    CGFloat width = self.scrollView.contentSize.width > CGRectGetWidth(view.bounds) ? self.scrollView.contentSize.width : CGRectGetWidth(view.bounds);
    CGFloat height = self.scrollView.contentSize.height > CGRectGetHeight(view.bounds) ? self.scrollView.contentSize.height : CGRectGetHeight(view.bounds);
    [self.scrollView setContentSize:CGSizeMake(width, height)];
    [self.scrollView insertSubview:view belowSubview:self.annotationView];
    [self.annotationView setFrame:CGRectMake(0, 0, width, height)];
}

- (void)testAnnotating {
    AnnotationPoint *p1 = [[AnnotationPoint alloc] initWithX:119 andY:16];
    AnnotationPoint *p2 = [[AnnotationPoint alloc] initWithX:122 andY:16];
    AnnotationPoint *p3 = [[AnnotationPoint alloc] initWithX:126 andY:18];
    AnnotationPoint *p4 = [[AnnotationPoint alloc] initWithX:134 andY:21];
    AnnotationPoint *p5 = [[AnnotationPoint alloc] initWithX:144 andY:28];
    AnnotationPath *path = [AnnotationPath pathWithPoints:@[p1, p2, p3, p4, p5] strokeColor:nil];
    [self.annotationView addAnnotatable:path];
    
    AnnotationTextField *textField = [AnnotationTextField textField];
    [self.annotationView addAnnotatable:textField];
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.annotationView;
}
@end
