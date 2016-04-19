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
};

@interface TextChat : NSObject
@property (nonatomic, copy) NSString *alias;
@property (nonatomic, copy) NSString *senderId;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSDate *dateTime;
@property (nonatomic) TCMessageTypes type;
- (instancetype)initWithMessage:(NSString *)message
                          alias:(NSString *)alias
                       senderId:(NSString *)senderId;
- (instancetype)initWithJSONString:(NSString *)jsonString;
- (NSString *)getTextChatSignalJSONString;
@end
