//
//  TextChatUICustomizator.m
//  TextChatSample
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTTextChatUICustomizator.h"
#import "OTTextChatUICustomizator_Private.h"

@implementation OTTextChatUICustomizator

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
