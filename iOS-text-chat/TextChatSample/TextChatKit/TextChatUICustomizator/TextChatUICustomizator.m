//
//  TextChatUICustomizator.m
//  TextChatSample
//
//  Created by Esteban Cordero on 4/13/16.
//  Copyright © 2016 Esteban Cordero. All rights reserved.
//

#import "TextChatUICustomizator.h"

#import "TextChatView_UserInterface.h"
#import "TextChatUICustomizator_Properties.h"

@implementation TextChatUICustomizator

+ (instancetype)customizator {
    
    static TextChatUICustomizator *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[TextChatUICustomizator alloc] init];
    });
    return sharedInstance;
}

- (void)userInterfaceUpdate {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TextChatUIUpdatedNotificationName object:self];
}

+ (void)setTableViewCellSendTextColor: (UIColor *)color; {
    if (!color) return;
    [TextChatUICustomizator customizator].tableViewCellSendTextColor = color;
    [[TextChatUICustomizator customizator] userInterfaceUpdate];
}

+ (void)setTableViewCellReceiveTextColor: (UIColor *)color; {
    if (!color) return;
    [TextChatUICustomizator customizator].tableViewCellReceiveTextColor = color;
    [[TextChatUICustomizator customizator] userInterfaceUpdate];
}

+ (void)setTableViewCellSendBackgroundColor: (UIColor *)color;{
    if (!color) return;
    [TextChatUICustomizator customizator].tableViewCellSendBackgroundColor = color;
    [[TextChatUICustomizator customizator] userInterfaceUpdate];
}

+ (void)setTableViewCellReceiveBackgroundColor: (UIColor *)color;{
    if (!color) return;
    [TextChatUICustomizator customizator].tableViewCellReceiveBackgroundColor = color;
    [[TextChatUICustomizator customizator] userInterfaceUpdate];
}

@end
