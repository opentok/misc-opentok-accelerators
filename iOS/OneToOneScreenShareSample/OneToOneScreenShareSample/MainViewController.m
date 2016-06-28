//
//  ViewController.m
//  OneToOneScreenShareSample
//
//  Created by Xi Huang on 5/23/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "MainView.h"
#import "MainViewController.h"
#import "OneToOneCommunicator.h"

#import <SVProgressHUD/SVProgressHUD.h>

@interface MainViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic) MainView *mainView;
@property (nonatomic) OneToOneCommunicator *oneToOneCommunicator;
@property (nonatomic) ScreenSharer *screenSharer;

@property (nonatomic) UIView *customSharedContent;
@property (nonatomic) UIImagePickerController *imagePickerViewContoller;
@property (nonatomic) UIAlertController *screenShareMenuAlertController;
@end

@implementation MainViewController

- (UIImagePickerController *)imagePickerViewContoller {
    if (!_imagePickerViewContoller) {
        _imagePickerViewContoller = [[UIImagePickerController alloc] init];
        _imagePickerViewContoller.delegate = self;
        _imagePickerViewContoller.allowsEditing = YES;
        _imagePickerViewContoller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    return _imagePickerViewContoller;
}

- (UIAlertController *)screenShareMenuAlertController {
    if (!_screenShareMenuAlertController) {
        _screenShareMenuAlertController = [UIAlertController alertControllerWithTitle:nil
                                                                              message:@"Please choose the content you want to share"
                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
        
        
        __weak MainViewController *weakSelf = self;
        UIAlertAction *grayAction = [UIAlertAction actionWithTitle:@"Gray Canvas"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
            
                                                               weakSelf.customSharedContent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.mainView.bounds), CGRectGetHeight(self.mainView.bounds))];
                                                               [weakSelf startScreenShare];
                                                           }];
        
        UIAlertAction *cameraRollAction = [UIAlertAction actionWithTitle:@"Camera Roll"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
                                                               [self presentViewController:weakSelf.imagePickerViewContoller animated:YES completion:nil];
                                                           }];
        
        [_screenShareMenuAlertController addAction:grayAction];
        [_screenShareMenuAlertController addAction:cameraRollAction];
        [_screenShareMenuAlertController addAction:
         [UIAlertAction actionWithTitle:@"Cancel"
                                  style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction *action) {
                                    
                                    [_screenShareMenuAlertController dismissViewControllerAnimated:YES completion:nil];
                                }]
         ];
    }
    return _screenShareMenuAlertController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mainView = (MainView *)self.view;
    self.oneToOneCommunicator = [OneToOneCommunicator oneToOneCommunicator];
    self.screenSharer = [ScreenSharer screenSharer];
#if !(TARGET_OS_SIMULATOR)
    [self.mainView showReverseCameraButton];
#endif
}

- (IBAction)publisherCallButtonPressed:(UIButton *)sender {
    
    [SVProgressHUD show];
    
    if (!self.oneToOneCommunicator.isCallEnabled && !self.screenSharer.isScreenSharing) {
        [self.oneToOneCommunicator connectWithHandler:^(OneToOneCommunicationSignal signal, NSError *error) {
            
            if (!error) {
                [SVProgressHUD dismiss];
                [self handleCommunicationSignal:signal];
            }
            else {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }
        }];
    }
    else {
        [SVProgressHUD dismiss];
        [self.screenSharer disconnect];
        [self.oneToOneCommunicator disconnect];
        [self.mainView connectCallHolder:NO];
        [self.mainView updateControlButtonsForEndingCall];
        
        [self.mainView removePublisherView];
        [self.mainView removePlaceHolderImage];
        [self.mainView removeAnnotationToolBar];
    }
}

- (void)handleCommunicationSignal:(OneToOneCommunicationSignal)signal {
    
    
    switch (signal) {
        case OneToOneCommunicationSignalSessionDidConnect: {
            [self.mainView connectCallHolder:YES];
            [self.mainView updateControlButtonsForCall];
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

- (IBAction)publisherAudioButtonPressed:(UIButton *)sender {
    
    if (self.oneToOneCommunicator.isCallEnabled) {
        self.oneToOneCommunicator.publishAudio = !self.oneToOneCommunicator.publishAudio;
        [self.mainView mutePubliserhMic:self.oneToOneCommunicator.publishAudio];
    }
    else if (self.screenSharer.isScreenSharing) {
        self.screenSharer.publishAudio = !self.screenSharer.publishAudio;
        [self.mainView mutePubliserhMic:self.screenSharer.publishAudio];
    }
}

- (IBAction)annotationButtonPressed:(UIButton *)sender {
    [self.mainView toggleAnnotationToolBar];
}

- (IBAction)ScreenShareButtonPressed:(UIButton *)sender {
    
    if (!self.screenSharer.isScreenSharing) {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self presentViewController:self.screenShareMenuAlertController animated:YES completion:nil];
        }
        else {
            UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:self.screenShareMenuAlertController];
            [popup presentPopoverFromRect:self.mainView.screenShareHolder.bounds
                                   inView:self.mainView.screenShareHolder
                 permittedArrowDirections:UIPopoverArrowDirectionAny
                                 animated:YES];
        }
    }
    else {
        [self stopScreenShareAndRecover];
    }
}

- (void)startScreenShare {
    [self.oneToOneCommunicator disconnect];
    [SVProgressHUD show];
    [self.screenSharer connectWithView:self.mainView.shareView handler:^(ScreenShareSignal signal, NSError *error) {
        
        [SVProgressHUD dismiss];
        if (!error) {
            [self handleScreenShareSignal:signal];
        }
        else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

- (void)stopScreenShareAndRecover {
    [self.screenSharer disconnect];
    [SVProgressHUD show];
    [self.oneToOneCommunicator connectWithHandler:^(OneToOneCommunicationSignal signal, NSError *error) {
        
        [SVProgressHUD dismiss];
        if (!error) {
            [self handleCommunicationSignal:signal];
        }
        else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

- (void)handleScreenShareSignal:(ScreenShareSignal)signal {
    
    switch (signal) {
        case ScreenShareSignalSessionDidConnect: {
            [self.mainView addScreenShareViewWithContentView:self.customSharedContent];
            [self.mainView toggleAnnotationToolBar];
            [self.mainView updateControlButtonsForScreenShare];
            [self.mainView showScreenShareNotificationBar:YES];
            break;
        }
        case ScreenShareSignalSessionDidDisconnect: {
            [self.mainView removeScreenShareView];
            [self.mainView removeAnnotationToolBar];
            [self.customSharedContent removeFromSuperview];
            [self.mainView cleanCanvas];
            [self.mainView showScreenShareNotificationBar:NO];
            break;
        }
        case ScreenShareSignalSessionDidFail:{
            [SVProgressHUD dismiss];
            break;
        }
        case ScreenShareSignalPublisherDidFail:{
            [SVProgressHUD showErrorWithStatus:@"Problem when publishing"];
            break;
        }
        case ScreenShareSignalSubscriberDidFail:{
            [SVProgressHUD showErrorWithStatus:@"Problem when subscribing"];
            break;
        }
        case ScreenShareSignalSubscriberVideoDisableWarning:{
            [SVProgressHUD showErrorWithStatus:@"Network connection is unstable."];
            break;
        }
        default:
            break;
    }
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
 * handles the event when the user does a touch to show and then hide the buttons for
 * subscriber actions within 7 seconds
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

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    self.customSharedContent = [[UIImageView alloc] initWithImage:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:^(){
        [self startScreenShare];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
