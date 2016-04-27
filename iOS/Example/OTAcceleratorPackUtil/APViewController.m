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

@end

@implementation APViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    FakeAccePack1 *pack1 = [[FakeAccePack1 alloc] init];
    FakeAccePack2 *pack2 = [[FakeAccePack2 alloc] init];
    [pack1 connect];
    [pack2 connect];
}

@end
