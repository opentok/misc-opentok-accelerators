//
//  APSession.m
//  APSessionDemo
//
//  Created by Xi Huang on 4/7/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "AcceleratorPackSession.h"

@interface AcceleratorPackSession() <OTSessionDelegate>
@property (nonatomic) NSString *apiKey;
@property (nonatomic) NSString *sessionId;
@property (nonatomic) NSString *token;

@property (nonatomic) NSMutableSet<id<APBroadcastDelegate>> *delegates;
@property (nonatomic) OTSession *oneSharedSession;
@end

@implementation AcceleratorPackSession

+ (instancetype)sharedSession {
    
    static AcceleratorPackSession *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AcceleratorPackSession alloc] init];
        sharedInstance.delegates = [[NSMutableSet alloc] init];
    });
    return sharedInstance;
}

+ (void)setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token {
    
    AcceleratorPackSession *sharedSession = [AcceleratorPackSession sharedSession];
    sharedSession.apiKey = apiKey;
    sharedSession.sessionId = sessionId;
    sharedSession.token = token;
    
    NSAssert(sharedSession.apiKey.length != 0, @"OpenTok: API key can not be empty, please add it to OneToOneCommunicator");
    NSAssert(sharedSession.sessionId.length != 0, @"OpenTok: Session Id can not be empty, please add it to OneToOneCommunicator");
    NSAssert(sharedSession.token.length != 0, @"OpenTok: Token can not be empty, please add it to OneToOneCommunicator");
}

+ (void)registerWithAccePack:(id)delegate {
    
    [[AcceleratorPackSession sharedSession].delegates addObject:delegate];
}

+ (NSError *)connect {
    
    AcceleratorPackSession *sharedSession = [AcceleratorPackSession sharedSession];
    
    if (!sharedSession.oneSharedSession) {
        NSString *apiKey = sharedSession.apiKey;
        NSString *sessionId = sharedSession.sessionId;
        NSString *token = sharedSession.token;
        sharedSession.oneSharedSession = [[OTSession alloc] initWithApiKey:apiKey sessionId:sessionId delegate:sharedSession];
        
        OTError *error;
        [[AcceleratorPackSession sharedSession].oneSharedSession connectWithToken:token error:&error];
        return error;
    }
    return nil;
}

+ (NSError *)disconnect {
    
    OTError *error;
    [[AcceleratorPackSession sharedSession].oneSharedSession disconnect:&error];
    return error;
}

+ (void)signalWithType:(NSString*) type
                string:(NSString*)string
            connection:(OTConnection*)connection
                 error:(OTError**)error {
    
    
    [[AcceleratorPackSession sharedSession].oneSharedSession signalWithType:type
                                                                     string:string
                                                                 connection:connection
                                                                      error:error];
}

#pragma mark - OTSessionDelegate
-(void)sessionDidConnect:(OTSession*)session {
    for (id delegate in self.delegates) {
        [delegate sessionDidConnect:session];
    }
}

- (void)sessionDidDisconnect:(OTSession *)session {
    for (id delegate in self.delegates) {
        [delegate sessionDidDisconnect:session];
    }
}

- (void)session:(OTSession *)session streamCreated:(OTStream *)stream {
    
    for (id delegate in self.delegates) {
        [delegate session:session streamCreated:stream];
    }
}

- (void)session:(OTSession *)session streamDestroyed:(OTStream *)stream {
    
    for (id delegate in self.delegates) {
        [delegate session:session streamDestroyed:stream];
    }
}

- (void)session:(OTSession *)session didFailWithError:(OTError *)error {
    
    for (id delegate in self.delegates) {
        [delegate session:session didFailWithError:error];
    }
}

#pragma mark - OTPublisherDelegate
- (void)publisher:(OTPublisherKit *)publisher didFailWithError:(OTError *)error {
    
    
    for (id delegate in self.delegates) {
        [delegate publisher:publisher didFailWithError:error];
    }
}

#pragma mark - OTSubscriberKitDelegate
-(void) subscriberDidConnectToStream:(OTSubscriberKit*)subscriber {
    
    for (id delegate in self.delegates) {
        [delegate subscriberDidConnectToStream:subscriber];
    }
}

-(void)subscriberVideoDisabled:(OTSubscriber *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    
    for (id delegate in self.delegates) {
        [delegate subscriberVideoDisabled:subscriber reason:reason];
    }
}

- (void)subscriberVideoEnabled:(OTSubscriberKit *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    
    for (id delegate in self.delegates) {
        [delegate subscriberVideoEnabled:subscriber reason:reason];
    }
}

-(void) subscriberVideoDisableWarning:(OTSubscriber *)subscriber reason:(OTSubscriberVideoEventReason)reason {
 
    for (id delegate in self.delegates) {
        [delegate subscriberVideoDisableWarning:subscriber reason:reason];
    }
}


-(void) subscriberVideoDisableWarningLifted:(OTSubscriberKit *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    
    for (id delegate in self.delegates) {
        [delegate subscriberVideoDisableWarningLifted:subscriber reason:reason];
    }
}

- (void)subscriber:(OTSubscriberKit *)subscriber didFailWithError:(OTError *)error {
    
    for (id delegate in self.delegates) {
        [delegate subscriber:subscriber didFailWithError:error];
    }
}

@end
