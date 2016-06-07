//
//  ViewController.m
//  ScreenShareSample
//
//  Created by Xi Huang on 4/26/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//
#import <ScreenShareKit/ScreenShareKit.h>
#import "ViewController.h"
#import "OneToOneCommunicator.h"

@interface ViewController () <UIScrollViewDelegate>
@property (nonatomic) ScreenShareToolbarView *toolbarView;

@property (nonatomic) ScreenCapture *screenShare;
@property (nonatomic) ScreenCaptureHandler *screenCaptureHandler;
@property (nonatomic) OneToOneCommunicator *oneToOneCommunicator;

@property (strong, nonatomic) IBOutlet UIView *publisherView;
@property (strong, nonatomic) IBOutlet UIView *subscriberView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // tool bar
    self.toolbarView = [ScreenShareToolbarView toolbar];
    self.screenCaptureHandler = [ScreenCaptureHandler screenCaptureHandler];
    self.oneToOneCommunicator = [OneToOneCommunicator oneToOneCommunicator];
    
//    // screen share view
//    UIImage *image = [UIImage imageNamed:@"mvc"];
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
//    [self.toolbarView.screenShareView addContentView:imageView];
//    
//    [self.view addSubview:self.toolbarView.screenShareView];
//    [self.view addSubview:self.toolbarView];
    
}

/**
 *  toggles the screen share of the current content of the screen
 */
- (IBAction)ScreenShareButtonPressed:(UIButton *)sender {
    self.screenShare = [[ScreenCapture alloc] initWithView: self.view];
    if (!self.screenCaptureHandler.isScreenSharing){
        [self.screenCaptureHandler setScreenCaptureSource: self.screenShare];
    } else {
        [self.screenCaptureHandler removeVideoSourceScreenShare];
    }
}

- (IBAction)startCall:(id)sender {
    [self.oneToOneCommunicator connectWithHandler:^(OneToOneCommunicationSignal signal, NSError *error) {

        if (!error) {
            [self handleCommunicationSignal:signal];
        }
    }];

}

- (IBAction)endCall:(id)sender {
    [self.oneToOneCommunicator disconnect];
    [self.screenCaptureHandler removeVideoSourceScreenShare];

    [self removePublisherView];
    [self removeSubscriberView];
}

- (void)handleCommunicationSignal:(OneToOneCommunicationSignal)signal {
    switch (signal) {
        case OneToOneCommunicationSignalSessionDidConnect: {
            [self addPublisherView:self.oneToOneCommunicator.publisherView];
            break;
        }
        case OneToOneCommunicationSignalSessionDidDisconnect:{
            [self removePublisherView];
            [self removeSubscriberView];
            [self.screenCaptureHandler removeVideoSourceScreenShare];
            break;
        }
        case OneToOneCommunicationSignalSessionDidFail:{
            break;
        }
        case OneToOneCommunicationSignalSessionStreamCreated:{
            if ([[self.screenCaptureHandler getSessionStreams] count] == 0){
                [self removeSubscriberView];
                [self addPublisherView:self.oneToOneCommunicator.publisherView];
            }
            break;
        }
        case OneToOneCommunicationSignalSessionStreamDestroyed:{
            [self removeSubscriberView];
            break;
        }
        case OneToOneCommunicationSignalPublisherDidFail:{
            break;
        }
        case OneToOneCommunicationSignalSubscriberConnect:{
            if([self.subscriberView.subviews count] == 0){
                [self addSubscribeView:self.oneToOneCommunicator.subscriberView];
            }
            break;
        }
        case OneToOneCommunicationSignalSubscriberDidFail:{
            break;
        }
        case OneToOneCommunicationSignalSubscriberVideoDisabled:{
            break;
        }
        case OneToOneCommunicationSignalSubscriberVideoEnabled:{
            break;
        }
        case OneToOneCommunicationSignalSubscriberVideoDisableWarning:{
            self.oneToOneCommunicator.subscribeToVideo = NO;
            break;
        }
        case OneToOneCommunicationSignalSubscriberVideoDisableWarningLifted:{
            [self addSubscribeView:self.oneToOneCommunicator.subscriberView];
            break;
        }

        default:
            break;
    }
}

#pragma mark - publisher view
- (void)addPublisherView:(UIView *)publisherView {

    [self.publisherView setHidden:NO];
    publisherView.frame = CGRectMake(0, 0, CGRectGetWidth(self.publisherView.bounds), CGRectGetHeight(self.publisherView.bounds));
    [self.publisherView addSubview:publisherView];
}

- (void)removePublisherView {
    [self.publisherView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

#pragma mark - subscriber view
- (void)addSubscribeView:(UIView *)subsciberView {
    
    subsciberView.frame = CGRectMake(0, 0, CGRectGetWidth(self.subscriberView.bounds), CGRectGetHeight(self.subscriberView.bounds));
    [self.subscriberView addSubview:subsciberView];
}

- (void)removeSubscriberView {
    [self.subscriberView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end