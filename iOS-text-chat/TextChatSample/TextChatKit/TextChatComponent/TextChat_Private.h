//
//  TextChat_Private.h
//  TextChatSample
//
//  Created by Xi Huang on 5/6/16.
//  Copyright © 2016 Esteban Cordero. All rights reserved.
//

#import "TextChat.h"

@interface TextChat ()

typedef NS_ENUM(NSUInteger, TCMessageTypes) {
    TCMessageTypesSent = 0,
    TCMessageTypesSentShort,
    TCMessageTypesReceived,
    TCMessageTypesReceivedShort,
};

@property (nonatomic) TCMessageTypes type;
- (instancetype)initWithMessage:(NSString *)message
                          alias:(NSString *)alias
                       senderId:(NSString *)senderId;
- (instancetype)initWithJSONString:(NSString *)jsonString;
- (NSString *)getTextChatSignalJSONString;

@end
