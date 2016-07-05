//
//  OTTextChatUICustomizator.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTTextChatUICustomizator : NSObject

/**
 *  Custom color for the send message text.
 */
@property (nonatomic) UIColor *tableViewCellSendTextColor;
/**
 *  Custom color for the received message text.
 */
@property (nonatomic) UIColor *tableViewCellReceiveTextColor;
/**
 *  Custom background color for the send message.
 */
@property (nonatomic) UIColor *tableViewCellSendBackgroundColor;
/**
 *  Custom background color for the received message.
 */
@property (nonatomic) UIColor *tableViewCellReceiveBackgroundColor;
/**
 *  Custom color for the background color of the top bar of the text chat.
 */
@property (nonatomic) UIColor *topBarBackgroundColor;
/**
 *  Custom color for the text title in the top bar of the text chat.
 */
@property (nonatomic) UIColor *topBarTitleTextColor;

@end
