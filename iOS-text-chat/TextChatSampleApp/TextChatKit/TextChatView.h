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

// top view
@property (weak, nonatomic) IBOutlet UIView *textChatTopView;
@property (weak, nonatomic) IBOutlet UILabel *textChatTopViewTitle;
@property (weak, nonatomic) IBOutlet UIButton *minimizeButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

// input view
@property (weak, nonatomic) IBOutlet UIView *textChatInputView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

// other UIs
@property (weak, nonatomic) IBOutlet UIButton *errorMessage;
@property (weak, nonatomic) IBOutlet UIButton *messageBanner;

-(void)disableAnchorToBottom;

-(void)anchorToBottom;

-(void)anchorToBottomAnimated:(BOOL)animated;

-(BOOL)isAnchoredToBottom;

-(BOOL)isAtBottom;


#warning temp
/**
 * The view containing the TextChatComponent user interface.
 */
//@property (nonatomic, strong) UIView * view;

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
