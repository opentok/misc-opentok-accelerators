//
//  TextChatComponentChatView.h
//  TextChatComponent
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextChat.h"

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


@interface TextChatView : UIView


@property (weak, nonatomic) IBOutlet UITableView *tableView;

-(void)disableAnchorToBottom;

-(void)anchorToBottom;

-(void)anchorToBottomAnimated:(BOOL)animated;

-(BOOL)isAnchoredToBottom;

-(BOOL)isAtBottom;

/**
 * Add a message to the TextChatListener received message list.
 *
 * @param message The message to send.
 */
- (BOOL)addMessage:(TextChat *)message;

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

+ (instancetype)textChatView;
@end
