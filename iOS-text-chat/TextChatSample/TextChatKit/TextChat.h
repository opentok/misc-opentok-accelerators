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
@property (nonatomic, copy) NSString *senderAlias;
@property (nonatomic, copy) NSString *senderId;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSDate *dateTime;
@property (nonatomic) TCMessageTypes type;
@end
