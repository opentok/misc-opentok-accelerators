//
//  TextChatMessage.m
//  TextChatSampleApp
//
//  Created by Xi Huang on 4/1/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "TextChat.h"

static NSString * const kText = @"text";

static NSString * const kSender = @"sender";
static NSString * const kSenderAlias = @"alias";
static NSString * const kSenderId = @"id";

static NSString * const kSendOn = @"sentOn";

@implementation TextChat

- (instancetype)initWithMessage:(NSString *)message
                          alias:(NSString *)alias
                       senderId:(NSString *)senderId {
    if (self = [super init]) {
        _alias = alias.length ? alias : @"";
        _senderId = senderId.length ? senderId : @"";
        _text = message;
        _type = TCMessageTypesSent;
        _dateTime = [[NSDate alloc] init];
    }
    return self;
}

- (instancetype)initWithJSONString:(NSString *)jsonString {

    if (!jsonString || !jsonString.length) return nil;

    if (self = [super init]) {

        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonError;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&jsonError];

        if (jsonError) {
            NSLog(@"Error to read JSON data");
            return nil;
        }

        if (dict[kText] && [dict[kText] isKindOfClass:[NSString class]]) {
            _text = dict[kText];
        }

        if (dict[kSender] && dict[kSender][kSenderAlias] && [dict[kSender][kSenderAlias] isKindOfClass:[NSString class]]) {
            _alias = dict[kSender][kSenderAlias];
        }

        if (dict[kSender] && dict[kSender][kSenderId] && [dict[kSender][kSenderId] isKindOfClass:[NSString class]]) {
            _senderId = dict[kSender][kSenderId];
        }


        if (dict[kSendOn] && [dict[kSendOn] isKindOfClass:[NSString class]]) {
            _dateTime = [NSDate dateWithTimeIntervalSince1970:[dict[kSendOn] doubleValue]];
        }

        _type = TCMessageTypesReceived;
    }
    return self;
}

- (NSString *)getTextChatSignalJSONString {

    if (!self.alias || !self.senderId || !self.text) return nil;

    NSError *jsonError;
    NSDictionary *json = @{kText: self.text,
                           kSender: @{
                                   kSenderAlias: self.alias,
                                   kSenderId: self.senderId,
                                   },
                           kSendOn: @([self.dateTime timeIntervalSince1970])
                           };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&jsonError];
    if (jsonError) {
        NSLog(@"Error to parse JSON data");
        return nil;
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
@end
