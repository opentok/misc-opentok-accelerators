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
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) TextChatView *textChatView;
@end

@implementation ViewController

- (TextChatView *)textChatView {
    if (!_textChatView) {
        _textChatView = [TextChatView textChatViewWithBottomView:self.bottomView];
    }
    return _textChatView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.textChatView show];
}

- (IBAction)buttonPressed:(id)sender {
    if (!self.textChatView.isViewAttached) {
        [self.textChatView show];
    }
}


@end