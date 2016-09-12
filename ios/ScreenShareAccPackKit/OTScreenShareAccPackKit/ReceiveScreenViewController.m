//
//  ReceiveScreenViewController.m
//  OTScreenShareAccPackKit
//
//  Created by Xi Huang on 9/11/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "ReceiveScreenViewController.h"
#import <OTScreenShareKit/OTScreenShareKit.h>

@interface ReceiveScreenViewController ()
@property (nonatomic) OTScreenSharer *screenSharer;
@end

@implementation ReceiveScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *previewBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Navigate" style:UIBarButtonItemStylePlain target:self action:@selector(navigateToOtherViews)];
    self.navigationItem.rightBarButtonItem = previewBarButtonItem;
    
    self.screenSharer = [OTScreenSharer sharedInstance];
    [self.screenSharer connectWithView:nil
                         handler:^(OTScreenShareSignal signal, NSError *error) {
                             
                             if (!error) {
                                 
                                 if (signal == OTScreenShareSignalSessionDidConnect) {
                                     self.screenSharer.publishAudio = NO;
                                     self.screenSharer.subscribeToAudio = NO;
                                 }
                                 else if (signal == OTScreenShareSignalSubscriberConnect) {
                                     
                                     [self.screenSharer.subscriberView removeFromSuperview];
                                     self.screenSharer.subscriberView.frame = self.view.bounds;
                                     [self.view insertSubview:self.screenSharer.subscriberView atIndex:0];
                                 }
                             }
                         }];
}

- (void)navigateToOtherViews {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"MAKE FIT/FILL SCREEN" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if (self.screenSharer.isScreenSharing) {
            
            if (self.screenSharer.subscriberVideoContentMode == OTScreenShareVideoViewFit) {
                self.screenSharer.subscriberVideoContentMode = OTScreenShareVideoViewFill;
            }
            else {
                self.screenSharer.subscriberVideoContentMode = OTScreenShareVideoViewFit;
            }
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
