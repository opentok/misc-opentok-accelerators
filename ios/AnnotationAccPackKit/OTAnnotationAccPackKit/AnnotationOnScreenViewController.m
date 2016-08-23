//
//  AnnotationOnScreenViewController.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "AnnotationOnScreenViewController.h"
#import <OTAnnotationKit/OTAnnotationKit.h>

@interface AnnotationOnScreenViewController()
@property (nonatomic) OTFullScreenAnnotationViewController *annotationOverContentViewController;
@end

@implementation AnnotationOnScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.annotationOverContentViewController = [[OTFullScreenAnnotationViewController alloc] init];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Annotate" style:UIBarButtonItemStylePlain target:self action:@selector(startAnnotation)];
    
    UIButton *statusButton =  [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 20)];
    [statusButton addTarget:self action:@selector(stopAnnotation) forControlEvents:UIControlEventTouchUpInside];
    [statusButton setBackgroundColor:[UIColor greenColor]];
    [statusButton setTitle:@"You are annotating your screen, Tap here to dismiss" forState:UIControlStateNormal];
    [statusButton.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [self.annotationOverContentViewController.view addSubview:statusButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    
    CGRect navigationBarFrame = self.navigationController.navigationBar.frame;
    CGRect newFrame = CGRectMake(navigationBarFrame.origin.x, navigationBarFrame.origin.y, navigationBarFrame.size.width, 44);
    self.navigationController.navigationBar.frame = newFrame;
}

- (IBAction)viewPressed:(id)sender {
    [self.view bringSubviewToFront:sender];
}

- (void)startAnnotation {
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    CGRect navigationBarFrame = self.navigationController.navigationBar.frame;
    CGRect newFrame = CGRectMake(navigationBarFrame.origin.x, navigationBarFrame.origin.y, navigationBarFrame.size.width, 64);
    self.navigationController.navigationBar.frame = newFrame;
    [self presentViewController:self.annotationOverContentViewController animated:YES completion:nil];
}

- (void)stopAnnotation {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
