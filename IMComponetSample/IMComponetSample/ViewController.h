//
//  ViewController.h
//  IMComponetSample
//
//  Created by Esteban Cordero on 1/31/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IMComponent/IMComponent.h>

@interface ViewController : UIViewController <IMComponentDelegate>

@property (strong) IMComponent *textChat;
@property (weak) IBOutlet UILabel *connectingLabel;

@end

