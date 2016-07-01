//
//  OTTextChatView_UserInterface.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <OTTextChatKit/OTTextChatKit.h>

@interface OTTextChatView ()
#pragma mark - UIs
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// top view
@property (weak, nonatomic) IBOutlet UIView *textChatTopView;
@property (weak, nonatomic) IBOutlet UILabel *textChatTopViewTitle;

// input view
@property (weak, nonatomic) IBOutlet UIView *textChatInputView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
//@property (weak, nonatomic) IBOutlet UIButton *minimizeButton;

// other UIs
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIButton *errorMessage;

// constraints
@property (strong, nonatomic) NSLayoutConstraint *topViewLayoutConstraint;
@property (strong, nonatomic) NSLayoutConstraint *bottomViewLayoutConstraint;

@end
