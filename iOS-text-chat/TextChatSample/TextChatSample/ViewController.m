//
//  ViewController.m
//  TextChatSample
//
//  Created by Esteban Cordero on 4/7/16.
//  Copyright © 2016 Esteban Cordero. All rights reserved.
//

#import <TextChatkit/TextChatKit.h>
#import "ViewController.h"

@interface ViewController () <TextChatViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) TextChatView *textChatView;
@property (strong, nonatomic) OneToOneCommunicator *oneToOneCommunicator;
@end

@implementation ViewController

- (TextChatView *)textChatView {
    if (!_textChatView) {
        _textChatView = [TextChatView textChatViewWithBottomView:self.bottomView];
    }
    return _textChatView;
}

- (OneToOneCommunicator *)oneToOneCommunicator {
    if (!_oneToOneCommunicator) {
        _oneToOneCommunicator = [OneToOneCommunicator oneToOneCommunicator];
    }
    return _oneToOneCommunicator;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.textChatView setDelegate:self];
    [self.textChatView setMaximumTextMessageLength:30];
    [self.textChatView setAlias:@"Tokboxer"];
    [self.textChatView connect];
}

- (IBAction)connectToTextChatButtonPressed:(id)sender {
    [self.textChatView connectWithHandler:^(TextChatViewEventSignal signal, TextChat *textChat, NSError *error) {
        
    }];
}

- (IBAction)disconnectToTextChatButtonPressed:(id)sender {
    [self.textChatView disconnect];
}

- (IBAction)connectToAVButtonPressed:(id)sender {
    [self.oneToOneCommunicator connectWithHandler:^(OneToOneCommunicationSignal signal, NSError *error) {
        
    }];
}

- (IBAction)disconnectToAVButtonPressed:(id)sender {
    [self.oneToOneCommunicator disconnect];
}

- (IBAction)ChangeTopColor:(id)sender {
    [self.textChatView.customizator setTopBarBackgroundColor:[UIColor orangeColor]];
    [self.textChatView.customizator setTopBarTitleTextColor:[UIColor redColor]];
}

- (IBAction)changeRedButtonPressed:(id)sender {
    [self.textChatView.customizator setTableViewCellSendTextColor:[UIColor orangeColor]];
    [self.textChatView.customizator setTableViewCellSendBackgroundColor:[UIColor greenColor]];
}

- (IBAction)changeBlueButtonPressed:(id)sender {
    [self.textChatView.customizator setTableViewCellSendTextColor:[UIColor redColor]];
    [self.textChatView.customizator setTableViewCellSendBackgroundColor:[UIColor yellowColor]];
}


- (IBAction)buttonPressed:(id)sender {
    if (!self.textChatView.isShown) {
        [self.textChatView show];
    }
}

- (IBAction)hideButtonPressed:(id)sender {
    
    [self.textChatView dismiss];
}

- (void)textChatView:(TextChatView *)textChatView didSendtextChat:(TextChat *)textChat error:(NSError *)error {
    NSLog(@"%s: error: %@", __PRETTY_FUNCTION__, error);
}

- (void)textChatView:(TextChatView *)textChatView didReceiveTextChat:(TextChat *)textChat {
    NSLog(@"%s: ", __PRETTY_FUNCTION__);
}

@end