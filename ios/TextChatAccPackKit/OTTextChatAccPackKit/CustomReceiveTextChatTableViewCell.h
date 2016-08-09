//
//  CustomReceiveTextChatTableViewCell.h
//  OTTextChatAccPackKit
//
//  Created by Xi Huang on 8/7/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomReceiveTextChatTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *receiverAliasLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end
