//
//  TextChatComponentTableViewCell.h
//  TextChatComponent
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextChatTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *message;

@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *UserLetterLabel;
@property (weak, nonatomic) IBOutlet UIView *userFirstLetter;
@property (weak, nonatomic) IBOutlet UIView *cornerUp;
@property (weak, nonatomic) IBOutlet UIView *cornerUpLeft;
@end
