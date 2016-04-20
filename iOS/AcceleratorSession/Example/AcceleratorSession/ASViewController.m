//
//  ASViewController.m
//  AcceleratorSession
//
//  Created by Lucas Huang on 04/12/2016.
//  Copyright (c) 2016 Lucas Huang. All rights reserved.
//

#import "ASViewController.h"
#import "FakeAccePack1.h"
#import "FakeAccePack2.h"
#import <AcceleratorSession/AcceleratorPackSession.h>

@interface ASViewController ()

@end

@implementation ASViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    FakeAccePack1 *acc1 = [[FakeAccePack1 alloc] init];
    FakeAccePack2 *acc2 = [[FakeAccePack2 alloc] init];
    
    [AcceleratorPackSession connect];
}

@end
