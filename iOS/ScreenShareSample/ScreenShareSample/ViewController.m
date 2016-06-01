//
//  ViewController.m
//  ScreenShareSample
//
//  Created by Xi Huang on 4/26/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//
#import <ScreenShareKit/ScreenShareKit.h>
#import "ViewController.h"

@interface ViewController () <UIScrollViewDelegate>
@property (nonatomic) ScreenShareToolbarView *toolbarView;

@property (nonatomic) ScreenCapture *screenShare;
@property (nonatomic) ScreenCaptureHandler *screenCaptureHandler;
@end

@implementation ViewController

- (ScreenCaptureHandler *)screenCaptureHandler {
    if (!_screenCaptureHandler) {
       _screenCaptureHandler = [ScreenCaptureHandler screenCaptureHandler];
   }
    return _screenCaptureHandler;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // tool bar
    self.toolbarView = [ScreenShareToolbarView toolbar];
    self.screenCaptureHandler = [ScreenCaptureHandler screenCaptureHandler];
    
    // screen share view
    UIImage *image = [UIImage imageNamed:@"mvc"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [self.toolbarView.screenShareView addContentView:imageView];
    
    [self.view addSubview:self.toolbarView.screenShareView];
    [self.view addSubview:self.toolbarView];
    
    UIButton *screenshare = [[UIButton alloc] init];
    [screenshare setTitle:@"Screenshare" forState:UIControlStateNormal];
    [screenshare setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [screenshare addTarget:self action:@selector(ScreenShareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [screenshare setFrame:CGRectMake(100, 0, 120, 30)];
    [self.view addSubview:screenshare];
    
}

/**
 *  toggles the screen share of the current content of the screen
 */
- (IBAction)ScreenShareButtonPressed:(UIButton *)sender {
    self.screenShare = [[ScreenCapture alloc] initWithView: self.view];
    [self.screenCaptureHandler setScreenCaptureSource: self.screenShare];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end