//
//  OTTextChatTableViewCell.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTTextChatTableViewCell.h"

#import "OTTextChatUICustomizator.h"

@implementation OTTextChatTableViewCell

- (void)awakeFromNib {
    
    self.layer.cornerRadius = 6.0f;
    self.message.layer.cornerRadius = 6.0f;
    
    self.message.textContainer.lineFragmentPadding = 20;
    self.userFirstLetter.layer.cornerRadius = 25.0f;
    self.userFirstLetter.layer.masksToBounds = YES;
    
    UIBezierPath *pathRight = [UIBezierPath new];
    [pathRight moveToPoint:(CGPoint){0, 0}];
    [pathRight addLineToPoint:(CGPoint){0, 30}];
    [pathRight addLineToPoint:(CGPoint){30, 0}];
    [pathRight addLineToPoint:(CGPoint){0, 0}];
    
    UIBezierPath *pathleft = [UIBezierPath new];
    [pathleft moveToPoint:(CGPoint){0, 0}];
    [pathleft addLineToPoint:(CGPoint){30, 0}];
    [pathleft addLineToPoint:(CGPoint){30, 30}];
    [pathleft addLineToPoint:(CGPoint){0, 0}];
    
    self.cornerUpRightView = [self cornerMaker:self.cornerUpRightView andWithPath:pathRight];
    self.cornerUpLeftView = [self cornerMaker:self.cornerUpLeftView andWithPath:pathleft];
}

- (UIView *) cornerMaker: (UIView *)view andWithPath:(UIBezierPath *)path {
    CAShapeLayer *maskleft = [CAShapeLayer new];
    maskleft.frame = view.bounds;
    maskleft.path = path.CGPath;
    view.layer.mask = maskleft;
    return view;
}

- (void)updateCellFromTextChat:(OTTextMessage *)textChat
                  customizator:(OTTextChatUICustomizator *)customizator {
    
    if (!textChat) return;
    
    NSDate *current_date = textChat.dateTime == nil ? [NSDate date] : textChat.dateTime;
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"hh:mm a";
    NSString *msg_sender = [textChat.alias length] > 0 ? textChat.alias : @" ";
    self.userLetterLabel.text = [msg_sender substringToIndex:1];
    self.userTimeLabel.text = [NSString stringWithFormat:@"%@, %@", msg_sender, [timeFormatter stringFromDate: current_date]];
    self.message.text = textChat.text;
    
    switch (textChat.type) {
        case TCMessageTypesSent:
        case TCMessageTypesSentShort:
            if(customizator.tableViewCellSendBackgroundColor != nil) self.message.backgroundColor = customizator.tableViewCellSendBackgroundColor;
            if(customizator.tableViewCellSendTextColor != nil) self.message.textColor = customizator.tableViewCellSendTextColor;
            if(customizator.tableViewCellSendBackgroundColor != nil) self.cornerUpRightView.backgroundColor = customizator.tableViewCellSendBackgroundColor;
            break;
        case TCMessageTypesReceived:
        case TCMessageTypesReceivedShort:
            if(customizator.tableViewCellReceiveBackgroundColor != nil)self.message.backgroundColor = customizator.tableViewCellReceiveBackgroundColor;
            if(customizator.tableViewCellReceiveTextColor != nil)self.message.textColor = customizator.tableViewCellReceiveTextColor;
            if(customizator.tableViewCellReceiveBackgroundColor != nil)self.cornerUpLeftView.backgroundColor = customizator.tableViewCellReceiveBackgroundColor;
            break;
        default:
            break;
    }}

@end
