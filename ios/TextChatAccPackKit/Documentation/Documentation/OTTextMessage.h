//
//  OTTextMessage.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>

/**
 *  A data model describing information used in individual text chat messages.
 */
@interface OTTextMessage : NSObject
/**
 *  The alias of the sender or receiver.
 */
@property (nonatomic, readonly) NSString *alias;
/**
 *  A unique identifier for the sender of the message.
 */
@property (nonatomic, readonly) NSString *senderId;
/**
 *  The content of the text message.
 */
@property (nonatomic, readonly) NSString *text;
/**
 *  The date and time when the message was sent (UNIXTIMESTAMP format).
 */
@property (nonatomic, readonly) NSDate *dateTime;
@end
