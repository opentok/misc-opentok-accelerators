//
//  TextChatMessage.h
//  TextChatSampleApp
//
//  Created by Xi Huang on 4/1/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TCMessageTypes) {
    TCMessageTypesSent = 0,
    TCMessageTypesSentShort,
    TCMessageTypesReceived,
    TCMessageTypesReceivedShort,
    TCMessageTypesDivider,
};

@interface TextChat : NSObject

/**
 * The sender alias for the message.
 */
@property (nonatomic, copy) NSString *senderAlias;
/**
 * The unique ID of the sender.
 */
@property (nonatomic, copy) NSString *senderId;
/**
 * The text of the message.
 */
@property (nonatomic, copy) NSString *text;
/**
 * The timestamp for the message.
 */
@property (nonatomic, copy) NSDate *dateTime;

/**
 * The type of the message
 */
@property (nonatomic) TCMessageTypes type;

@end
