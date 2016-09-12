//
//  OTScreenSharer.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, OTScreenShareSignal) {
    OTScreenShareSignalSessionDidConnect = 0,
    OTScreenShareSignalSessionDidDisconnect,
    OTScreenShareSignalSessionDidFail,
    OTScreenShareSignalSessionStreamCreated,
    OTScreenShareSignalSessionStreamDestroyed,
    OTScreenShareSignalPublisherDidFail,
    OTScreenShareSignalSubscriberConnect,
    OTScreenShareSignalSubscriberDidFail,
    OTScreenShareSignalSubscriberVideoDisabled,
    OTScreenShareSignalSubscriberVideoEnabled,
    OTScreenShareSignalSubscriberVideoDisableWarning,
    OTScreenShareSignalSubscriberVideoDisableWarningLifted,
};

typedef NS_ENUM(NSInteger, OTScreenShareVideoViewContentMode) {
    OTScreenShareVideoViewFit,
    OTScreenShareVideoViewFill
};

typedef void (^OTScreenShareBlock)(OTScreenShareSignal signal, NSError *error);

@protocol OTScreenShareDelegate <NSObject>
- (void)screenShareWithSignal:(OTScreenShareSignal)signal
                        error:(NSError *)error;
@end

@interface OTScreenSharer : NSObject

/**
 *  A boolean value that indicates whether the specified UIView is sharing.
 */
@property (readonly, nonatomic) BOOL isScreenSharing;

/**
 *  @return Returns the shared OTScreenSharer object.
 */
+ (instancetype)sharedInstance;

/**
 *  Add the configuration detail to your app.
 *
 *  @param apiKey   Your OpenTok API key.
 *  @param sessionId    The session ID of this instance.
 *  @param token    The token generated for this connection.
 */
+ (void)setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token;

/**
 *  Start sharing with a specified UIView.
 *
 *  @param view The UIView to be shared
 */
- (NSError *)connectWithView:(UIView *)view;

/**
 *  Start sharing with a specified UIView, notifying change by the handler block.
 *
 *  @param view    The UIView to be shared.
 *  @param handler The completion handler to call with the change.
 */
- (void)connectWithView:(UIView *)view
                handler:(OTScreenShareBlock)handler;

/**
 *  Stop sharing.
 */
- (NSError *)disconnect;

/**
 *  Change the sharing UIView, it does nothing if sharing is not started.
 */
- (void)updateView:(UIView *)view;

/**
 *  The object that acts as the delegate of the screen sharer.
 *
 *  The delegate must adopt the ScreenShareDelegate protocol. The delegate is not retained.
 */
@property (weak, nonatomic) id<OTScreenShareDelegate> delegate;

// SUBSCRIBER
@property (nonatomic) OTScreenShareVideoViewContentMode subscriberVideoContentMode;
@property (readonly, nonatomic) CGSize subscriberVideoDimension;
@property (readonly, nonatomic) UIView *subscriberView;
@property (nonatomic, getter=isSubscribeToAudio) BOOL subscribeToAudio;
@property (nonatomic, getter=isSubscribeToVideo) BOOL subscribeToVideo;

// PUBLISHER
@property (readonly, nonatomic) UIView *publisherView;
@property (nonatomic, getter=isPublishAudio) BOOL publishAudio;
@property (nonatomic, getter=isPublishVideo) BOOL publishVideo;

@end
