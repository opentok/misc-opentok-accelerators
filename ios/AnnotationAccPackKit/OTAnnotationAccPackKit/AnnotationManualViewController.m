//
//  AnnotationManualViewController.m
//  OTAnnotationAccPackKit
//
//  Created by Xi Huang on 7/12/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "AnnotationManualViewController.h"
#import <OTAnnotationKit/OTAnnotationKit.h>

@interface AnnotationManualViewController ()
@property (nonatomic) OTAnnotationScrollView *screenShareView;
@end

@implementation AnnotationManualViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"mvc"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    self.screenShareView = [[OTAnnotationScrollView alloc] initWithFrame:CGRectMake(0,
                                                                                    64,
                                                                                    CGRectGetWidth([UIScreen mainScreen].bounds),
                                                                                    CGRectGetHeight([UIScreen mainScreen].bounds) - 64)];
    [self.screenShareView addContentView:imageView];
    [self.view addSubview:self.screenShareView];
    
    
    OTAnnotationPoint *p1 = [[OTAnnotationPoint alloc] initWithX:119 andY:16];
    OTAnnotationPoint *p2 = [[OTAnnotationPoint alloc] initWithX:122 andY:16];
    OTAnnotationPoint *p3 = [[OTAnnotationPoint alloc] initWithX:126 andY:18];
    OTAnnotationPoint *p4 = [[OTAnnotationPoint alloc] initWithX:134 andY:21];
    OTAnnotationPoint *p5 = [[OTAnnotationPoint alloc] initWithX:144 andY:28];
    OTAnnotationPath *path = [OTAnnotationPath pathWithPoints:@[p1, p2, p3, p4, p5] strokeColor:nil];
    [self.screenShareView drawWithAnnotatable:path];
    
    
    OTAnnotationPoint *p6 = [[OTAnnotationPoint alloc] initWithX:160 andY:16];
    OTAnnotationPoint *p7 = [[OTAnnotationPoint alloc] initWithX:160 andY:20];
    OTAnnotationPoint *p8 = [[OTAnnotationPoint alloc] initWithX:160 andY:24];
    OTAnnotationPoint *p9 = [[OTAnnotationPoint alloc] initWithX:160 andY:26];
    OTAnnotationPoint *p10 = [[OTAnnotationPoint alloc] initWithX:160 andY:30];
    OTAnnotationPath *path1 = [OTAnnotationPath pathWithPoints:@[p6, p7, p8, p9, p10] strokeColor:[UIColor redColor]];
    [self.screenShareView drawWithAnnotatable:path1];
}

@end
