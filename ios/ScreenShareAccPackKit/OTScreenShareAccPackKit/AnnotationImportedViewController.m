//
//  ViewController.m
//  ScreenShareSample
//
//  Created by Xi Huang on 4/26/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "AnnotationImportedViewController.h"
#import <OTScreenShareKit/OTScreenShareKit.h>

@interface AnnotationImportedViewController ()
@property (nonatomic) OTAnnotationScrollView *screenShareView;
@end

@implementation AnnotationImportedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // screen share view
    UIImage *image = [UIImage imageNamed:@"mvc"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    self.screenShareView = [[OTAnnotationScrollView alloc] initWithFrame:CGRectMake(0,
                                                                                    0,
                                                                                    CGRectGetWidth([UIScreen mainScreen].bounds),
                                                                                    CGRectGetHeight([UIScreen mainScreen].bounds) - 44)];
    [self.screenShareView addContentView:imageView];
    
    [self.screenShareView initializeToolbarView];
    CGFloat height = self.screenShareView.toolbarView.bounds.size.height;
    self.screenShareView.toolbarView.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) - height, self.screenShareView.toolbarView.bounds.size.width, height);
    
    [self.view addSubview:self.screenShareView];
    [self.view addSubview:self.screenShareView.toolbarView];
}

@end