//
//  MainView.m
//  OneToOneScreenShareSample
//
//  Created by Esteban Cordero on 5/23/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "MainView.h"

@interface MainView()
@property (strong, nonatomic) IBOutlet UIView *publisherView;
@property (strong, nonatomic) IBOutlet UIView *subscriberView;

// 4 action buttons at the bottom of the view
@property (strong, nonatomic) IBOutlet UIButton *videoHolder;
@property (strong, nonatomic) IBOutlet UIButton *callHolder;
@property (strong, nonatomic) IBOutlet UIButton *micHolder;
@property (strong, nonatomic) IBOutlet UIButton *annotationHolder;

@property (strong, nonatomic) IBOutlet UIButton *subscriberVideoButton;
@property (strong, nonatomic) IBOutlet UIButton *subscriberAudioButton;

@property (strong, nonatomic) IBOutlet UIButton *publisherCameraButton;

@property (strong, nonatomic) UIImageView *subscriberPlaceHolderImageView;
@property (strong, nonatomic) UIImageView *publisherPlaceHolderImageView;

@property (nonatomic) ScreenShareToolbarView *toolbarView;
@property (strong, nonatomic) IBOutlet UIView *actionButtonView;

@property (weak, nonatomic) IBOutlet UIView *screenshareNotificationBar;
@end

@implementation MainView

- (ScreenShareToolbarView *)toolbarView {
    if (!_toolbarView) {
        _toolbarView = [ScreenShareToolbarView toolbar];
        _toolbarView.backgroundColor = [UIColor darkGrayColor];
        
        CGFloat height = _toolbarView.bounds.size.height;
        _toolbarView.frame = CGRectMake(0, CGRectGetHeight(self.shareView.bounds) - height, _toolbarView.bounds.size.width, height);
    }
    return _toolbarView;
}


- (UIImageView *)publisherPlaceHolderImageView {
    if (!_publisherPlaceHolderImageView) {
        _publisherPlaceHolderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page1"]];
        _publisherPlaceHolderImageView.backgroundColor = [UIColor clearColor];
        _publisherPlaceHolderImageView.contentMode = UIViewContentModeScaleAspectFit;
        _publisherPlaceHolderImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _publisherPlaceHolderImageView;
}

- (UIImageView *)subscriberPlaceHolderImageView {
    if (!_subscriberPlaceHolderImageView) {
        _subscriberPlaceHolderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page1"]];
        _subscriberPlaceHolderImageView.backgroundColor = [UIColor clearColor];
        _subscriberPlaceHolderImageView.contentMode = UIViewContentModeScaleAspectFit;
        _subscriberPlaceHolderImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _subscriberPlaceHolderImageView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.shareView.hidden = YES;
    
    self.publisherView.hidden = YES;
    self.publisherView.alpha = 1;
    self.publisherView.layer.borderWidth = 1;
    self.publisherView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.publisherView.layer.backgroundColor = [UIColor grayColor].CGColor;
    self.publisherView.layer.cornerRadius = 3;

    [self showSubscriberControls:NO];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self drawBorderOn:self.micHolder withWhiteBorder:YES];
    [self drawBorderOn:self.callHolder withWhiteBorder:NO];
    [self drawBorderOn:self.videoHolder withWhiteBorder:YES];
    [self drawBorderOn:self.screenShareHolder withWhiteBorder:YES];
    [self drawBorderOn:self.annotationHolder withWhiteBorder:YES];
}

- (void)drawBorderOn:(UIView *)view
     withWhiteBorder:(BOOL)withWhiteBorder {
    
    view.layer.cornerRadius = (view.bounds.size.width / 2);
    if (withWhiteBorder) {
        view.layer.borderWidth = 1;
        view.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}

#pragma mark - publisher view
- (void)addPublisherView:(UIView *)publisherView {
    
    [self.publisherView setHidden:NO];
    publisherView.frame = CGRectMake(0, 0, CGRectGetWidth(self.publisherView.bounds), CGRectGetHeight(self.publisherView.bounds));
    [self.publisherView addSubview:publisherView];
    publisherView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addAttachedLayoutConstantsToSuperview:publisherView];
}

- (void)removePublisherView {
    [self.publisherView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)addPlaceHolderToPublisherView {
    self.publisherPlaceHolderImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.publisherView.bounds), CGRectGetHeight(self.publisherView.bounds));
    [self.publisherView addSubview:self.publisherPlaceHolderImageView];
    [self addAttachedLayoutConstantsToSuperview:self.publisherPlaceHolderImageView];
}

- (void)connectCallHolder:(BOOL)connected {
    if (connected) {
        [self.callHolder setImage:[UIImage imageNamed:@"hangUp"] forState:UIControlStateNormal];
        self.callHolder.layer.backgroundColor = [UIColor colorWithRed:(205/255.0) green:(32/255.0) blue:(40/255.0) alpha:1.0].CGColor;
    }
    else {
        [self.callHolder setImage:[UIImage imageNamed:@"startCall"] forState:UIControlStateNormal];
        self.callHolder.layer.backgroundColor = [UIColor colorWithRed:(106/255.0) green:(173/255.0) blue:(191/255.0) alpha:1.0].CGColor;
    }
}
- (void)mutePubliserhMic:(BOOL)muted {
    if (muted) {
        [self.micHolder setImage:[UIImage imageNamed:@"mutedMicLineCopy"] forState: UIControlStateNormal];
    }
    else {
        [self.micHolder setImage:[UIImage imageNamed:@"mic"] forState: UIControlStateNormal];
    }
}

- (void)connectPubliserVideo:(BOOL)connected {
    if (connected) {
        [self.videoHolder setImage:[UIImage imageNamed:@"noVideoIcon"] forState: UIControlStateNormal];
    }
    else {
        [self.videoHolder setImage:[UIImage imageNamed:@"videoIcon"] forState:UIControlStateNormal];
    }
}

#pragma mark - subscriber view
- (void)addSubscribeView:(UIView *)subsciberView {
    
    subsciberView.frame = CGRectMake(0, 0, CGRectGetWidth(self.subscriberView.bounds), CGRectGetHeight(self.subscriberView.bounds));
    [self.subscriberView addSubview:subsciberView];
    subsciberView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addAttachedLayoutConstantsToSuperview:subsciberView];
}

- (void)removeSubscriberView {
    [self.subscriberView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)addPlaceHolderToSubscriberView {
    self.subscriberPlaceHolderImageView.frame = self.subscriberView.bounds;
    [self.subscriberView addSubview:self.subscriberPlaceHolderImageView];
    [self addAttachedLayoutConstantsToSuperview:self.subscriberPlaceHolderImageView];
}

- (void)muteSubscriberMic:(BOOL)muted {
    if (muted) {
        [self.subscriberAudioButton setImage:[UIImage imageNamed:@"noSoundCopy"] forState: UIControlStateNormal];
    }
    else {
        [self.subscriberAudioButton setImage:[UIImage imageNamed:@"audio"] forState: UIControlStateNormal];
    }
}

- (void)connectSubsciberVideo:(BOOL)connected {
    if (connected) {
        [self.subscriberVideoButton setImage:[UIImage imageNamed:@"noVideoIcon"] forState: UIControlStateNormal];
    }
    else {
        [self.subscriberVideoButton setImage:[UIImage imageNamed:@"videoIcon"] forState: UIControlStateNormal];
    }
}

- (void)showSubscriberControls:(BOOL)shown {
    if (shown) {
        [self.subscriberAudioButton setHidden:NO];
        [self.subscriberVideoButton setHidden:NO];
    }
    else {
        [self.subscriberAudioButton setHidden:YES];
        [self.subscriberVideoButton setHidden:YES];
    }
}

- (void)addScreenShareViewWithContentView:(UIView *)view {
    self.toolbarView.screenShareView.frame = self.shareView.bounds;
    [self.toolbarView.screenShareView addContentView:view];
    [self.shareView setHidden:NO];
    [self.shareView addSubview:self.toolbarView.screenShareView];
    [self.publisherView setHidden:YES];
    [self bringSubviewToFront:self.actionButtonView];
}

- (void)removeScreenShareView {
    [self.shareView setHidden:YES];
    [self.toolbarView.screenShareView removeFromSuperview];
    [self.publisherView setHidden:NO];
}

#pragma mark - annotation bar
- (void)toggleAnnotationToolBar {
    
    if (!self.toolbarView || !self.toolbarView.superview) {
        [self.toolbarView.screenShareView eraseAll];
        [self.shareView addSubview:self.toolbarView];
    }
    else {
        [self removeAnnotationToolBar];
    }
}

- (void)removeAnnotationToolBar {
    [self.toolbarView removeFromSuperview];
}

- (void)cleanCanvas {
    [self.toolbarView.screenShareView eraseAll];
}

#pragma mark - other controls
- (void)removePlaceHolderImage {
    [self.publisherPlaceHolderImageView removeFromSuperview];
    [self.subscriberPlaceHolderImageView removeFromSuperview];
}

- (void)updateControlButtonsForCall {
    [self.subscriberVideoButton setEnabled:YES];
    [self.subscriberAudioButton setEnabled:YES];
    [self.publisherCameraButton setEnabled:YES];
    [self.videoHolder setEnabled:YES];
    [self.micHolder setEnabled:YES];
    [self.screenShareHolder setEnabled:YES];
    [self.annotationHolder setEnabled:NO];
    [self.micHolder setImage:[UIImage imageNamed:@"mic"] forState: UIControlStateNormal];
    [self.videoHolder setImage:[UIImage imageNamed:@"videoIcon"] forState:UIControlStateNormal];
    [self.subscriberAudioButton setImage:[UIImage imageNamed:@"audio"] forState: UIControlStateNormal];
    [self.subscriberVideoButton setImage:[UIImage imageNamed:@"videoIcon"] forState: UIControlStateNormal];
}

- (void)updateControlButtonsForScreenShare {
    [self.subscriberVideoButton setEnabled:NO];
    [self.subscriberAudioButton setEnabled:YES];
    [self.publisherCameraButton setEnabled:NO];
    [self.videoHolder setEnabled:NO];
    [self.micHolder setEnabled:YES];
    [self.screenShareHolder setEnabled:YES];
    [self.annotationHolder setEnabled:YES];
    [self.micHolder setImage:[UIImage imageNamed:@"mic"] forState: UIControlStateNormal];
    [self.videoHolder setImage:[UIImage imageNamed:@"videoIcon"] forState:UIControlStateNormal];
    [self.subscriberAudioButton setImage:[UIImage imageNamed:@"audio"] forState: UIControlStateNormal];
    [self.subscriberVideoButton setImage:[UIImage imageNamed:@"videoIcon"] forState: UIControlStateNormal];
}


- (void)updateControlButtonsForEndingCall {
    [self.subscriberVideoButton setEnabled:NO];
    [self.subscriberAudioButton setEnabled:NO];
    [self.publisherCameraButton setEnabled:NO];
    [self.videoHolder setEnabled:NO];
    [self.micHolder setEnabled:NO];
    [self.screenShareHolder setEnabled:NO];
    [self.annotationHolder setEnabled:NO];
    [self.micHolder setImage:[UIImage imageNamed:@"mic"] forState: UIControlStateNormal];
    [self.videoHolder setImage:[UIImage imageNamed:@"videoIcon"] forState:UIControlStateNormal];
    [self.subscriberAudioButton setImage:[UIImage imageNamed:@"audio"] forState: UIControlStateNormal];
    [self.subscriberVideoButton setImage:[UIImage imageNamed:@"videoIcon"] forState: UIControlStateNormal];
}

- (void)showScreenShareNotificationBar:(BOOL)shown {
    [self.screenshareNotificationBar setHidden:!shown];
}

#pragma mark - private method
-(void)addAttachedLayoutConstantsToSuperview:(UIView *)view {
    
    if (!view.superview) {
        return;
    }
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:view
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:view.superview
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:0.0];
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:view
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:view.superview
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1.0
                                                                constant:0.0];
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:view
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:view.superview
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1.0
                                                                 constant:0.0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:view
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:view.superview
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0.0];
    [NSLayoutConstraint activateConstraints:@[top, leading, trailing, bottom]];
}


@end
