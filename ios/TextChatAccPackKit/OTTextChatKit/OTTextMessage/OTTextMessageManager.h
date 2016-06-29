//
//  TextChatComponent.h
//  TextChatComponent
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTTextMessage.h"
#import "OTTextMessage_Private.h"
#import "OTTextChatView.h"

@protocol TextMessageManagerDelegate <NSObject>
- (void)didConnectWithError:(NSError *)error;
- (void)didDisConnectWithError:(NSError *)error;
- (void)didAddTextChat:(OTTextMessage *)textChat error:(NSError *)error;
- (void)didReceiveTextChat:(OTTextMessage *)textChat;
@end

//analytics
extern NSString* const kLogComponentIdentifier;
extern NSString* const KLogClientVersion;
extern NSString* const KLogActionInitialize;
extern NSString* const KLogActionSendMessage;
extern NSString* const KLogActionReceiveMessage;
extern NSString* const KLogVariationAttempt;
extern NSString* const KLogVariationSuccess;
extern NSString* const KLogVariationFailure;

@interface OTTextMessageManager : NSObject
@property (weak, nonatomic) id<TextMessageManagerDelegate> delegate;

@property (readonly, nonatomic) NSArray<OTTextMessage *> *messages;
@property (readonly, nonatomic) NSString *alias;
@property (readonly, nonatomic) NSString *receiverAlias;
@property (readonly, nonatomic) NSUInteger maximumTextMessageLength;

- (void)connect;

- (void)disconnect;

- (void)sendMessage:(NSString *)message;

- (OTTextMessage *)getTextChatFromIndexPath:(NSIndexPath *)indexPath;

- (void)setAlias:(NSString *)alias;

- (void)setMaximumTextMessageLength:(NSUInteger)maximumTextMessageLength;

@end
