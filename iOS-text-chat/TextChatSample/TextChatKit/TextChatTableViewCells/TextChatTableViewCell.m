//
//  TextChatComponentTableViewCell.m
//  TextChatComponent
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import "TextChatTableViewCell.h"

#import "TextChatUICustomizator.h"

@implementation TextChatTableViewCell

- (void)awakeFromNib {
    
    self.layer.cornerRadius = 6.0f;
    self.message.layer.cornerRadius = 6.0f;
    
    self.message.textContainer.lineFragmentPadding = 20;
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

- (void)updateCellFromTextChat:(TextMessage *)textChat
                  customizator:(TextChatUICustomizator *)customizator {
    
    if (!textChat) return;
    
    NSDate *current_date = textChat.dateTime == nil ? [NSDate date] : textChat.dateTime;
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"hh:mm a";
    NSString *msg_sender = [textChat.alias length] > 0 ? textChat.alias : @" ";
    self.UserLetterLabel.text = [msg_sender substringToIndex:1];
    self.time.text = [NSString stringWithFormat:@"%@, %@", msg_sender, [timeFormatter stringFromDate: current_date]];
    self.message.text = textChat.text;
    
    switch (textChat.type) {
        case TCMessageTypesSent:
        case TCMessageTypesSentShort:
            if(customizator.tableViewCellSendBackgroundColor != nil) self.message.backgroundColor = customizator.tableViewCellSendBackgroundColor;
            if(customizator.tableViewCellSendTextColor != nil) self.message.textColor = customizator.tableViewCellSendTextColor;
            if(customizator.tableViewCellSendBackgroundColor != nil) self.cornerUp.backgroundColor = customizator.tableViewCellSendBackgroundColor;
            break;
        case TCMessageTypesReceived:
        case TCMessageTypesReceivedShort:
            if(customizator.tableViewCellReceiveBackgroundColor != nil)self.message.backgroundColor = customizator.tableViewCellReceiveBackgroundColor;
            if(customizator.tableViewCellReceiveTextColor != nil)self.message.textColor = customizator.tableViewCellReceiveTextColor;
            if(customizator.tableViewCellReceiveBackgroundColor != nil)self.cornerUpLeft.backgroundColor = customizator.tableViewCellReceiveBackgroundColor;
            break;
        default:
            break;
    }}

@end
