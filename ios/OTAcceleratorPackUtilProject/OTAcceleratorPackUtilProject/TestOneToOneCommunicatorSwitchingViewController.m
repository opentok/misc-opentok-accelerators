//
//  TestOneToOneCommunicatorSwitchingViewController.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "TestOneToOneCommunicatorSwitchingViewController.h"
#import <OTAcceleratorPackUtil/OTAcceleratorPackUtil.h>

@interface TestOneToOneCommunicatorSwitchingViewController()<OTOneToOneCommunicatorDelegate>
@property (weak, nonatomic) IBOutlet UIView *subscriberView;
@property (weak, nonatomic) IBOutlet UIView *publisherView;
@property (nonatomic) OTOneToOneCommunicator *communicator;
@end

@implementation TestOneToOneCommunicatorSwitchingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.communicator = [OTOneToOneCommunicator sharedInstance];
    self.communicator.delegate = self;
    [self.communicator connect];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Switch" style:UIBarButtonItemStylePlain target:self action:@selector(switchButtonPressed)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.communicator disconnect];
}

- (void)oneToOneCommunicationWithSignal:(OTOneToOneCommunicationSignal)signal
                                  error:(NSError *)error {
    
    if (signal == OTSessionDidConnect && !error) {
        self.communicator.publisherView.frame = self.publisherView.bounds;
        [self.publisherView addSubview:self.communicator.publisherView];
    }
    else if (signal == OTSubscriberDidConnect && !error) {
        self.communicator.subscriberView.frame = self.subscriberView.bounds;
        [self.subscriberView addSubview:self.communicator.subscriberView];
    }
}

- (void)switchButtonPressed {
    // please specify anotherTokboxer to test it
    [self.communicator subscribeToStreamWithName:@"anotherTokboxer"];
}

@end
