//
//  TextChatMessage.h
//  TextChatSampleApp
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A data model describing information used in individual text chat messages.
 */
@interface OTTextMessage : NSObject
/**
 *  alias of the sender/receiver
 */
@property (nonatomic, readonly) NSString *alias;
/**
 *  unique identifier for the sender of the message
 */
@property (nonatomic, readonly) NSString *senderId;
/**
 *  Content of the text message
 */
@property (nonatomic, readonly) NSString *text;
/**
 *  Date and time when the message was sent (UNIXTIMESTAMP format)
 */
@property (nonatomic, readonly) NSDate *dateTime;
@end
