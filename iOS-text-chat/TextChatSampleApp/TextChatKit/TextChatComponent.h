//
//  TextChatComponent.h
//  TextChatComponent
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TextChat;

/**
 * A delegate for receiving events when a text chat message is ready to send.
 */
@protocol TextChatComponentDelegate <NSObject>

/**
 * Called when a message in the TextChatComponent is ready to send. A message
 * is ready to send when the user clicks the Send button in the
 * IMComponentComponent user interface.
 */
- (BOOL)onMessageReadyToSend:(TextChat *)message;

@end

/**
 * A controller for the OpenTok iOS Text Chat UI widget.
 */
@interface TextChatComponent : NSObject <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

/**
 * The view containing the TextChatComponent user interface.
 */
@property (nonatomic, strong) UIView * view;

/**
 * Set to the delegate object that receives events for this TextChatComponent.
 */
@property (nonatomic, weak) id<TextChatComponentDelegate> delegate;

/**
 * Add a message to the TextChatListener received message list.
 *
 * @param message The message to send.
 */
- (BOOL)addMessage:(TextChat *)message;

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

/**
 * Set the participants of the chat
 *
 * @param title, the string with the name of the participants
 */
-(void) setTitleToTopBar: (NSMutableDictionary *)title;

@end
