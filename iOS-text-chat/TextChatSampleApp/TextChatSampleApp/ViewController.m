//
//  ViewController.m
//  TextChatSampleApp
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//


#import <TextChatkit/TextChatKit.h>
#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) TextChatView *textChatView;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textChatView = [TextChatView textChatView];
    [self.view insertSubview:self.textChatView belowSubview:self.connectingLabel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    
    // fade in
    self.textChatView.alpha = 0;
    
    [UIView animateWithDuration:0.5 animations:^() {
        _connectingLabel.alpha = 0;
        self.textChatView.alpha = 1;
    }];
}
@end
