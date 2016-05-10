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

@property (weak, nonatomic) IBOutlet ScreenShareView *shareView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // ScreenShareView example
    UIImage *image = [UIImage imageNamed:@"mvc"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    [self.shareView addSubview:imageView];
}



- (IBAction)changeScrollable:(id)sender {
    self.shareView.scrollEnabled = !self.shareView.scrollEnabled;
}
@end