//
//  TextChatComponent.h
//  TextChatComponent
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import "TextChat.h"
#import "TextChatView.h"

@protocol TextChatComponentDelegate <NSObject>
- (void)didConnectWithError:(NSError *)error;
- (void)didDisConnectWithError:(NSError *)error;
- (void)didAddMessageWithError:(NSError *)error;
- (void)didReceiveMessage;
@end

@interface TextChatComponent : NSObject

@property (weak, nonatomic) id<TextChatComponentDelegate> delegate;

@property (readonly, nonatomic) NSArray<TextChat *> *messages;
@property (readonly, nonatomic) NSString *alias;
@property (readonly, nonatomic) NSString *receiverAlias;
@property (readonly, nonatomic) NSUInteger maximumTextMessageLength;

- (void)connect;

- (void)disconnect;

- (void)sendMessage:(NSString *)message;

- (TextChat *)getTextChatFromIndexPath:(NSIndexPath *)indexPath;

- (void)setAlias:(NSString *)alias;

- (void)setMaximumTextMessageLength:(NSUInteger)maximumTextMessageLength;

@end
