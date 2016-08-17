//
//  TestOneToOneCommunicatorViewController.m
//  OTAcceleratorPackUtilProject
//
//  Created by Xi Huang on 7/11/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "TestOneToOneCommunicatorViewController.h"
#import <OTAcceleratorPackUtil/OTAcceleratorPackUtil.h>

@interface TestOneToOneCommunicatorViewController () <OTOneToOneCommunicatorDelegate>
@property (weak, nonatomic) IBOutlet UIView *subscriberView;
@property (weak, nonatomic) IBOutlet UIView *publisherView;
@property (nonatomic) OTOneToOneCommunicator *communicator;
@end

@implementation TestOneToOneCommunicatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.communicator = [OTOneToOneCommunicator sharedInstance];
    self.communicator.delegate = self;
    [self.communicator connect];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"TestReset" style:UIBarButtonItemStylePlain target:self action:@selector(testResetButtonPressed)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)oneToOneCommunicationWithSignal:(OTOneToOneCommunicationSignal)signal
                                  error:(NSError *)error {
    
    if (signal == OTSessionDidConnect) {
        self.communicator.publisherView.frame = self.publisherView.bounds;
        [self.publisherView addSubview:self.communicator.publisherView];
    }
    else if (signal == OTSubscriberConnect) {
        self.communicator.subscriberView.frame = self.subscriberView.bounds;
        [self.subscriberView addSubview:self.communicator.subscriberView];
    }
}

- (void)testResetButtonPressed {
    
    // the behavior here should be: force the session to disconnect
    [OTOneToOneCommunicator setOpenTokApiKey:@"testResetButtonPressed" sessionId:@"testResetButtonPressed" token:@"testResetButtonPressed"];
}

@end
