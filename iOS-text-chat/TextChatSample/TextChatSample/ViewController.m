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
    [self.textChatView setAlias:@"Lucas"];
    [self.textChatView connect];
}

- (IBAction)connectToAVButtonPressed:(id)sender {
    [self.oneToOneCommunicator connectWithHandler:^(OneToOneCommunicationSignal signal, NSError *error) {
        
    }];
}

- (IBAction)disconnectToAVButtonPressed:(id)sender {
    [self.oneToOneCommunicator disconnect];
}

- (IBAction)changeRedButtonPressed:(id)sender {
    [TextChatUICustomizator setTableViewCellSendTextColor:[UIColor orangeColor]];
    [TextChatUICustomizator setTableViewCellSendBackgroundColor:[UIColor greenColor]];
}

- (IBAction)changeBlueButtonPressed:(id)sender {
    [TextChatUICustomizator setTableViewCellSendTextColor:[UIColor redColor]];
    [TextChatUICustomizator setTableViewCellSendBackgroundColor:[UIColor yellowColor]];
}


- (IBAction)buttonPressed:(id)sender {
    if (!self.textChatView.isShown) {
        [self.textChatView show];
    }
}

- (IBAction)hideButtonPressed:(id)sender {
    
    [self.textChatView dismiss];
}

- (void)textChatViewDidSendMessage:(TextChatView *)textChatView
                             error:(NSError *)error {

    NSLog(@"error: %@", error.localizedDescription);
}

- (void)textChatViewDidReceiveMessage:(TextChatView *)textChatView {
    
}

@end