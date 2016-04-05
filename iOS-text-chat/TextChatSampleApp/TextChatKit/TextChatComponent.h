//
//  TextChatComponent.h
//  TextChatComponent
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <OpenTok/OpenTok.h>

#import "TextChat.h"
#import "TextChatView.h"

@protocol TextChatComponentDelegate <NSObject>
- (void)didConnectWithError:(NSError *)error;
- (void)didAddMessageWithError:(NSError *)error;
- (void)didReceiveMessage;
@end

@interface TextChatComponent : NSObject

@property (weak, nonatomic) id<TextChatComponentDelegate> delegate;

@property (readonly, nonatomic) OTSession *session;
@property (readonly, nonatomic) NSArray<TextChat *> *messages;
@property (readonly, nonatomic) NSSet<NSString *> *senders;
@property (readonly, nonatomic) NSString *senderId;
@property (readonly, nonatomic) NSString *alias;

- (void)connect;

- (void)sendMessage:(NSString *)message;

@end
