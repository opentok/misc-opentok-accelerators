//
//  TextChatComponentChatView.h
//  TextChatComponent
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TextChatView;
@protocol TextChatViewDelegate <NSObject>
- (void)textChatViewDidSendMessage:(TextChatView *)textChatView
                             error:(NSError *)error;
@end

@interface TextChatView : UIView

@property (weak, nonatomic) id<TextChatViewDelegate> delegate;

@property (readonly, nonatomic) BOOL isViewAttached;

+ (instancetype)textChatView;

+ (instancetype)textChatViewWithBottomView:(UIView *)bottomView;

- (void)minimize;

- (void)maximize;

- (void)show;

- (void)dismiss;

@end