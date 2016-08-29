//
//  TextChatComponentChatView.h
//
//  Copyright © 2016 Tokbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, OTOneToOneCommunicationSignal) {
    OTSessionDidConnect = 0,
    OTSessionDidDisconnect,
    OTSessionDidFail,
    OTSessionStreamCreated,
    OTSessionStreamDestroyed,
    OTPublisherDidFail,
    OTPublisherStreamCreated,
    OTPublisherStreamDestroyed,
    OTSubscriberConnect,
    OTSubscriberDidFail,
    OTSubscriberVideoDisabled,
    OTSubscriberVideoEnabled,
    OTSubscriberVideoDisableWarning,
    OTSubscriberVideoDisableWarningLifted,
};

typedef void (^OTOneToOneCommunicatorBlock)(OTOneToOneCommunicationSignal signal, NSError *error);

@protocol OTOneToOneCommunicatorDelegate <NSObject>
- (void)oneToOneCommunicationWithSignal:(OTOneToOneCommunicationSignal)signal
                                  error:(NSError *)error;
@end

@interface OTOneToOneCommunicator : NSObject

+ (instancetype)sharedInstance;
+ (void)setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token;

- (NSError *)connect;
- (void)connectWithHandler:(OTOneToOneCommunicatorBlock)handler;
- (NSError *)disconnect;

@property (weak, nonatomic) id<OTOneToOneCommunicatorDelegate> delegate;

// CALL
@property (readonly, nonatomic) BOOL isCallEnabled;

// SUBSCRIBER
@property (readonly, nonatomic) UIView *subscriberView;
@property (nonatomic, getter=isSubscribeToAudio) BOOL subscribeToAudio;
@property (nonatomic, getter=isSubscribeToVideo) BOOL subscribeToVideo;

// PUBLISHER
@property (nonatomic) NSString *publisherName;
@property (readonly, nonatomic) UIView *publisherView;
@property (nonatomic, getter=isPublishAudio) BOOL publishAudio;
@property (nonatomic, getter=isPublishVideo) BOOL publishVideo;
@property (nonatomic) AVCaptureDevicePosition cameraPosition;

@end
