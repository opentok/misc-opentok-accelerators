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
//@property (nonatomic) ScreenShareTextField *textField;
//@property (nonatomic) UIView *contentView;
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic) ScreenShareView *shareView;
@property (nonatomic) ScreenShareToolbarView *toolbarView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // ScreenShareView example
    self.shareView = [ScreenShareView view];
    
    UIImage *image = [UIImage imageNamed:@"mvc"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [self.shareView addContentView:imageView];
    
    self.shareView.frame = CGRectMake(0, 50, CGRectGetWidth(self.shareView.bounds), CGRectGetHeight(self.shareView.bounds));
    [self.view addSubview:self.shareView];
    
    self.toolbarView = [[ScreenShareToolbarView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) - 50, CGRectGetWidth([UIScreen mainScreen].bounds), 50)];
    [self.view addSubview:self.toolbarView];
    
    [self.shareView testAnnotating];
}


- (IBAction)changeScrollable:(id)sender {
    self.shareView.scrollEnabled = !self.shareView.scrollEnabled;
}
@end