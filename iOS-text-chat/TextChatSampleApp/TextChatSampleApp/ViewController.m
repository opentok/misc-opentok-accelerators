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
    
    CGRect r = self.view.bounds;
    r.origin.y += 20;
    r.size.height -= 20;
    [self.textChatView setFrame:r];
    [self.view insertSubview:self.textChatView belowSubview:self.connectingLabel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // fade in
    self.textChatView.alpha = 0;
    
    [UIView animateWithDuration:0.5 animations:^() {
        _connectingLabel.alpha = 0;
        self.textChatView.alpha = 1;
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
  NSDictionary* info = [aNotification userInfo];
  CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
  double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  [UIView animateWithDuration:duration animations:^{

    CGRect r = self.view.bounds;
    r.origin.y += 20;
    r.size.height -= 20 + kbSize.height;
    self.textChatView.frame = r;
  }];
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
  NSDictionary* info = [aNotification userInfo];
  double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  [UIView animateWithDuration:duration animations:^{

    CGRect r = self.view.bounds;
    r.origin.y += 20;
    r.size.height -= 20;
    self.textChatView.frame = r;

  }];
}

@end
