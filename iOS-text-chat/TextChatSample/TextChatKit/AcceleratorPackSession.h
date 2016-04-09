//
//  APSession.h
//  APSessionDemo
//
//  Created by Xi Huang on 4/7/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenTok/OpenTok.h>


@protocol APBroadcastDelegate <NSObject>
- (void)sessionDidConnect:(OTSession*)session;

- (void)sessionDidDisconnect:(OTSession *)session;

- (void)session:(OTSession *)session
  streamCreated:(OTStream *)stream;

- (void)session:(OTSession *)session
streamDestroyed:(OTStream *)stream;

- (void)session:(OTSession *)session
didFailWithError:(OTError *)error;

- (void)publisher:(OTPublisherKit *)publisher
 didFailWithError:(OTError *)error;

- (void)subscriberDidConnectToStream:(OTSubscriberKit*)subscriber;

- (void)subscriberVideoDisabled:(OTSubscriber *)subscriber
                         reason:(OTSubscriberVideoEventReason)reason;

- (void)subscriberVideoEnabled:(OTSubscriberKit *)subscriber
                        reason:(OTSubscriberVideoEventReason)reason;

- (void)subscriberVideoDisableWarning:(OTSubscriber *)subscriber
                               reason:(OTSubscriberVideoEventReason)reason;

- (void)subscriberVideoDisableWarningLifted:(OTSubscriberKit *)subscriber
                                     reason:(OTSubscriberVideoEventReason)reason;

- (void)subscriber:(OTSubscriberKit *)subscriber
  didFailWithError:(OTError *)error;
@end



@interface AcceleratorPackSession : NSObject

+ (void)setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token;
+ (void)registerWithAccePack:(id<APBroadcastDelegate>)delegate;
+ (NSError *)connect;
+ (NSError *)disconnect;

+ (void)signalWithType:(NSString*) type
                string:(NSString*)string
            connection:(OTConnection*)connection
                 error:(OTError**)error;

@end
