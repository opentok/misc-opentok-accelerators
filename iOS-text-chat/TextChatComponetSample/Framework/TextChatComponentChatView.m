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
  BOOL minimized;
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

- (IBAction)minimizeView:(UIButton *)sender {
  UIImage* maximize_image = [UIImage imageNamed:@"maximize"];
  UIImage* minimize_image = [UIImage imageNamed:@"minimize"];
  CGRect r = [self.layer frame];
  if (minimized) {
    [sender setImage:minimize_image forState:UIControlStateNormal];
    r.origin.y = (_topNavBar.layer.bounds.size.height - _topNavBar.layer.bounds.size.height/2);
    minimized = NO;
  } else {
    [sender setImage:maximize_image forState:UIControlStateNormal];
    r.origin.y = (self.layer.bounds.size.height - (_topNavBar.layer.bounds.size.height /2));
    minimized = YES;
  }
  [self.layer setFrame:r];
}

- (IBAction)closeButton:(UIButton *)sender {
  [self removeFromSuperview];
}
@end
