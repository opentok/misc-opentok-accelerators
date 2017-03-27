//
//  OTMultiPartyScreenSharer.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTAcceleratorSession.h"
#import "OTVideoView.h"
#import "OTCommonCommunicator.h"

@class OTMultiPartyScreenSharer;
@class OTMultiPartyScreenShareRemote;

typedef void (^OTMultiPartyScreenSharerBlock)(OTCommunicationSignal signal, OTMultiPartyScreenShareRemote *subscriber, NSError *error);

@protocol OTMultiPartyScreenSharerDataSource <NSObject>
- (OTAcceleratorSession *)sessionOfOTMultiPartyScreenSharer:(OTMultiPartyScreenSharer *)multiPartyScreenSharer;
@end

@interface OTMultiPartyScreenSharer : NSObject

/**
 *  The object that acts as the data source of the communicator.
 *
 *  The delegate must adopt the OTOneToOneCommunicatorDataSource protocol. The delegate is not retained.
 */
@property (weak, nonatomic) id<OTMultiPartyScreenSharerDataSource> dataSource;

/**
 *  Initialize a new `OTMultiPartyScreenSharer` instsance with a publisher name.
 *
 *  @return A new `OTMultiPartyScreenSharer` instsance.
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
                handler:(OTMultiPartyScreenSharerBlock)handler;

/**
 *  De-registers to the shared session: [OTAcceleratorSession] and stops publishing/subscriber.
 *
 *  @return An error to indicate whether it disconnects successfully, non-nil if it fails.
 */
- (NSError *)disconnect;

/**
 *  A boolean value that indicates whether the specified UIView is sharing.
 */
@property (readonly, nonatomic) BOOL isScreenSharing;

/**
 *  `YES` means that it won't subscribe to any streams, default is `NO`. 
 *  Turning it `NO` will make it subscribe to available streams.
 *  Turning it `YES` will unsubscribe and remove all subscribers
 */
@property (nonatomic, getter=isPublishOnly) BOOL publishOnly;

#pragma mark - publisher
/**
 *  The view for this publisher. If this view becomes visible, it will display a preview of the active camera feed.
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

/**
 *  The preferred camera position. When setting this property, if the change is possible, the publisher will use the camera with the specified position.
 *  If the publisher has begun publishing, getting this property returns the current camera position;
 *  if the publisher has not yet begun publishing, getting this property returns the preferred camera position.
 */
@property (nonatomic) AVCaptureDevicePosition cameraPosition;

@end

@interface OTMultiPartyScreenShareRemote : NSObject

/**
 *  The view containing a playback buffer for associated video data. Add this view to your view heirarchy to display a video stream.
 *
 *  The subscriber view is available after OTSubscriberDidConnect being signaled.
 */
@property (readonly, nonatomic) OTVideoView *subscriberView;

/**
 *  The scaling of the rendered video, as defined by the <OTVideoViewContentMode> enum.
 *  The default value is OTVideoViewScaleBehaviorFill.
 *  Set it to OTVideoViewScaleBehaviorFit to have the video shrink, as needed, so that the entire video is visible(with pillarboxing).
 */
@property (nonatomic) OTVideoViewContentMode subscriberVideoContentMode;

/**
 *  A boolean value to indicate whether the communicator has audio available.
 */
@property (nonatomic, readonly) BOOL isRemoteAudioAvailable;

/**
 *  A boolean value to indicate whether the communicator has video available.
 */
@property (nonatomic, readonly) BOOL isRemoteVideoAvailable;

/**
 *  A boolean value to indicate whether the communicator subscript to audio.
 */
@property (nonatomic, getter=isSubscribeToAudio) BOOL subscribeToAudio;

/**
 *  A boolean value to indicate whether the communicator subscript to video.
 */
@property (nonatomic, getter=isSubscribeToVideo) BOOL subscribeToVideo;

@property (readonly, nonatomic) NSString *userInfo;

@end
