//
//  IMComponentChatView.h
//  IMComponent
//
//  Created by Esteban Cordero on 1/28/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMComponentChatView : UIView

@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UILabel *countLabel;
@property (nonatomic, weak) IBOutlet UIButton *errorMessage;
@property (nonatomic, weak) IBOutlet UIButton *messageBanner;

-(void)disableAnchorToBottom;

-(void)anchorToBottom;

-(void)anchorToBottomAnimated:(BOOL)animated;

-(BOOL)isAnchoredToBottom;

-(BOOL)isAtBottom;

@end
