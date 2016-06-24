#import "MainView.h"
#import "MainViewController.h"
#import <OTTextChatKit/OTTextChatKit.h>
#import "SVProgressHUD.h"
#import "OneToOneCommunicator.h"

@interface MainViewController ()
@property (nonatomic) MainView *mainView;
@property (nonatomic) OTTextChatView *textChatView;
@property (nonatomic) OneToOneCommunicator *oneToOneCommunicator;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mainView = (MainView *)self.view;
    self.oneToOneCommunicator = [OneToOneCommunicator oneToOneCommunicator];
    //self.textChatView = [TextChatView textChatViewWithBottomView:self.mainView.actionButtonsHolder];
    self.textChatView = [OTTextChatView textChatView];

    // optional config for set the max amount of character permited per message
    [self.textChatView setMaximumTextMessageLength:200];
    // optional to be able to set the Alias for show in the top bar and on the messages (Name of the sender)
    [self.textChatView setAlias:@"Tokboxer"];
}

/**
 * toggles the call start/end handles the color of the buttons
 */
- (IBAction)publisherCallButtonPressed:(UIButton *)sender {
    
    [SVProgressHUD show];
    
    if (!self.oneToOneCommunicator.isCallEnabled) {
        [self.mainView setTextChatHolderUserInteractionEnabled:YES];
        [self.textChatView connect];
        [self.oneToOneCommunicator connectWithHandler:^(OneToOneCommunicationSignal signal, NSError *error) {

            [SVProgressHUD dismiss];
            [self.mainView connectCallHolder:self.oneToOneCommunicator.isCallEnabled];
            if (!error) {
                [self handleCommunicationSignal:signal];
            }
        }];
        [self.mainView buttonsStatusSetter:YES];
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
        [self.mainView resetUIInterface];
    }
}

- (void)handleCommunicationSignal:(OneToOneCommunicationSignal)signal {


    switch (signal) {
        case OneToOneCommunicationSignalSessionDidConnect: {
            [self.mainView addPublisherView:self.oneToOneCommunicator.publisherView];
            break;
        }
        case OneToOneCommunicationSignalSessionDidDisconnect:{
            [self.mainView removePublisherView];
            [self.mainView removeSubscriberView];
            break;
        }
        case OneToOneCommunicationSignalSessionDidFail:{
            [SVProgressHUD dismiss];
            break;
        }
        case OneToOneCommunicationSignalSessionStreamCreated:{
            break;
        }
        case OneToOneCommunicationSignalSessionStreamDestroyed:{
            [self.mainView removeSubscriberView];
            break;
        }
        case OneToOneCommunicationSignalPublisherDidFail:{
            [SVProgressHUD showErrorWithStatus:@"Problem when publishing"];
            break;
        }
        case OneToOneCommunicationSignalSubscriberConnect:{
            [self.mainView addSubscribeView:self.oneToOneCommunicator.subscriberView];
            break;
        }
        case OneToOneCommunicationSignalSubscriberDidFail:{
            [SVProgressHUD showErrorWithStatus:@"Problem when subscribing"];
            break;
        }
        case OneToOneCommunicationSignalSubscriberVideoDisabled:{
            [self.mainView addPlaceHolderToSubscriberView];
            break;
        }
        case OneToOneCommunicationSignalSubscriberVideoEnabled:{
            [SVProgressHUD dismiss];
            [self.mainView addSubscribeView:self.oneToOneCommunicator.subscriberView];
            break;
        }
        case OneToOneCommunicationSignalSubscriberVideoDisableWarning:{
            [self.mainView addPlaceHolderToSubscriberView];
            self.oneToOneCommunicator.subscribeToVideo = NO;
            [SVProgressHUD showErrorWithStatus:@"Network connection is unstable."];
            break;
        }
        case OneToOneCommunicationSignalSubscriberVideoDisableWarningLifted:{
            [SVProgressHUD dismiss];
            [self.mainView addSubscribeView:self.oneToOneCommunicator.subscriberView];
            break;
        }

        default:
            break;
    }
}

/**
 * toggles the audio comming from the publisher
 */
- (IBAction)publisherAudioButtonPressed:(UIButton *)sender {

    [self.mainView mutePubliserhMic:self.oneToOneCommunicator.publishAudio];
    self.oneToOneCommunicator.publishAudio = !self.oneToOneCommunicator.publishAudio;
}

/**
 * toggles the video comming from the publisher
 */
- (IBAction)publisherVideoButtonPressed:(UIButton *)sender {

    if (self.oneToOneCommunicator.publishVideo) {
        [self.mainView removePublisherView];
        [self.mainView addPlaceHolderToPublisherView];
    }
    else {
        [self.mainView addPublisherView:self.oneToOneCommunicator.publisherView];
    }

    [self.mainView connectPubliserVideo:self.oneToOneCommunicator.publishVideo];
    self.oneToOneCommunicator.publishVideo = !self.oneToOneCommunicator.publishVideo;
}

/**
 * toggle the camera position (front camera) <=> (back camera)
 */
- (IBAction)publisherCameraButtonPressed:(UIButton *)sender {
    if (self.oneToOneCommunicator.cameraPosition == AVCaptureDevicePositionBack) {
        self.oneToOneCommunicator.cameraPosition = AVCaptureDevicePositionFront;
    }
    else {
        self.oneToOneCommunicator.cameraPosition = AVCaptureDevicePositionBack;
    }
}

/**
 * toggles the video comming from the subscriber
 */
- (IBAction)subscriberVideoButtonPressed:(UIButton *)sender {

    [self.mainView connectSubsciberVideo:self.oneToOneCommunicator.subscribeToVideo];
    self.oneToOneCommunicator.subscribeToVideo = !self.oneToOneCommunicator.subscribeToVideo;
}

/**
 * toggles the audio comming from the susbscriber
 */
- (IBAction)subscriberAudioButtonPressed:(UIButton *)sender {

    [self.mainView muteSubscriberMic:self.oneToOneCommunicator.subscribeToAudio];
    self.oneToOneCommunicator.subscribeToAudio = !self.oneToOneCommunicator.subscribeToAudio;
}
/**
 * action to handle the textchat to be attached into the main view, also add the listeners for show the keyboard
 * and set the title for the top bar in the text chat component
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
 * handles the event when the user does a touch to show and then hide the buttons for
 * subscriber actions within 7 seconds
*/
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.mainView showSubscriberControls:YES];
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
