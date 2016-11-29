//
//  TestOneToOneCommunicatorViewController.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "TestOneToOneCommunicatorViewController.h"
#import "AppDelegate.h"

@interface TestOneToOneCommunicatorViewController () <OTOneToOneCommunicatorDataSource>
@property (weak, nonatomic) IBOutlet UIView *subscriberView;
@property (weak, nonatomic) IBOutlet UIView *publisherView;
@property (nonatomic) OTOneToOneCommunicator *communicator;
@end

@implementation TestOneToOneCommunicatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.communicator = [[OTOneToOneCommunicator alloc] init];
    self.communicator.dataSource = self;
    [self startCall];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Options" style:UIBarButtonItemStylePlain target:self action:@selector(navigateToOtherViews)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.communicator disconnect];
}

- (void)startCall {
    [self.communicator connectWithHandler:^(OTOneToOneCommunicationSignal signal, NSError *error) {
        if (signal == OTPublisherCreated && !error) {
            self.communicator.publisherView.frame = self.publisherView.bounds;
            [self.publisherView addSubview:self.communicator.publisherView];
        }
        else if (signal == OTSubscriberDidConnect && !error) {
            self.communicator.subscriberView.frame = self.subscriberView.bounds;
            [self.subscriberView addSubview:self.communicator.subscriberView];
        }
    }];
}

- (void)navigateToOtherViews {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose an testing option"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"START/END CALL" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if (self.communicator.isCallEnabled) {
            [self.communicator disconnect];
        }
        else {
            [self startCall];
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"SWITCH PUBLISHER VIDEO ON/OFF" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        self.communicator.publishVideo = !self.communicator.publishVideo;
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"SWITCH SUBSCRIBER VIDEO ON/OFF" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        self.communicator.subscribeToVideo = !self.communicator.subscribeToVideo;
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - OTOneToOneCommunicatorDataSource
- (OTAcceleratorSession *)sessionOfOTOneToOneCommunicator:(OTOneToOneCommunicator *)oneToOneCommunicator {
    return [(AppDelegate*)[[UIApplication sharedApplication] delegate] getSharedAcceleratorSession];
}

@end
