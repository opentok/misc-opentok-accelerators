//
//  OTOneToOneCommunicator.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, OTOneToOneCommunicationSignal) {
    OTSessionDidConnect = 0,
    OTSessionDidDisconnect,
    OTSessionDidFail,
    OTSessionStreamCreated,
    OTSessionStreamDestroyed,
    OTSessionDidBeginReconnecting,
    OTSessionDidReconnect,
    OTPublisherDidFail,
    OTPublisherStreamCreated,
    OTPublisherStreamDestroyed,
    OTSubscriberDidConnect,
    OTSubscriberDidFail,
    OTSubscriberVideoDisabledByPublisher,
    OTSubscriberVideoDisabledBySubscriber,
    OTSubscriberVideoDisabledByBadQuality,
    OTSubscriberVideoEnabledByPublisher,
    OTSubscriberVideoEnabledBySubscriber,
    OTSubscriberVideoEnabledByGoodQuality,
    OTSubscriberVideoDisableWarning,
    OTSubscriberVideoDisableWarningLifted,
};

typedef NS_ENUM(NSInteger, OTVideoViewContentMode) {
    OTVideoViewFill,
    OTVideoViewFit
};

typedef void (^OTOneToOneCommunicatorBlock)(OTOneToOneCommunicationSignal signal, NSError *error);

@protocol OTOneToOneCommunicatorDelegate <NSObject>
- (void)oneToOneCommunicationWithSignal:(OTOneToOneCommunicationSignal)signal
                                  error:(NSError *)error;
@end

@interface OTOneToOneCommunicator: NSObject

/**
 *  @return Returns the shared OTOneToOneCommunicator object.
 */
+ (instancetype)sharedInstance;

/**
 *  A string that represents the current communicator.
 *  If not specified, the value will be "system name-name specified by Setting", e.g. @"iOS-MyiPhone"
 */
@property (nonatomic) NSString *publisherName;

/**
 *  Registers to the shared session: [OTAcceleratorSession] and perform publishing/subscribing automatically.
 *
 *  @return An error to indicate whether it connects successfully, non-nil if it fails.
 */
- (NSError *)connect;

/**
 *  An alternative connect method with a completion block handler.
 *
 *  @param handler The completion handler to call with the change.
 */
- (void)connectWithHandler:(OTOneToOneCommunicatorBlock)handler;

/**
 *  De-registers to the shared session: [OTAcceleratorSession] and stops publishing/subscriber.
 *
 *  @return An error to indicate whether it disconnects successfully, non-nil if it fails.
 */
- (NSError *)disconnect;

/**
 *  The object that acts as the delegate of the screen sharer.
 *
 *  The delegate must adopt the OTOneToOneCommunicatorDelegate protocol. The delegate is not retained.
 */
@property (weak, nonatomic) id<OTOneToOneCommunicatorDelegate> delegate;

/**
 *  A boolean value to indicate whether the call is enabled. `YES` once the publisher connects or after OTSessionDidConnect being signaled.
 */
@property (readonly, nonatomic) BOOL isCallEnabled;

#pragma mark - subscriber
/**
 *  The view containing a playback buffer for associated video data. Add this view to your view heirarchy to display a video stream.
 *
 *  The subscriber view is available after OTSubscriberDidConnect being signaled.
 */
@property (readonly, nonatomic) UIView *subscriberView;

/**
 *  The scaling of the rendered video, as defined by the <OTVideoViewContentMode> enum.
 *  The default value is OTVideoViewScaleBehaviorFill.
 *  Set it to OTVideoViewScaleBehaviorFit to have the video shrink, as needed, so that the entire video is visible(with pillarboxing).
 */
@property (nonatomic) OTVideoViewContentMode subscriberVideoContentMode;

/**
 *  A boolean value to indicate whether the communicator has available audio from subscription.
 *  This property will take the stream's hasAudio into account internally.
 */
@property (nonatomic, getter=isSubscribeToAudio) BOOL subscribeToAudio;

/**
 *  A boolean value to indicate whether the communicator has available video from subscription.
 *  This property will take the stream's hasVideo into account internally.
 */
@property (nonatomic, getter=isSubscribeToVideo) BOOL subscribeToVideo;

#pragma mark - publisher
/**
 *  The view for this publisher. If this view becomes visible, it will display a preview of the active camera feed.
 * 
 *  The publisher view is available after OTSessionDidConnect being signaled.
 */
@property (readonly, nonatomic) UIView *publisherView;

/**
 *  A boolean value to indicate whether to publish audio.
 */
@property (nonatomic, getter=isPublishAudio) BOOL publishAudio;

/**
 *  A boolean value to indicate whether to publish video.
 */
@property (nonatomic, getter=isPublishVideo) BOOL publishVideo;

/**
 *  The preferred camera position. When setting this property, if the change is possible, the publisher will use the camera with the specified position. 
 *  If the publisher has begun publishing, getting this property returns the current camera position; 
 *  if the publisher has not yet begun publishing, getting this property returns the preferred camera position.
 */
@property (nonatomic) AVCaptureDevicePosition cameraPosition;

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
