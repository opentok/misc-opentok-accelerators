//
//  TextChatMessage.h
//  TextChatSampleApp
//
//  Created by Xi Huang on 4/1/16.
//  Copyright © 2016 TokBox. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A data model describing information used in individual text chat messages.
 */
@interface TextChat : NSObject

/**
 *  Alias of the sender
 */
@property (nonatomic, copy) NSString *alias;

/**
 *  Identifier of the sender
 */
@property (nonatomic, copy) NSString *senderId;

/**
 *  Content of the text message
 */
@property (nonatomic, copy) NSString *text;

/**
 *  Time of the text message sent or received
 */
@property (nonatomic, copy) NSDate *dateTime;
@end
