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
        
        UIView *clearView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.annotationView = [[OTAnnotationScrollView alloc] init];
        self.annotationView.zoomEnabled = NO;
        [self.annotationView addContentView:clearView];
        
        [self.annotationView initializeToolbarView];
        CGFloat height = self.annotationView.toolbarView.bounds.size.height;
        self.annotationView.toolbarView.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - height, self.annotationView.toolbarView.bounds.size.width, height);
        
        self.annotationView.frame = CGRectMake(0,
                                               0,
                                               CGRectGetWidth([UIScreen mainScreen].bounds),
                                               CGRectGetHeight([UIScreen mainScreen].bounds) - height);
        [self.view addSubview:self.annotationView];
        [self.view addSubview:self.annotationView.toolbarView];
        
        self.providesPresentationContextTransitionStyle = YES;
        self.definesPresentationContext = YES;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        self.annotationView.scrollView.scrollEnabled = NO;
        self.annotationView.scrollView.pinchGestureRecognizer.enabled = NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
