//
//  TextChatUICustomizator_Properties.h
//  TextChatSample
//
//  Created by Xi Huang on 4/14/16.
//  Copyright © 2016 Esteban Cordero. All rights reserved.
//

#import "TextChatUICustomizator.h"

static NSString * const TextChatUIUpdatedNotificationName = @"TextChatUIUpdatedNotificationName";

@interface TextChatUICustomizator ()
+ (instancetype)customizator;
@property (nonatomic) UIColor *tableViewCellSendTextColor;
@property (nonatomic) UIColor *tableViewCellReceiveTextColor;
@property (nonatomic) UIColor *tableViewCellSendBackgroundColor;
@property (nonatomic) UIColor *tableViewCellReceiveBackgroundColor;
@end