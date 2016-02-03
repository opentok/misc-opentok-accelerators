//
//  ViewController.h
//  TextChatComponetSample
//
//  Created by Esteban Cordero on 1/31/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TextChatComponent/TextChatComponent.h>

@interface ViewController : UIViewController <TextChatComponentDelegate>

@property (strong) TextChatComponent *textChat;
@property (weak) IBOutlet UILabel *connectingLabel;

@end

