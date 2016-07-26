//
//  OTTextMessageManager.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTTextMessage.h"
#import "OTTextMessage_Private.h"
#import "OTTextChatView.h"

/**
 *  A delegate of an OTTextMessageManager object must conform the TextMessageManagerDelegate protocol.
 *  Methods of the protocol allow the delegate to provide notifications of the connectivity and status of the message.
 */
@protocol TextMessageManagerDelegate <NSObject>

/**
 *  Notifies the delegate that text chat manager has established a connection, with or without an error.
 *
 *  @param error Localizes error description, if one exists.
 */
- (void)didConnectWithError:(NSError *)error;

/**
 *  Notifies the delegate that text chat manager has stopped the connection, with or without an error.
 *
 *  @param error Localized error description, if one exists.
 */
- (void)didDisConnectWithError:(NSError *)error;

/**
 *  Notifies the delegate that text chat was added to the project, with or without an error.
 *
 *  @param textChat Text chat object.
 *  @param error    Localized error description, if one exists.
 */
- (void)didAddTextChat:(OTTextMessage *)textChat error:(NSError *)error;

/**
 *  Notifies the delegate that the text chat manager finished receiving the message.
 *
 *  @param textChat Contains all data related to the message.
 */
- (void)didReceiveTextChat:(OTTextMessage *)textChat;
@end

// Analytics constants 
extern NSString* const kLogComponentIdentifier;
extern NSString* const KLogClientVersion;
extern NSString* const KLogActionInitialize;
extern NSString* const KLogActionOpen;
extern NSString* const KLogActionClose;
extern NSString* const KLogActionSendMessage;
extern NSString* const KLogActionReceiveMessage;
extern NSString* const KLogVariationAttempt;
extern NSString* const KLogVariationSuccess;
extern NSString* const KLogVariationFailure;

@interface OTTextMessageManager : NSObject

/**
*  The object that acts as the delegate of the text chat manager.
*
*  The delegate must adopt the TextMessageManagerDelegate protocol. The delegate is not retained.
*/
@property (weak, nonatomic) id<TextMessageManagerDelegate> delegate;

/**
 *  The complete array of messages sent and received in the current session.
 */
@property (readonly, nonatomic) NSArray<OTTextMessage *> *messages;
@property (readonly, nonatomic) NSString *alias;
@property (readonly, nonatomic) NSString *receiverAlias;
@property (nonatomic) NSUInteger maximumTextMessageLength;

/**
 *  Initiates the connection with OpenTok.
 */
- (void)connect;

/**
 *  Disconnects from the OpenTok session.
 */
- (void)disconnect;

/**
 *  Perform the send message action, sending all the data as a signal.
 *
 *  @param message The text data for the current message.
 */
- (void)sendMessage:(NSString *)message;

/**
 *  Get the specified message.
 *
 *  @param indexPath The array index for the message to be retrieved.
 *
 *  @return The message contained at the specified index.
 */
- (OTTextMessage *)getTextChatFromIndexPath:(NSIndexPath *)indexPath;

- (void)setAlias:(NSString *)alias;

@end
