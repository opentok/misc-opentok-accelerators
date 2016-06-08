//
//  ViewController.m
//  ScreenShareSample
//
//  Created by Xi Huang on 4/26/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//
#import <ScreenShareKit/ScreenShareKit.h>
#import "ViewController.h"

@interface ViewController ()
@property (nonatomic) ScreenShareToolbarView *toolbarView;
@property (nonatomic) ScreenSharer *screenCaptureHandler;

@property (weak, nonatomic) IBOutlet UIButton *screenShareButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // tool bar
    self.toolbarView = [ScreenShareToolbarView toolbar];
     self.screenCaptureHandler = [ScreenSharer screenSharer];
    
    // screen share view
    UIImage *image = [UIImage imageNamed:@"mvc"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [self.toolbarView.screenShareView addContentView:imageView];
    
    [self.view addSubview:self.toolbarView.screenShareView];
    [self.view addSubview:self.toolbarView];
    
    [self.view bringSubviewToFront:self.screenShareButton];
}

- (IBAction)ScreenShareButtonPressed:(UIButton *)sender {

    if (!self.screenCaptureHandler.isScreenSharing){
        [self.screenCaptureHandler connectWithView:self.view];
    }
    else {
        [self.screenCaptureHandler disconnect];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end