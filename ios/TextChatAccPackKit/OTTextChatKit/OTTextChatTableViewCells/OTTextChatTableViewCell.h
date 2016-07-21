//
//  OTTextChatTableViewCell.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <OTTextChatKit/OTTextChatUICustomizator.h>
#import "OTTextMessage.h"
#import "OTTextMessage_Private.h"

@interface OTTextChatTableViewCell : UITableViewCell

/**
 *  The message text displayed in the bubble.
 */
@property (weak, nonatomic) IBOutlet UITextView *message;

/**
 *  The time at which the message was received or sent.
 */
@property (weak, nonatomic) IBOutlet UILabel *userTimeLabel;

/**
 *  The first letter of the sender's name.
 */
@property (weak, nonatomic) IBOutlet UILabel *userLetterLabel;

/**
 *  View containing the first letter of the sender's name.
 */
@property (weak, nonatomic) IBOutlet UIView *userFirstLetter;

/**
 *  The corner of the message bubble when sending the message.
 */
@property (weak, nonatomic) IBOutlet UIView *cornerUpRightView;

/**
 *  The corner of the message bubble when receiving the message.
 */
@property (weak, nonatomic) IBOutlet UIView *cornerUpLeftView;

/**
 *  Update the cell with the specified text chat information, and apply UI customization if available.
 *
 *  @param textChat     The message being sent or received.
 *  @param customizer   UI customization for the bubble color or text color of the new message.
 */
-(void)updateCellFromTextChat:(OTTextMessage *)textChat
                   customizer:(OTTextChatUICustomizator *)customizer;

@end
