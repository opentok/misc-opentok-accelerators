//
//  APViewController.m
//  OTAcceleratorPackUtil
//
//  Created by Lucas Huang on 04/27/2016.
//  Copyright (c) 2016 Lucas Huang. All rights reserved.
//

#import "APViewController.h"
#import "FakeAccePack1.h"
#import "FakeAccePack2.h"

@interface APViewController ()
@property (nonatomic) FakeAccePack1 *pack1;
@property (nonatomic) FakeAccePack2 *pack2;
@end

@implementation APViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.pack1 = [[FakeAccePack1 alloc] init];
    self.pack2 = [[FakeAccePack2 alloc] init];
    [self.pack1 connect];
    [self.pack2 connect];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.pack1 disconnect];
        [self.pack2 disconnect];
    });
}

@end
