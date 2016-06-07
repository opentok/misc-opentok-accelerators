//
//  TextChatComponent.h
//  TextChatComponent
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import "TextMessage.h"
#import "TextMessage_Private.h"
#import "TextChatView.h"
#import "OTKAnalytics.h"

@protocol TextMessageManagerDelegate <NSObject>
- (void)didConnectWithError:(NSError *)error;
- (void)didDisConnectWithError:(NSError *)error;
- (void)didAddTextChat:(TextMessage *)textChat error:(NSError *)error;
- (void)didReceiveTextChat:(TextMessage *)textChat;
@end

//analytics
extern NSString* const KLogSource;
extern NSString* const KLogClientVersion;
extern NSString* const KLogActionInitialize;
extern NSString* const KLogActionSendMessage;
extern NSString* const KLogActionReceiveMessage;
extern NSString* const KLogActionMaxLength;
extern NSString* const KLogActionSenderAlias;
extern NSString* const KLogActionMinimize;
extern NSString* const KLogActionMaximize;
extern NSString* const KLogActionClose;
extern NSString* const KLogVariationAttempt;
extern NSString* const KLogVariationSuccess;
extern NSString* const KLogVariationFailure;

@interface TextMessageManager : NSObject
@property (weak, nonatomic) id<TextMessageManagerDelegate> delegate;

@property (readonly, nonatomic) NSArray<TextMessage *> *messages;
@property (readonly, nonatomic) NSString *alias;
@property (readonly, nonatomic) NSString *receiverAlias;
@property (readonly, nonatomic) NSUInteger maximumTextMessageLength;
@property (readonly, nonatomic) OTKAnalytics *analytics;

- (void)connect;

- (void)disconnect;

- (void)sendMessage:(NSString *)message;

- (TextMessage *)getTextChatFromIndexPath:(NSIndexPath *)indexPath;

- (void)setAlias:(NSString *)alias;

- (void)setMaximumTextMessageLength:(NSUInteger)maximumTextMessageLength;

- (void)addLogEvent:(NSString*)action variation:(NSString*)variation; //for internal use

@end
