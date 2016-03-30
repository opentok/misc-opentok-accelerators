//
//  TextChatComponentChatView.m
//  TextChatComponent
//
//  Created by Esteban Cordero on 2/23/16.
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
    [_tableView setContentOffset:CGPointMake(0, MAX(0, _tableView.contentSize.height - self.layer.bounds.size.height)) animated:animated];
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
    r.origin.y = 0;
    r.size.height = self.superview.bounds.size.height;
    minimized = NO;
  } else {
    [sender setImage:maximize_image forState:UIControlStateNormal];
    r.origin.y = (self.layer.bounds.size.height - _topNavBar.layer.bounds.size.height);
    r.size.height = _topNavBar.layer.bounds.size.height;
    minimized = YES;
  }
  self.frame = CGRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height);
}

- (IBAction)closeButton:(UIButton *)sender {
  // to reset the minimize button that can be on a different state when close button is hit
  [self.minimizeView setImage:[UIImage imageNamed:@"minimize"] forState:UIControlStateNormal];
  minimized = NO;
  [self removeFromSuperview];
}
@end
