//
//  TextChatComponentChatView.h
//  TextChatComponent
//
//  Created by Xi Huang on 2/23/16.
//  Copyright © 2016 Tokbox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TextChatView;
@protocol TextChatViewDelegate <NSObject>
- (void)textChatViewDidSendMessage:(TextChatView *)textChatView
                             error:(NSError *)error;
- (void)textChatViewDidReceiveMessage:(TextChatView *)textChatView;

@optional
- (void)didConnectWithError:(NSError *)error;
- (void)didDisConnectWithError:(NSError *)error;
@end

@interface TextChatView : UIView

+ (void)setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token;

@property (weak, nonatomic) id<TextChatViewDelegate> delegate;

@property (readonly, nonatomic) BOOL isShown;

+ (instancetype)textChatView;

+ (instancetype)textChatViewWithBottomView:(UIView *)bottomView;

- (void)connect;

- (void)disconnect;

- (void)minimize;

- (void)maximize;

- (void)show;

- (void)dismiss;

- (void)setAlias:(NSString *)alias;

- (void)setMaximumTextMessageLength:(NSUInteger)length;

@end