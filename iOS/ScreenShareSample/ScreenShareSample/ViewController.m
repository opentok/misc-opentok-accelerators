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

@interface ViewController ()
@property (nonatomic) ScreenShareTextField *textField;
@property (nonatomic) ScreenShareView *shareView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    self.shareView = [ScreenShareView viewWithStrokeColor:[UIColor yellowColor]];
//    self.shareView.frame = CGRectMake(0, 20, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
//    [self.view addSubview:self.shareView];
    
    self.textField = [ScreenShareTextField textField];
    [self.view addSubview:self.textField];
}
@end