//
//  MainView.h
//  OneToOneScreenShareSample
//
//  Created by Esteban Cordero on 5/23/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ScreenShareKit/ScreenShareKit.h>

@interface MainView : UIView

@property (strong, nonatomic) IBOutlet UIView *shareView;
@property (strong, nonatomic) IBOutlet UIButton *screenShareHolder;

// publisher view
- (void)addPublisherView:(UIView *)publisherView;
- (void)removePublisherView;
- (void)addPlaceHolderToPublisherView;

- (void)connectCallHolder:(BOOL)connected;
- (void)mutePubliserhMic:(BOOL)muted;
- (void)connectPubliserVideo:(BOOL)connected;

// subscriber view
- (void)addSubscribeView:(UIView *)subscriberView;
- (void)removeSubscriberView;
- (void)addPlaceHolderToSubscriberView;

- (void)muteSubscriberMic:(BOOL)muted;
- (void)connectSubsciberVideo:(BOOL)connected;
- (void)showSubscriberControls:(BOOL)shown;

- (void)addScreenShareViewWithContentView:(UIView *)view;
- (void)removeScreenShareView;

// annotation bar
- (void)toggleAnnotationToolBar;
- (void)removeAnnotationToolBar;

// other controls
- (void)removePlaceHolderImage;
- (void)buttonsStatusSetter: (BOOL)status;
- (void)resetAudioVideoControlButtons;

@end
