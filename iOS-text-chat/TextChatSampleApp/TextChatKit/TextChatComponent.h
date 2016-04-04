//
//  TextChatComponent.h
//  TextChatComponent
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "TextChat.h"


@interface TextChatComponent : NSObject <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableDictionary *senders;
@property (strong, nonatomic) NSString *senderId;
@property (strong, nonatomic) NSString *alias;

@end
