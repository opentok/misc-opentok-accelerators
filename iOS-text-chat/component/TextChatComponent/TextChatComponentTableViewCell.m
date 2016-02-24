//
//  TextChatComponentTableViewCell.m
//  TextChatComponent
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import "TextChatComponentTableViewCell.h"

@implementation TextChatComponentTableViewCell

- (void)awakeFromNib {
  // Initialization code
  self.message.textContainer.lineFragmentPadding = 20;
  //self.message.textContainerInset = UIEdgeInsetsZero;
  
  self.userFirstLetter.layer.cornerRadius = 25.0f;
  self.userFirstLetter.layer.masksToBounds = YES;

  
  UIBezierPath *path = [UIBezierPath new];
  [path moveToPoint:(CGPoint){0, 0}];
  [path addLineToPoint:(CGPoint){0, 30}];
  [path addLineToPoint:(CGPoint){30, 0}];
  [path addLineToPoint:(CGPoint){0, 0}];
  
  CAShapeLayer *mask = [CAShapeLayer new];
  mask.frame = self.cornerUp.bounds;
  mask.path = path.CGPath;
  self.cornerUp.layer.mask = mask;
  
  
  UIBezierPath *pathleft = [UIBezierPath new];
  [pathleft moveToPoint:(CGPoint){0, 0}];
  [pathleft addLineToPoint:(CGPoint){30, 0}];
  [pathleft addLineToPoint:(CGPoint){30, 30}];
  [pathleft addLineToPoint:(CGPoint){0, 0}];
  
  CAShapeLayer *maskleft = [CAShapeLayer new];
  maskleft.frame = self.cornerUp.bounds;
  maskleft.path = pathleft.CGPath;
  self.cornerUpLeft.layer.mask = maskleft;
}

@end
