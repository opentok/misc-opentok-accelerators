//
//  OTScreenSharer.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OTScreenShareKit/OTRemoteAnnotator.h>

typedef NS_ENUM(NSUInteger, ScreenShareSignal) {
    ScreenShareSignalSessionDidConnect = 0,
    ScreenShareSignalSessionDidDisconnect,
    ScreenShareSignalSessionDidFail,
    ScreenShareSignalSessionStreamCreated,
    ScreenShareSignalSessionStreamDestroyed,
    ScreenShareSignalPublisherDidFail,
    ScreenShareSignalSubscriberConnect,
    ScreenShareSignalSubscriberDidFail,
    ScreenShareSignalSubscriberVideoDisabled,
    ScreenShareSignalSubscriberVideoEnabled,
    ScreenShareSignalSubscriberVideoDisableWarning,
    ScreenShareSignalSubscriberVideoDisableWarningLifted,
};

typedef void (^ScreenShareBlock)(ScreenShareSignal signal, NSError *error);

@protocol ScreenShareDelegate <NSObject>
- (void)screenShareWithSignal:(ScreenShareSignal)signal
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
+ (instancetype)screenSharer;

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
- (void)connectWithView:(UIView *)view;

/**
 *  Start sharing with a specified UIView, notifying change by the handler block.
 *
 *  @param view    The UIView to be shared.
 *  @param handler The completion handler to call with the change.
 */
- (void)connectWithView:(UIView *)view
                handler:(ScreenShareBlock)handler;

/**
 *  Stop sharing.
 */
- (void)disconnect;

/**
 *  Change the sharing UIView, it does nothing if sharing is not started.
 */
- (void)updateView:(UIView *)view;

/**
 *  The object that acts as the delegate of the screen sharer.
 *
 *  The delegate must adopt the ScreenShareDelegate protocol. The delegate is not retained.
 */
@property (weak, nonatomic) id<ScreenShareDelegate> delegate;

// SUBSCRIBER
@property (readonly, nonatomic) UIView *subscriberView;
@property (nonatomic, getter=isSubscribeToAudio) BOOL subscribeToAudio;
@property (nonatomic, getter=isSubscribeToVideo) BOOL subscribeToVideo;

// PUBLISHER
@property (readonly, nonatomic) UIView *publisherView;
@property (nonatomic, getter=isPublishAudio) BOOL publishAudio;
@property (nonatomic, getter=isPublishVideo) BOOL publishVideo;

#pragma mark - Remote control
@property (nonatomic) OTRemoteAnnotator *remoteAnnotator;
- (void)initializeRemoteAnnotator;
@end
