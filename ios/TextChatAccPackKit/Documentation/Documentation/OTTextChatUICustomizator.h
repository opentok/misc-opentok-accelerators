//
//  OTTextChatUICustomizator.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTTextChatUICustomizator : NSObject

/**
 *  Customize the color for the send message text.
 */
@property (nonatomic) UIColor *tableViewCellSendTextColor;
/**
 *  Customize the color for the received message text.
 */
@property (nonatomic) UIColor *tableViewCellReceiveTextColor;
/**
 *  Customize the background color for the send message.
 */
@property (nonatomic) UIColor *tableViewCellSendBackgroundColor;
/**
 *  Customize the background color for the received message.
 */
@property (nonatomic) UIColor *tableViewCellReceiveBackgroundColor;
/**
 *  Customize the color for the background color of the top bar of the text chat.
 */
@property (nonatomic) UIColor *topBarBackgroundColor;
/**
 *  Customize the color for the text title in the top bar of the text chat.
 */
@property (nonatomic) UIColor *topBarTitleTextColor;

@end
