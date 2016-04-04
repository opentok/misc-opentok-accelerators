//
//  TextChatComponent.m
//  TextChatComponent
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import "TextChatComponent.h"
#import "TextChat.h"
#import "TextChatTableViewCell.h"
#import "TextChatView.h"

#define DEFAULT_TTextChatE_SPAN 120

@implementation TextChatComponent


- (instancetype)init {
    if (self = [super init]) {
        _messages = [[NSMutableArray alloc] init];
    }
    return self;
}

//- (instancetype)init {
//  self = [super init];
//  if (self)  {
//    _messages = [[NSMutableArray alloc] init];
//
//    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//    
//    UINib *viewNIB = [UINib nibWithNibName:@"TextChatView" bundle:bundle];
//    [viewNIB instantiateWithOwner:self options:nil];
//
//    [_textChatView anchorToBottom];
//    
//    // Add padding
//    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
//    _textChatView.textField.leftView = paddingView;
//    _textChatView.textField.leftViewMode = UITextFieldViewModeAlways;
//  }
//  return self;
//}
@end
