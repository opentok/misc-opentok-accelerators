//
//  ViewController.m
//  TextChatSample
//
//  Created by Esteban Cordero on 4/7/16.
//  Copyright © 2016 Esteban Cordero. All rights reserved.
//

#import <TextChatkit/TextChatKit.h>
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [TextChatView textChatView];
}

@end