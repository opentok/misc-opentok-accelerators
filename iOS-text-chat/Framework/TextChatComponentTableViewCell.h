//
//  TextChatComponentTableViewCell.h
//  TextChatComponent
//
//  Created by Esteban Cordero on 1/28/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextChatComponentTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *username;
@property (nonatomic, weak) IBOutlet UILabel *time;
@property (nonatomic, weak) IBOutlet UITextView *message;

@property (weak, nonatomic) IBOutlet UILabel *UserLetterLabel;
@property (weak, nonatomic) IBOutlet UIView *userFirstLetter;
@property (weak, nonatomic) IBOutlet UIView *cornerUp;
@property (weak, nonatomic) IBOutlet UIView *cornerUpLeft;

@property (weak, nonatomic) IBOutlet UIView *textChatView;
@end
