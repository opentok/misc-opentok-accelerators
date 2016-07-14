//
// MainViewController.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "MainView.h"
#import "MainViewController.h"
#import <OTTextChatKit/OTTextChatKit.h>
#import "SVProgressHUD.h"
#import <OTAcceleratorPackUtil/OTOneToOneCommunicator.h>

@interface MainViewController ()
@property (nonatomic) MainView *mainView;
@property (nonatomic) OTTextChatView *textChatView;
@property (nonatomic) OTOneToOneCommunicator *oneToOneCommunicator;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mainView = (MainView *)self.view;
    self.oneToOneCommunicator = [OTOneToOneCommunicator communicator];
    //self.textChatView = [TextChatView textChatViewWithBottomView:self.mainView.actionButtonsHolder];
    self.textChatView = [OTTextChatView textChatView];

    // optional config for set the max amount of character permited per message
    [self.textChatView setMaximumTextMessageLength:200];
    // optional to be able to set the Alias for show in the top bar and on the messages (Name of the sender)
    [self.textChatView setAlias:@"Tokboxer"];
#if !(TARGET_OS_SIMULATOR)
    [self.mainView showReverseCameraButton];
#endif
}

- (IBAction)publisherCallButtonPressed:(UIButton *)sender {
    
    [SVProgressHUD show];
    
    if (!self.oneToOneCommunicator.isCallEnabled) {
        [self.oneToOneCommunicator connectWithHandler:^(OTOneToOneCommunicationSignal signal, NSError *error) {
            if (!error) {
                [SVProgressHUD dismiss];
                [self.mainView setTextChatHolderUserInteractionEnabled:YES];
                [self.textChatView connect];
                [self.mainView connectCallHolder:self.oneToOneCommunicator.isCallEnabled];
                [self.mainView updateControlButtonsForCall:YES];
                [self handleCommunicationSignal:signal];
            }
            else {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }
        }];
    }
    else {

        [SVProgressHUD dismiss];
        [self.oneToOneCommunicator disconnect];
        [self.textChatView disconnect];
        [self.mainView connectCallHolder:self.oneToOneCommunicator.isCallEnabled];
        [self.textChatView dismiss];
        
        [self.mainView removePublisherView];
        [self.mainView removePlaceHolderImage];
        [self.mainView setTextChatHolderUserInteractionEnabled:NO];
        [self.mainView updateControlButtonsForCall:NO];
        [self.mainView resetUIInterface];
    }
}

- (void)handleCommunicationSignal:(OTOneToOneCommunicationSignal)signal {

    switch (signal) {
        case OTSessionDidConnect: {
            [self.mainView addPublisherView:self.oneToOneCommunicator.publisherView];
            break;
        }
        case OTSessionDidDisconnect:{
            [self.mainView removePublisherView];
            [self.mainView removeSubscriberView];
            break;
        }
        case OTSessionDidFail:{
            [SVProgressHUD dismiss];
            break;
        }
        case OTSessionStreamCreated:{
            break;
        }
        case OTSessionStreamDestroyed:{
            [self.mainView removeSubscriberView];
            break;
        }
        case OTPublisherDidFail:{
            [SVProgressHUD showErrorWithStatus:@"Problem when publishing"];
            break;
        }
        case OTSubscriberConnect:{
            [self.mainView addSubscribeView:self.oneToOneCommunicator.subscriberView];
            break;
        }
        case OTSubscriberDidFail:{
            [SVProgressHUD showErrorWithStatus:@"Problem when subscribing"];
            break;
        }
        case OTSubscriberVideoDisabled:{
            [self.mainView addPlaceHolderToSubscriberView];
            break;
        }
        case OTSubscriberVideoEnabled:{
            [SVProgressHUD dismiss];
            [self.mainView addSubscribeView:self.oneToOneCommunicator.subscriberView];
            break;
        }
        case OTSubscriberVideoDisableWarning:{
            [self.mainView addPlaceHolderToSubscriberView];
            self.oneToOneCommunicator.subscribeToVideo = NO;
            [SVProgressHUD showErrorWithStatus:@"Network connection is unstable."];
            break;
        }
        case OTSubscriberVideoDisableWarningLifted:{
            [SVProgressHUD dismiss];
            [self.mainView addSubscribeView:self.oneToOneCommunicator.subscriberView];
            break;
        }

        default:
            break;
    }
}

- (IBAction)publisherAudioButtonPressed:(UIButton *)sender {
    self.oneToOneCommunicator.publishAudio = !self.oneToOneCommunicator.publishAudio;
    [self.mainView mutePubliserhMic:self.oneToOneCommunicator.publishAudio];
}

- (IBAction)publisherVideoButtonPressed:(UIButton *)sender {
    self.oneToOneCommunicator.publishVideo = !self.oneToOneCommunicator.publishVideo;
    if (self.oneToOneCommunicator.publishVideo) {
        [self.mainView addPublisherView:self.oneToOneCommunicator.publisherView];
    }
    else {
        [self.mainView removePublisherView];
        [self.mainView addPlaceHolderToPublisherView];
    }
    [self.mainView connectPubliserVideo:self.oneToOneCommunicator.publishVideo];
}

- (IBAction)publisherCameraButtonPressed:(UIButton *)sender {
    if (self.oneToOneCommunicator.cameraPosition == AVCaptureDevicePositionBack) {
        self.oneToOneCommunicator.cameraPosition = AVCaptureDevicePositionFront;
    }
    else {
        self.oneToOneCommunicator.cameraPosition = AVCaptureDevicePositionBack;
    }
}

- (IBAction)subscriberVideoButtonPressed:(UIButton *)sender {
    self.oneToOneCommunicator.subscribeToVideo = !self.oneToOneCommunicator.subscribeToVideo;
    [self.mainView connectSubsciberVideo:self.oneToOneCommunicator.subscribeToVideo];
}

- (IBAction)subscriberAudioButtonPressed:(UIButton *)sender {
    self.oneToOneCommunicator.subscribeToAudio = !self.oneToOneCommunicator.subscribeToAudio;
    [self.mainView muteSubscriberMic:self.oneToOneCommunicator.subscribeToAudio];
}

/**
 * Action to handle the textchat to be attached to the main view. Also adds the listeners for displaying the keyboard
 * and setting the title for the top bar in the text chat component.
 */
- (IBAction)textChatButtonPressed:(UIButton *)sender {
    
    if (!self.textChatView.isShown) {
        [self.textChatView show];
    }
    // OPTIONAL COLOR CHANGING 
    // [TextChatUICustomizator setTableViewCellSendBackgroundColor:[UIColor orangeColor]];
    // [TextChatUICustomizator setTableViewCellReceiveBackgroundColor:[UIColor yellowColor]];
}

/**
 * Handles the event, within 7 seconds, when the user performs a touch action to show and then hide the buttons for
 * subscriber actions.
*/
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.oneToOneCommunicator.subscriberView){
        [self.mainView showSubscriberControls:YES];
    }
    [self.mainView performSelector:@selector(showSubscriberControls:)
                        withObject:nil
                        afterDelay:7.0];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
