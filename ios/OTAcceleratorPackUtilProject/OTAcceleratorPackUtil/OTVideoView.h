//
//  OTSubscriberView.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenTok/OpenTok.h>

@interface OTAudioVideoControlView : UIView

@property (readonly, nonatomic) UIButton *audioButton;

@property (readonly, nonatomic) UIButton *videoButton;

@end

@class OTVideoView;
@protocol OTVideoViewProtocol <NSObject>

@optional

- (void)placeHolderImageViewDidShowOnVideoView:(OTVideoView *)videoView;

- (void)placeHolderImageViewDidDismissOnVideoView:(OTVideoView *)videoView;

- (void)videoView:(OTVideoView *)videoView didTapToChangeAudioTo:(BOOL)enabled;

- (void)videoView:(OTVideoView *)videoView didTapToChangeVideoTo:(BOOL)enabled;

@end

@interface OTVideoView : UIView

+ (instancetype)defaultPlaceHolderImageWithPublisher:(OTPublisher *)publisher;

+ (instancetype)defaultPlaceHolderImageWithSubscriber:(OTSubscriber *)subscriber;

@property (weak, nonatomic) id<OTVideoViewProtocol> delegate;

@property (readonly, nonatomic) OTAudioVideoControlView *controlView;

@property (nonatomic) BOOL showAudioVideoControl;

@property (nonatomic) BOOL handleAudioVideo;

- (void)clean;

@end
