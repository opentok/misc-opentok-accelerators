//
//  ViewController.h
//  TextChatSampleApp
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TextChatKit/TextChatComponent.h>

@interface ViewController : UIViewController <TextChatComponentDelegate>

@property (strong) TextChatComponent *textChat;
@property (strong, nonatomic) IBOutlet UILabel *connectingLabel;

@end

