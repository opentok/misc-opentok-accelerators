//
//  ScreenShareToolbarViewController.m
//  ScreenShareSample
//
//  Created by Xi Huang on 5/10/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "ScreenShareToolbarViewController.h"

#import <ScreenShareKit/ScreenShareKit.h>

@interface ScreenShareToolbarViewController()
@property (nonatomic) ScreenShareToolbarView *toolbarView;
@property (nonatomic) ScreenShareColorPickerView *colorPickerView;
@end

@implementation ScreenShareToolbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.toolbarView = [ScreenShareToolbarView screenShareToolbarView];
    self.toolbarView.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) - 50, CGRectGetWidth([UIScreen mainScreen].bounds), 50);
    [self.view addSubview:self.toolbarView];
    
    self.colorPickerView = [ScreenShareColorPickerView colorPickerView];
    self.colorPickerView.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) - 60 - 50 - 10, CGRectGetWidth([UIScreen mainScreen].bounds), 60);
    [self.view addSubview:self.colorPickerView];
}

@end
