//
//  TextChatComponentChatView.h
//  TextChatComponent
//
//  Created by Xi Huang on 2/23/16.
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

+ (instancetype)communicator;
+ (void)setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token;

- (void)connect;
- (void)connectWithHandler:(OTOneToOneCommunicatorBlock)handler;
- (void)disconnect;

@property (weak, nonatomic) id<OTOneToOneCommunicatorDelegate> delegate;

// CALL
@property (readonly, nonatomic) BOOL isCallEnabled;

// SUBSCRIBER
@property (readonly, nonatomic) UIView *subscriberView;
@property (nonatomic) BOOL subscribeToAudio;
@property (nonatomic) BOOL subscribeToVideo;

// PUBLISHER
@property (readonly, nonatomic) UIView *publisherView;
@property (nonatomic) BOOL publishAudio;
@property (nonatomic) BOOL publishVideo;
@property (nonatomic) AVCaptureDevicePosition cameraPosition;

@end
