//
//  OTTextMessage_Private.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTTextMessage.h"

@interface OTTextMessage ()

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
