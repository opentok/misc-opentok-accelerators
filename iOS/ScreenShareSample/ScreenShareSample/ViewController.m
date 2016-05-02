//
//  ViewController.m
//  ScreenShareSample
//
//  Created by Xi Huang on 4/26/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "ViewController.h"
#import <ScreenShareKit/ScreenShareView.h>
#import <ScreenShareKit/ScreenShareTextField.h>
#import <ScreenShareKit/ScreenShareColorPickerView.h>

@interface ViewController () <UIScrollViewDelegate>
@property (nonatomic) ScreenShareTextField *textField;
@property (nonatomic) UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic) ScreenShareView *shareView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // ScreenShareView example
    UIImage *image = [UIImage imageNamed:@"mvc"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(imageView.bounds), CGRectGetHeight(imageView.bounds))];
    [self.contentView addSubview:imageView];
    
    self.scrollView.delegate = self;
    self.scrollView.maximumZoomScale = 3.0;
    [self.scrollView addSubview:self.contentView];
    [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.contentView.bounds), CGRectGetHeight(self.contentView.bounds))];
    
    self.shareView = [ScreenShareView viewWithStrokeColor:[UIColor yellowColor]];
    self.shareView.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds) * 2, CGRectGetHeight(self.contentView.bounds) * 2);
    [self.contentView addSubview:self.shareView];

    // ScreenShareTextField example
//    self.textField = [ScreenShareTextField textField];
//    [self.view addSubview:self.textField];
    
    // ScreenShareColorPickerView example
//    ScreenShareColorPickerView *pickerView = [ScreenShareColorPickerView colorPickerView];
//    CGFloat height =  CGRectGetWidth([UIScreen mainScreen].bounds) / 9;
//    pickerView.frame = CGRectMake(0, height, height * 9, height);
//    [self.view addSubview:pickerView];
}



- (IBAction)changeScrollable:(id)sender {
    self.scrollView.scrollEnabled = !self.scrollView.scrollEnabled;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.contentView;
}

@end