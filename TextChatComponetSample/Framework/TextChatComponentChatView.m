//
//  TextChatComponentChatView.m
//  TextChatComponent
//
//  Created by Esteban Cordero on 1/28/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import "TextChatComponentChatView.h"

@implementation TextChatComponentChatView {
  BOOL anchorToBottom;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [_textField resignFirstResponder];
  [super touchesBegan:touches withEvent:event];
}

-(void)disableAnchorToBottom {
  anchorToBottom = NO;
}

-(void)anchorToBottom {
  [self anchorToBottomAnimated:false];
}

-(void)anchorToBottomAnimated:(BOOL)animated {
  anchorToBottom = YES;
  if (![self isAtBottom]) {
    [_tableView setContentOffset:CGPointMake(0, MAX(0, _tableView.contentSize.height - _tableView.bounds.size.height)) animated:animated];
  }
}

-(BOOL)isAtBottom {
  return _tableView.contentOffset.y >=  _tableView.contentSize.height - _tableView.bounds.size.height;
}

-(BOOL)isAnchoredToBottom {
  return anchorToBottom;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  if (anchorToBottom) {
    [self anchorToBottomAnimated:YES];
  }
}

@end
