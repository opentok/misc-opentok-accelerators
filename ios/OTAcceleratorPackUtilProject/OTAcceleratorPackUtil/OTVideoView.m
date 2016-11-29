//
//  OTSubscriberView.m
//  OTAcceleratorPackUtilProject
//
//  Created by Xi Huang on 12/1/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTVideoView.h"
#import "OTAcceleratorPackUtilBundle.h"
#import "UIView+Helper.h"

@interface OTVideoView()
@property (nonatomic) UIImage *placeHolderImage;
@property (nonatomic) UIImageView *placeHolderImageView;
@property (weak, nonatomic) OTSubscriber *subscriber;
@property (weak, nonatomic) OTPublisher *publisher;
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
    [videoView updateUI:videoView.subscriber.subscribeToVideo && videoView.subscriber.stream.hasVideo];
    return videoView;
}

- (void)clean {
    
    if (self.publisher) {
        [self removeObserver:self forKeyPath:@"publisher.publishVideo"];
    }
    
    if (self.subscriber) {
        [self removeObserver:self forKeyPath:@"subscriber.subscribeToVideo"];
        [self removeObserver:self forKeyPath:@"subscriber.stream.hasVideo"];
    }
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
        _placeHolderImage = placeHolderImage;
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
        [view addAttachedLayoutConstantsToSuperview];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    OTVideoView *videoView = (OTVideoView *)object;
    if (videoView.publisher == self.publisher && [keyPath isEqualToString:@"publisher.publishVideo"]) {
        [self updateUI:self.publisher.publishVideo];
    }
    else if (videoView.subscriber == self.subscriber && ([keyPath isEqualToString:@"subscriber.stream.hasVideo"] || [keyPath isEqualToString:@"subscriber.subscribeToVideo"] )) {
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self updateUI:self.subscriber.subscribeToVideo && self.subscriber.stream.hasVideo];
        });
    }
}

@end
