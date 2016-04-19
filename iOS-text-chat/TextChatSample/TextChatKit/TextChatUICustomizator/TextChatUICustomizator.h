//
//  TextChatUICustomizator.h
//  TextChatSample
//
//  Created by Esteban Cordero on 4/13/16.
//  Copyright © 2016 Tokbox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextChatUICustomizator : NSObject

+ (void)setTableViewCellSendTextColor: (UIColor *)color;

+ (void)setTableViewCellReceiveTextColor: (UIColor *)color;

+ (void)setTableViewCellSendBackgroundColor: (UIColor *)color;

+ (void)setTableViewCellReceiveBackgroundColor: (UIColor *)color;

@end
