//
//  OTScreenSharer.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTAcceleratorSession.h"
#import "OTOneToOneCommunicator.h"

@class OTScreenSharer;

@protocol OTScreenShareDataSource <NSObject>
- (OTAcceleratorSession *)sessionOfOTScreenSharer:(OTScreenSharer *)screenSharer;
@end

@interface OTScreenSharer : NSObject

/**
 *  The object that acts as the data source of the screen sharer.
 *
 *  The delegate must adopt the OTScreenShareDataSource protocol. The delegate is not retained.
 */
@property (weak, nonatomic) id<OTScreenShareDataSource> dataSource;

/**
 *  Initialize a new `OTScreenSharer` instsance with a publisher name.
 *
 *  @return A new `OTScreenSharer` instsance.
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  A string that represents the current communicator.
 *  If not specified, the value will be "system name-name specified by Setting", e.g. @"iOS-MyiPhone"
 */
@property (readonly, nonatomic) NSString *name;

/**
 *  An alternative connect method with a completion block handler.
 *
 *  @param view    The UIView to be shared.
 *  @param handler The completion handler to call with the change.
 */
- (void)connectWithView:(UIView *)view
                handler:(OTCommunicatorBlock)handler;

/**
 *  De-registers to the shared session: [OTAcceleratorSession] and stops publishing/subscriber.
 *
 *  @return An error to indicate whether it disconnects successfully, non-nil if it fails.
 */
- (NSError *)disconnect;

/**
 *  Change the sharing UIView, it does nothing if sharing is not started.
 */
- (void)updateView:(UIView *)view;

/**
 *  A boolean value that indicates whether the specified UIView is sharing.
 */
@property (readonly, nonatomic) BOOL isScreenSharing;

#pragma mark - subscriber
/**
 *  The scaling of the rendered video, as defined by the <OTVideoViewContentMode> enum.
 *  The default value is OTVideoViewScaleBehaviorFill. 
 *  Set it to OTVideoViewScaleBehaviorFit to have the video shrink, as needed, so that the entire video is visible(with pillarboxing).
 */
@property (nonatomic) OTVideoViewContentMode subscriberVideoContentMode;

/**
 *  The current dimensions of the video media track on the subscriber's stream.
 *  This property can change if a stream published from an iOS device resizes, based on a change in the device orientation, or a change in video resolution occurs.
 */
@property (readonly, nonatomic) CGSize subscriberVideoDimension;

/**
 *  A boolean value to indicate whether the subscriber has audio available.
 */
@property (nonatomic, readonly) BOOL isRemoteAudioAvailable;

/**
 *  A boolean value to indicate whether the subscriber has video available.
 */
@property (nonatomic, readonly) BOOL isRemoteVideoAvailable;

/**
 *  The view containing a playback buffer for associated video data. Add this view to your view heirarchy to display a video stream.
 *
 *  The subscriber view is available after OTSubscriberDidConnect being signaled.
 */
@property (readonly, nonatomic) OTVideoView *subscriberView;

/**
 *  A boolean value to indicate whether the screen sharer subscripts to audio.
 */
@property (nonatomic, getter=isSubscribeToAudio) BOOL subscribeToAudio;

/**
 *  A boolean value to indicate whether the screen sharer subscripts to video.
 */
@property (nonatomic, getter=isSubscribeToVideo) BOOL subscribeToVideo;

#pragma mark - publisher
/**
 *  The view for this publisher. If this view becomes visible, it will display a preview of the active screen share feed.
 *
 *  The publisher view is available after OTSessionDidConnect being signaled.
 */
@property (readonly, nonatomic) OTVideoView *publisherView;

/**
 *  A boolean value to indicate whether to publish audio.
 */
@property (nonatomic, getter=isPublishAudio) BOOL publishAudio;

/**
 *  A boolean value to indicate whether to publish video.
 */
@property (nonatomic, getter=isPublishVideo) BOOL publishVideo;

#pragma mark - advanced
/**
 *  Manually subscribe to a stream with a specfieid name.
 *
 *  @return An error to indicate whether it subscribes successfully, non-nil if it fails.
 */
- (NSError *)subscribeToStreamWithName:(NSString *)name;

/**
 *  Manually subscribe to a stream with a specfieid stream id.
 *
 *  @return An error to indicate whether it subscribes successfully, non-nil if it fails.
 */
- (NSError *)subscribeToStreamWithStreamId:(NSString *)streamId;

@end
