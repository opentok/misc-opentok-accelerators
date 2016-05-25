//
//  ViewController.m
//  ScreenShareSample
//
//  Created by Xi Huang on 4/26/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "ViewController.h"
#import <ScreenShareKit/ScreenShareKit.h>

@interface ViewController () <UIScrollViewDelegate>
@property (nonatomic) ScreenShareToolbarView *toolbarView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // tool bar
    self.toolbarView = [ScreenShareToolbarView toolbar];
    
    // screen share view
    UIImage *image = [UIImage imageNamed:@"mvc"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [self.toolbarView.screenShareView addContentView:imageView];
    
    [self.view addSubview:self.toolbarView.screenShareView];
    [self.view addSubview:self.toolbarView];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end