//
//  TextChatUICustomizator.m
//  TextChatSample
//
//  Created by Esteban Cordero on 4/13/16.
//  Copyright © 2016 Esteban Cordero. All rights reserved.
//

#import "TextChatUICustomizator.h"

@implementation TextChatUICustomizator

- (void)setTableViewCellSendTextColor: (UIColor *)color; {
    if (!color) return;
    self.tableViewCellSendTextColor = color;
}

- (void)setTableViewCellReceiveTextColor: (UIColor *)color; {
    if (!color) return;
    self.tableViewCellReceiveTextColor = color;
}

- (void)setTableViewCellSendBackgroundColor: (UIColor *)color;{
    if (!color) return;
    self.tableViewCellSendBackgroundColor = color;
}

- (void)setTableViewCellReceiveBackgroundColor: (UIColor *)color;{
    if (!color) return;
    self.tableViewCellReceiveBackgroundColor = color;
}

- (void)setTopBarBackgroundColor: (UIColor *)color;{
    if (!color) return;
    self.topBarBackgroundColor = color;
}

- (void)setTopBarTitleTextColor: (UIColor *)color;{
    if (!color) return;
    self.topBarTitleTextColor = color;
}

@end
