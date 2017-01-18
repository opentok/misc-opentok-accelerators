//
//  OTSubscriberView.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTVideoView.h"
#import "OTAcceleratorPackUtilBundle.h"
#import "UIView+Helper.h"

@interface OTAudioVideoControlView()
@property (nonatomic) UIImage *audioImage;
@property (nonatomic) UIImage *noAudioImage;
@property (nonatomic) UIImage *videoImage;
@property (nonatomic) UIImage *noVideoImage;
@property (nonatomic) UIButton *audioButton;
@property (nonatomic) UIButton *videoButton;
@end

@implementation OTAudioVideoControlView

- (UIImage *)noAudioImage {
    if (!_noAudioImage) {
        _noAudioImage = [UIImage imageNamed:@"noAudio" inBundle:[OTAcceleratorPackUtilBundle acceleratorPackUtilBundle] compatibleWithTraitCollection: nil];
    }
    return _noAudioImage;
}

- (UIImage *)noVideoImage {
    if (!_noVideoImage) {
        _noVideoImage = [UIImage imageNamed:@"noVideo" inBundle:[OTAcceleratorPackUtilBundle acceleratorPackUtilBundle] compatibleWithTraitCollection: nil];
    }
    return _noVideoImage;
}

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor lightGrayColor];
        _audioImage = [UIImage imageNamed:@"audio" inBundle:[OTAcceleratorPackUtilBundle acceleratorPackUtilBundle] compatibleWithTraitCollection: nil];
        _videoImage = [UIImage imageNamed:@"video" inBundle:[OTAcceleratorPackUtilBundle acceleratorPackUtilBundle] compatibleWithTraitCollection: nil];
        _audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_audioButton setImage:_audioImage forState:UIControlStateNormal];
        _audioButton.translatesAutoresizingMaskIntoConstraints = NO;
        _videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoButton setImage:_videoImage forState:UIControlStateNormal];
        _videoButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_audioButton];
        [self addSubview:_videoButton];
        
        [NSLayoutConstraint constraintWithItem:_audioButton
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_audioButton.superview
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_audioButton
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_audioButton.superview
                                     attribute:NSLayoutAttributeLeading
                                    multiplier:1.0
                                      constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_audioButton
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_audioButton.superview
                                     attribute:NSLayoutAttributeTrailing
                                    multiplier:1.0
                                      constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_audioButton
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_audioButton.superview
                                     attribute:NSLayoutAttributeHeight
                                    multiplier:0.5
                                      constant:0.0].active = YES;
        
        [NSLayoutConstraint constraintWithItem:_videoButton
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_audioButton
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0
                                      constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_videoButton
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_videoButton.superview
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1.0
                                      constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_videoButton
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_videoButton.superview
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1.0
                                      constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_videoButton
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_videoButton.superview
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0
                                      constant:0.0].active = YES;
    }
    return self;
}

- (void)updateAudioButton:(BOOL)enabled {
    if (enabled) {
        [_audioButton setImage:self.audioImage forState:UIControlStateNormal];
    }
    else {
        [_audioButton setImage:self.noAudioImage forState:UIControlStateNormal];
    }
}

- (void)updateVideoButton:(BOOL)enabled {
    if (enabled) {
        [_videoButton setImage:self.videoImage forState:UIControlStateNormal];
    }
    else {
        [_videoButton setImage:self.noVideoImage forState:UIControlStateNormal];
    }
}

@end

@interface OTVideoView()
@property (nonatomic) UIImage *placeHolderImage;
@property (nonatomic) UIImageView *placeHolderImageView;
@property (weak, nonatomic) OTSubscriber *subscriber;
@property (weak, nonatomic) OTPublisher *publisher;
@property (nonatomic) OTAudioVideoControlView *controlView;
@end

@implementation OTVideoView

+ (instancetype)defaultPlaceHolderImageWithPublisher:(OTPublisher *)publisher {
    if (![publisher isKindOfClass:[OTPublisher class]]) return nil;
    OTVideoView *videoView = [[OTVideoView alloc] initWithVideoView:publisher.view
                                                   placeHolderImage:[UIImage imageNamed:@"avatar" inBundle:[OTAcceleratorPackUtilBundle acceleratorPackUtilBundle] compatibleWithTraitCollection: nil]];
    videoView.publisher = publisher;
    [videoView addObserver:videoView
                forKeyPath:@"publisher.publishVideo"
                   options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                   context:nil];
    [videoView addObserver:videoView
                forKeyPath:@"publisher.publishAudio"
                   options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                   context:nil];
    
    [videoView updateUI:videoView.publisher.publishVideo];
    return videoView;
}

+ (instancetype)defaultPlaceHolderImageWithSubscriber:(OTSubscriber *)subscriber {
    if (![subscriber isKindOfClass:[OTSubscriber class]]) return nil;
    OTVideoView *videoView = [[OTVideoView alloc] initWithVideoView:subscriber.view
                                                   placeHolderImage:[UIImage imageNamed:@"avatar" inBundle:[OTAcceleratorPackUtilBundle acceleratorPackUtilBundle] compatibleWithTraitCollection: nil]];
    videoView.subscriber = subscriber;
    [videoView addObserver:videoView
                forKeyPath:@"subscriber.subscribeToVideo"
                   options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                   context:nil];
    [videoView addObserver:videoView
                forKeyPath:@"subscriber.stream.hasVideo"
                   options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                   context:nil];
    [videoView addObserver:videoView
                forKeyPath:@"subscriber.subscribeToAudio"
                   options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                   context:nil];
    [videoView addObserver:videoView
                forKeyPath:@"subscriber.stream.hasAudio"
                   options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                   context:nil];
    [videoView updateUI:videoView.subscriber.subscribeToVideo && videoView.subscriber.stream.hasVideo];
    return videoView;
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    if (view == _placeHolderImageView) {
        [self bringSubviewToFront:self.controlView];
    }
}

- (void)setShowAudioVideoControl:(BOOL)showAudioVideoControl {
    _showAudioVideoControl = showAudioVideoControl;
    if (_showAudioVideoControl) {
        _controlView = [[OTAudioVideoControlView alloc] init];
        [_controlView.audioButton addTarget:self
                                     action:@selector(controlViewAudioButtonClicked:)
                           forControlEvents:UIControlEventTouchUpInside];
        [_controlView.videoButton addTarget:self
                                     action:@selector(controlViewVideoButtonClicked:)
                           forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_controlView];
        _controlView.frame = CGRectMake(10, 10, CGRectGetWidth(self.frame) * 0.1, CGRectGetHeight(self.frame) * 0.3);
    }
    else {
        [_controlView removeFromSuperview];
        _controlView = nil;
    }
}

- (UIImageView *)placeHolderImageView {
    
    if (!_placeHolderImageView) {
        _placeHolderImageView = [[UIImageView alloc] initWithImage: _placeHolderImage];
        _placeHolderImageView.backgroundColor = [UIColor grayColor];
        _placeHolderImageView.contentMode = UIViewContentModeScaleAspectFit;
        _placeHolderImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _placeHolderImageView;
}

- (instancetype)initWithVideoView:(UIView *)view
                 placeHolderImage:(UIImage *)placeHolderImage {
    
    if (self = [super init]) {
        _handleAudioVideo = YES;
        _showAudioVideoControl = YES;
        
        _placeHolderImage = placeHolderImage;
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
        [view addAttachedLayoutConstantsToSuperview];
        
        _controlView = [[OTAudioVideoControlView alloc] init];
        [_controlView.audioButton addTarget:self
                                     action:@selector(controlViewAudioButtonClicked:)
                           forControlEvents:UIControlEventTouchUpInside];
        [_controlView.videoButton addTarget:self
                                     action:@selector(controlViewVideoButtonClicked:)
                           forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_controlView];
    }
    return self;
}

- (void)controlViewAudioButtonClicked:(UIButton *)button {
    if (button == _controlView.audioButton) {
        if (_publisher) {
            self.publisher.publishAudio = !self.publisher.publishAudio;
        }
        else {
            self.subscriber.subscribeToAudio = !self.subscriber.subscribeToAudio;
        }
    }
}

- (void)controlViewVideoButtonClicked:(UIButton *)button {
    if (button == _controlView.videoButton) {
        if (_publisher) {
            self.publisher.publishVideo = !self.publisher.publishVideo;
        }
        else {
            self.subscriber.subscribeToVideo = !self.subscriber.subscribeToVideo;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    OTVideoView *videoView = (OTVideoView *)object;
    if (videoView.publisher == self.publisher && [keyPath isEqualToString:@"publisher.publishVideo"]) {
        [self updateUI:self.publisher.publishVideo];
        if (self.controlView) {
            [self.controlView updateVideoButton:self.publisher.publishVideo];
        }
    }
    else if (videoView.publisher == self.publisher && [keyPath isEqualToString:@"publisher.publishAudio"]) {
        if (self.controlView) {
            [self.controlView updateAudioButton:self.publisher.publishAudio];
        }
    }
    else if (videoView.subscriber == self.subscriber && ([keyPath isEqualToString:@"subscriber.stream.hasVideo"] || [keyPath isEqualToString:@"subscriber.subscribeToVideo"] )) {
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self updateUI:self.subscriber.subscribeToVideo && self.subscriber.stream.hasVideo];
            if (self.controlView) {
                [self.controlView updateVideoButton:self.subscriber.subscribeToVideo];
            }
        });
    }
    else if (videoView.subscriber == self.subscriber && [keyPath isEqualToString:@"subscriber.subscribeToAudio"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (self.controlView) {
                [self.controlView updateAudioButton:self.subscriber.subscribeToAudio];
            }
        });
    }
}

- (void)clean {
    
    if (self.publisher) {
        [self removeObserver:self forKeyPath:@"publisher.publishVideo"];
        [self removeObserver:self forKeyPath:@"publisher.publishAudio"];
    }
    
    if (self.subscriber) {
        [self removeObserver:self forKeyPath:@"subscriber.subscribeToVideo"];
        [self removeObserver:self forKeyPath:@"subscriber.stream.hasVideo"];
        [self removeObserver:self forKeyPath:@"subscriber.subscribeToAudio"];
        [self removeObserver:self forKeyPath:@"subscriber.stream.hasAudio"];
    }
    
    [_controlView removeFromSuperview];
    _controlView = nil;
    _placeHolderImage = nil;
    [_placeHolderImageView removeFromSuperview];
    _placeHolderImageView = nil;
}

- (void)refresh {
    
    if (!_subscriber && !_publisher) return;
    
    if (_publisher) {
        [self updateUI:_publisher.publishVideo];
    }
    else {
        [self updateUI:_subscriber.subscribeToVideo];
    }
}

- (void)updateUI:(BOOL)enabled {
    
    if (!self.handleAudioVideo) return;
    
    if (enabled) {
        [self.placeHolderImageView removeFromSuperview];
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(OTVideoViewProtocol)]) {
            [self.delegate placeHolderImageViewDidDismissOnVideoView:self];
        }
    }
    else {
        if (self.placeHolderImageView.superview) return;
        [self addSubview:self.placeHolderImageView];
        [self.placeHolderImageView addAttachedLayoutConstantsToSuperview];
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(OTVideoViewProtocol)]) {
            [self.delegate placeHolderImageViewDidShowOnVideoView:self];
        }
    }
}

@end
