//
//  TextChatUICustomizator.m
//  TextChatSample
//
//  Created by Esteban Cordero on 4/13/16.
//  Copyright © 2016 Esteban Cordero. All rights reserved.
//

#import "TextChatUICustomizator.h"

@implementation TextChatUICustomizator

- (void)notifyUserInterfaceUpdate {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TextChatUIUpdatedNotificationName object:self];
}

- (void)setTableViewCellSendTextColor: (UIColor *)color; {
    _tableViewCellSendTextColor = color;
    [self notifyUserInterfaceUpdate];
}

- (void)setTableViewCellReceiveTextColor: (UIColor *)color; {
    _tableViewCellReceiveTextColor = color;
    [self notifyUserInterfaceUpdate];
}

- (void)setTableViewCellSendBackgroundColor: (UIColor *)color;{
    _tableViewCellSendBackgroundColor = color;
    [self notifyUserInterfaceUpdate];
}

- (void)setTableViewCellReceiveBackgroundColor: (UIColor *)color;{
    _tableViewCellReceiveBackgroundColor = color;
    [self notifyUserInterfaceUpdate];
}

- (void)setTopBarBackgroundColor: (UIColor *)color;{
    _topBarBackgroundColor = color;
    [self notifyUserInterfaceUpdate];
}

- (void)setTopBarTitleTextColor: (UIColor *)color;{
    _topBarTitleTextColor = color;
    [self notifyUserInterfaceUpdate];
}

@end
