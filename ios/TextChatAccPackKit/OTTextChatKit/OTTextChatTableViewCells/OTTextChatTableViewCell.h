//
//  TextChatComponentTableViewCell.h
//  TextChatComponent
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import <OTTextChatKit/OTTextChatUICustomizator.h>
#import "OTTextMessage.h"
#import "OTTextMessage_Private.h"

@interface OTTextChatTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *message;

@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *UserLetterLabel;
@property (weak, nonatomic) IBOutlet UIView *userFirstLetter;
@property (weak, nonatomic) IBOutlet UIView *cornerUp;
@property (weak, nonatomic) IBOutlet UIView *cornerUpLeft;

- (void)updateCellFromTextChat:(OTTextMessage *)textChat
                  customizator:(OTTextChatUICustomizator *)customizator;

@end
