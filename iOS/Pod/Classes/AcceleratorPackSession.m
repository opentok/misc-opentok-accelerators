//
//  APSession.m
//  APSessionDemo
//
//  Created by Xi Huang on 4/7/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "AcceleratorPackSession.h"

static NSString * InternalApiKey = @"";
static NSString * InternalSessionId = @"";
static NSString * InternalToken = @"";

@interface AcceleratorPackSession() <OTSessionDelegate>
@property (nonatomic) NSString *apiKey;
@property (nonatomic) NSString *token;

@property (nonatomic) NSMutableSet <id<OTSessionDelegate>> *delegates;
@end

@implementation AcceleratorPackSession

- (NSString *)apiKey {
    return InternalApiKey;
}

- (NSString *)sessionId {
    return InternalToken;
}

+ (NSSet<id<OTSessionDelegate>> *)getRegisters {
    return [[AcceleratorPackSession getAcceleratorPackSession].delegates copy];
}

+ (instancetype)getAcceleratorPackSession {
    
    static AcceleratorPackSession *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[AcceleratorPackSession alloc] initWithApiKey:InternalApiKey
                                                              sessionId:InternalSessionId
                                                               delegate:nil];
        sharedInstance.delegate = sharedInstance;
        sharedInstance.delegates = [[NSMutableSet alloc] init];
    });
    return sharedInstance;
}

+ (void)setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token {
    
    InternalApiKey = apiKey;
    InternalSessionId = sessionId;
    InternalToken = token;
    
    NSAssert(InternalApiKey.length != 0, @"OpenTok: API key can not be empty, please add it to OneToOneCommunicator");
    NSAssert(InternalSessionId.length != 0, @"OpenTok: Session Id can not be empty, please add it to OneToOneCommunicator");
    NSAssert(InternalToken.length != 0, @"OpenTok: Token can not be empty, please add it to OneToOneCommunicator");
}

+ (void)registerWithAccePack:(id)delegate {
    
    AcceleratorPackSession *session = [AcceleratorPackSession getAcceleratorPackSession];
    
    if ([delegate conformsToProtocol:@protocol(OTSessionDelegate)]) {
        [session.delegates addObject:delegate];
    }

    OTError *error = [AcceleratorPackSession connect];
    if (error) {
        NSLog(@"AcceleratorSesssion Error: %@", error.localizedDescription);
    }
}

+ (void)deregisterWithAccePack:(id)delegate {
    
    AcceleratorPackSession *session = [AcceleratorPackSession getAcceleratorPackSession];
    
    if ([session.delegates containsObject:delegate]) {
        [session.delegates removeObject:delegate];
    }

    if (session.delegates.count == 0) {
        OTError *error = [AcceleratorPackSession disconnect];
        if (error) {
            NSLog(@"AcceleratorSesssion Error: %@", error.localizedDescription);
        }
    }
}

+ (BOOL)containsAccePack:(id)delegate {
    
    AcceleratorPackSession *session = [AcceleratorPackSession getAcceleratorPackSession];
    return [session.delegates containsObject:delegate];
}

+ (OTError *)connect {
    
    AcceleratorPackSession *sharedSession = [AcceleratorPackSession getAcceleratorPackSession];
    
    if (sharedSession.sessionConnectionStatus == OTSessionConnectionStatusConnected ||
        sharedSession.sessionConnectionStatus == OTSessionConnectionStatusConnecting ||
        sharedSession.sessionConnectionStatus == OTSessionConnectionStatusReconnecting) return nil;
    
    OTError *error;
    [sharedSession connectWithToken:InternalToken error:&error];
    return error;
}

+ (OTError *)disconnect {
    
    AcceleratorPackSession *sharedSession = [AcceleratorPackSession getAcceleratorPackSession];
    
    if (sharedSession.sessionConnectionStatus == OTSessionConnectionStatusNotConnected ||
        sharedSession.sessionConnectionStatus == OTSessionConnectionStatusDisconnecting) return nil;
    
    OTError *error;
    [sharedSession disconnect:&error];
    return error;
}

#pragma mark - OTSessionDelegate
-(void)sessionDidConnect:(OTSession*)session {
    
    
    [self.delegates enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {
        
        if ([obj respondsToSelector:@selector(sessionDidConnect:)]) {
            [obj sessionDidConnect:session];
        }
    }];
}

- (void)sessionDidDisconnect:(OTSession *)session {
    
    
    [self.delegates enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {
        
        if ([obj respondsToSelector:@selector(sessionDidDisconnect:)]) {
            [obj sessionDidDisconnect:session];
        }
    }];
}

- (void)session:(OTSession *)session didFailWithError:(OTError *)error {

    [self.delegates enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {
        
        if ([obj respondsToSelector:@selector(session:didFailWithError:)]) {
            [obj session:session didFailWithError:error];
        }
    }];
}

- (void)session:(OTSession *)session streamCreated:(OTStream *)stream {
    
    [self.delegates enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {
        
        if ([obj respondsToSelector:@selector(session:streamCreated:)]) {
            [obj session:session streamCreated:stream];
        }
    }];
}

- (void)session:(OTSession *)session streamDestroyed:(OTStream *)stream {
    
    [self.delegates enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {

        if ([obj respondsToSelector:@selector(session:streamDestroyed:)]) {
            [obj session:session streamDestroyed:stream];
        }
    }];
}

- (void)  session:(OTSession*) session
connectionCreated:(OTConnection*) connection {
    
    [self.delegates enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {
        
        if ([obj respondsToSelector:@selector(session:connectionCreated:)]) {
            [obj session:session connectionCreated:connection];
        }
    }];
}

- (void)session:(OTSession*) session
connectionDestroyed:(OTConnection*) connection {
    
    [self.delegates enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {
    
        if ([obj respondsToSelector:@selector(session:connectionDestroyed:)]) {
            [obj session:session connectionDestroyed:connection];
        }
    }];
}

- (void)session:(OTSession*)session
receivedSignalType:(NSString*)type
    fromConnection:(OTConnection*)connection
        withString:(NSString*)string {
    
    
    [self.delegates enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {
        
        if ([obj respondsToSelector:@selector(session:receivedSignalType:fromConnection:withString:)]) {
            [obj session:session receivedSignalType:type fromConnection:connection withString:string];
        }
    }];
}

@end
