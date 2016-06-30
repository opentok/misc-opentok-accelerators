//
//  AnnotationOverContentViewController.m
//  ScreenShareSample
//
//  Created by Xi Huang on 6/23/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "OTFullScreenAnnotationViewController.h"
#import "OTAnnotationScrollView.h"
#import "OTAnnotationScrollView_Private.h"

@interface OTFullScreenAnnotationViewController ()
@property (nonatomic) OTAnnotationScrollView *annotationView;
@end

@implementation OTFullScreenAnnotationViewController

- (instancetype)init {
    
    if (self = [super init]) {
        
        _annotationView= [[OTAnnotationScrollView alloc] init];
        _annotationView.zoomEnabled = NO;
        _annotationView.scrollView.scrollEnabled = NO;
        _annotationView.scrollView.pinchGestureRecognizer.enabled = NO;
        
        
        [_annotationView initializeToolbarView];
        CGFloat height = _annotationView.toolbarView.bounds.size.height;
        _annotationView.toolbarView.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - height, _annotationView.toolbarView.bounds.size.width, height);
        
        _annotationView.frame = CGRectMake(0,
                                           0,
                                           CGRectGetWidth([UIScreen mainScreen].bounds),
                                           CGRectGetHeight([UIScreen mainScreen].bounds) - height);
        [self.view addSubview:_annotationView];
        [self.view addSubview:_annotationView.toolbarView];
        
        UIView *clearView = [[UIView alloc] initWithFrame:_annotationView.bounds];
        [_annotationView addContentView:clearView];
        
        self.providesPresentationContextTransitionStyle = YES;
        self.definesPresentationContext = YES;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}

@end
