//
//  ReceiveScreenViewController.m
//  OTScreenShareAccPackKit
//
//  Created by Xi Huang on 9/11/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "ReceiveScreenViewController.h"
#import "AppDelegate.h"
#import "OTScreenSharer.h"

@interface ReceiveScreenViewController () <OTScreenShareDataSource>
@property (nonatomic) OTScreenSharer *screenSharer;
@end

@implementation ReceiveScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *previewBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Navigate" style:UIBarButtonItemStylePlain target:self action:@selector(navigateToOtherViews)];
    self.navigationItem.rightBarButtonItem = previewBarButtonItem;
    
    self.screenSharer = [[OTScreenSharer alloc] init];
    self.screenSharer.dataSource = self;
    [self.screenSharer connectWithView:nil
                         handler:^(OTCommunicationSignal signal, NSError *error) {
                             
                             if (!error) {
                                 
                                 if (signal == OTPublisherCreated) {
                                     self.screenSharer.publishAudio = NO;
                                     self.screenSharer.subscribeToAudio = NO;
                                 }
                                 else if (signal == OTSubscriberReady) {
                                     
                                     [self.screenSharer.subscriberView removeFromSuperview];
                                     self.screenSharer.subscriberView.frame = self.view.bounds;
                                     [self.view insertSubview:self.screenSharer.subscriberView atIndex:0];
                                 }
                             }
                         }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.screenSharer disconnect];
}

- (void)navigateToOtherViews {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"MAKE FIT/FILL SCREEN" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if (self.screenSharer.isScreenSharing) {
            
            if (self.screenSharer.subscriberVideoContentMode == OTVideoViewFit) {
                self.screenSharer.subscriberVideoContentMode = OTVideoViewFill;
            }
            else {
                self.screenSharer.subscriberVideoContentMode = OTVideoViewFit;
            }
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (OTAcceleratorSession *)sessionOfOTScreenSharer:(OTScreenSharer *)screenSharer {
    return [(AppDelegate*)[[UIApplication sharedApplication] delegate] getSharedAcceleratorSession];
}

@end
