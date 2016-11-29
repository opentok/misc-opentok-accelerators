//
//  OTSubscriberView.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenTok/OpenTok.h>

@class OTVideoView;
@protocol OTVideoViewProtocol <NSObject>

@optional

- (void)placeHolderImageViewDidShowOnVideoView:(OTVideoView *)videoView;

- (void)placeHolderImageViewDidDismissOnVideoView:(OTVideoView *)videoView;

- (void)videoView:(OTVideoView *)videoView didChangeAudioTo:(BOOL)enabled;

- (void)videoView:(OTVideoView *)videoView didChangeVideoTo:(BOOL)enabled;

@end

@interface OTVideoView : UIView

+ (instancetype)defaultPlaceHolderImageWithPublisher:(OTPublisher *)publisher;

+ (instancetype)defaultPlaceHolderImageWithSubscriber:(OTSubscriber *)subscriber;

@property (nonatomic) id<OTVideoViewProtocol> delegate;

@property (nonatomic) BOOL showAudioVideoControl;

@property (nonatomic) BOOL handleAudioVideo;

- (void)clean;

@end
