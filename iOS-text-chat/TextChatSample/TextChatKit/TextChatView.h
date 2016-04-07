//
//  TextChatComponentChatView.h
//  TextChatComponent
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextChatView : UIView

@property (readonly, nonatomic) BOOL isViewAttached;

+ (instancetype)textChatView;

+ (instancetype)textChatViewWithBottomView:(UIView *)bottomView;

- (void)showTextChatView;

@end
