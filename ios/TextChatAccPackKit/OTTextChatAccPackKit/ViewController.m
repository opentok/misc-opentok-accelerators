//
//  ViewController.m
//  OTTextChatAccPackKit
//
//  Created by Xi Huang on 6/24/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "ViewController.h"
#import <OTTextChatKit/OTTextChatKit.h>

@interface ViewController ()
@property (nonatomic) OTTextChatView *textChatView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.textChatView = [TextChatView textChatViewWithBottomView:self.bottomView];
    self.textChatView = [OTTextChatView textChatView];
    // starting the accellpack connection with the session
    [self.textChatView connect];
}

- (IBAction)startTextChat:(UIButton *)sender {
    if (!self.textChatView.isShown) {
        [self.textChatView show];
    } else {
        [self.textChatView dismiss];
    }
    // OPTIONAL COLOR CHANGING
    // [TextChatUICustomizator setTableViewCellSendBackgroundColor:[UIColor orangeColor]];
    // [TextChatUICustomizator setTableViewCellReceiveBackgroundColor:[UIColor yellowColor]];

}
@end
