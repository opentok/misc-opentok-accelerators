//
//  OTTextMessage_Private.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTTextMessage.h"

@interface OTTextMessage ()

/**
 *  @typedef TCMessageTypes Type of message useful to add the respective UI to differenciate between a
 *                          recent send message or a message follow by another message send by the same person
 *  @brief TCMessageTypesSent, TCMessageTypesSentShort, TCMessageTypesReceived, TCMessageTypesReceivedShort
 *  @constant TCMessageTypesSent The message was send by the sender
 *  @constant TCMessageTypesSentShort This is when the sender send a consecutive message
 *  @constant TCMessageTypesReceived This is the message send by receiver
 *  @constant TCMessageTypesReceivedShort When the receiver sends consecutive messages
 */
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
