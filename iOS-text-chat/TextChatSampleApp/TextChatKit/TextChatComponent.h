//
//  TextChatComponent.h
//  TextChatComponent
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "TextChat.h"
#import "TextChatView.h"

typedef void (^TextChatBlock)(NSError *error);

@interface TextChatComponent : NSObject

@property (strong, nonatomic) NSMutableArray<TextChat *> *messages;
@property (strong, nonatomic) NSMutableDictionary *senders;
@property (strong, nonatomic) NSString *senderId;
@property (strong, nonatomic) NSString *alias;

- (void)connectWithHandler:(TextChatBlock)handler;

- (NSError *)sendMessage:(TextChat *)message;

@end
