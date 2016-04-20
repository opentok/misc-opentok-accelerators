//
//  TextChatView_UserInterface.h
//  TextChatSample
//
//  Created by Xi Huang on 4/14/16.
//  Copyright © 2016 Esteban Cordero. All rights reserved.
//

#import <TextChatKit/TextChatKit.h>

@interface TextChatView ()
#pragma mark - UIs
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// top view
@property (weak, nonatomic) IBOutlet UIView *textChatTopView;
@property (weak, nonatomic) IBOutlet UILabel *textChatTopViewTitle;

// input view
@property (weak, nonatomic) IBOutlet UIView *textChatInputView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *minimizeButton;

// other UIs
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIButton *errorMessage;
@end
