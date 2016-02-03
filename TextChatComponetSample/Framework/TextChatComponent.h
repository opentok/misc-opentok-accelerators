//
//  TextChatComponent.h
//  TextChatComponent
//
//  Created by Esteban Cordero on 1/28/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * Defines the chat message object that you pass into the
 * <[TextChatComponent addMessage:]> method.
 */

@interface TextChatComponentMessage : NSObject

/**
 * The sender alias for the message.
 */
@property (nonatomic, copy) NSString *senderAlias;
/**
 * The unique ID of the sender.
 */
@property (nonatomic, copy) NSString *senderId;
/**
 * The text of the message.
 */
@property (nonatomic, copy) NSString *text;
/**
 * The timestamp for the message.
 */
@property (nonatomic, copy) NSDate *dateTime;

@end

/**
 * A delegate for receiving events when a text chat message is ready to send.
 */
@protocol TextChatComponentDelegate <NSObject>

/**
 * Called when a message in the TextChatComponent is ready to send. A message
 * is ready to send when the user clicks the Send button in the
 * IMComponentComponent user interface.
 */
- (BOOL)onMessageReadyToSend:(TextChatComponentMessage *)message;

@end

/**
 * A controller for the OpenTok iOS Text Chat UI widget.
 */
@interface TextChatComponent : NSObject <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

/**
 * The view containing the TextChatComponent user interface.
 */
@property (nonatomic, strong) IBOutlet UIView * view;

/**
 * Set to the delegate object that receives events for this TextChatComponent.
 */
@property (nonatomic, weak) id<TextChatComponentDelegate> delegate;

/**
 * Add a message to the TextChatListener received message list.
 *
 * @param message The message to send.
 */
- (BOOL)addMessage:(TextChatComponentMessage *)message;

/**
 * Set the maximum length of a text chat message.
 *
 * @param length The maximum length for a message.
 */
- (void)setMaxLength:(int) length;

/**
 * Set the sender ID and the sender alias of the output messages.
 *
 * @param senderId The unique ID for the sender. The TextChatComponent uses this ID
 * to group messages from the same sender in the user interface.
 *
 * @param alias The string (alias) identifying the sender of the message.
 */
- (void)setSenderId:(NSString *)senderId alias:(NSString *)alias;

@end
