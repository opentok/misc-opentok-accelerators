//
//  AnnotationOverContentViewController.m
//  ScreenShareSample
//
//  Created by Xi Huang on 6/23/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "AnnotationOverContentViewController.h"
#import "ScreenShareToolbarView.h"

@interface AnnotationOverContentViewController ()
@property (nonatomic) ScreenShareToolbarView *toolbarView;
@end

@implementation AnnotationOverContentViewController

- (instancetype)init {
    if (self = [super init]) {
        _toolbarView = [ScreenShareToolbarView toolbar];
        CGFloat height = _toolbarView.bounds.size.height;
        _toolbarView.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - height, _toolbarView.bounds.size.width, height);
        
        UIView *clearView = [[UIView alloc] initWithFrame:self.view.bounds];
        [_toolbarView.screenShareView addContentView:clearView];
        
        [self.view addSubview:_toolbarView.screenShareView];
        [self.view addSubview:_toolbarView];
        
        
        self.providesPresentationContextTransitionStyle = YES;
        self.definesPresentationContext = YES;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        UILabel *statusLabel =  [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 20)];
        [statusLabel setBackgroundColor:[UIColor greenColor]];
        [statusLabel setText:@"You are annotating your screen"];
        [statusLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [statusLabel setTextAlignment:NSTextAlignmentCenter];
        [self.view addSubview:statusLabel];
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
