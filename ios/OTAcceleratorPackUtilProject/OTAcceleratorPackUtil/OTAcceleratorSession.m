//
//  APSession.m
//  APSessionDemo
//
//  Created by Xi Huang on 4/7/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "OTAcceleratorSession.h"

static NSString * InternalApiKey = nil;
static NSString * InternalSessionId = nil;
static NSString * InternalToken = nil;

@interface OTAcceleratorSession() <OTSessionDelegate>

@property (nonatomic) NSMutableSet <id<OTSessionDelegate>> *delegates;
// in order to signal sessionDidDisconnect: back to inactive registers
@property (nonatomic) NSMutableSet <id<OTSessionDelegate>> *inactiveDelegate;

@end

@implementation OTAcceleratorSession

static OTAcceleratorSession *sharedSession;

- (NSString *)apiKey {
    return InternalApiKey;
}

+ (NSSet<id<OTSessionDelegate>> *)getRegisters {
    return [[OTAcceleratorSession getAcceleratorPackSession].delegates copy];
}

+ (instancetype)getAcceleratorPackSession {
    return sharedSession;
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
    
    if (sharedSession.sessionConnectionStatus == OTSessionConnectionStatusConnected ||
        sharedSession.sessionConnectionStatus == OTSessionConnectionStatusConnecting) {
        
        OTError *error;
        [sharedSession disconnect:&error];
        if (error) {
            NSLog(@"AcceleratorSesssion Error: %@", error.localizedDescription);
        }
    }
    
    // re-init
    sharedSession = [[OTAcceleratorSession alloc] initWithApiKey:InternalApiKey
                                                        sessionId:InternalSessionId
                                                         delegate:nil];
    sharedSession.delegate = sharedSession;
    sharedSession.delegates = [[NSMutableSet alloc] init];
    sharedSession.inactiveDelegate = [[NSMutableSet alloc] init];
}

+ (NSError *)registerWithAccePack:(id)delegate {
    
    OTAcceleratorSession *sharedSession = [OTAcceleratorSession getAcceleratorPackSession];
    
    if ([delegate conformsToProtocol:@protocol(OTSessionDelegate)]) {
        if ([sharedSession.inactiveDelegate containsObject:delegate]) {
            [sharedSession.inactiveDelegate removeObject:delegate];
        }
        [sharedSession.delegates addObject:delegate];
    }
    
    // notify sessionDidConnect when session has connected
    if (sharedSession.sessionConnectionStatus == OTSessionConnectionStatusConnected) {
        [delegate sessionDidConnect:sharedSession];
        return nil;
    }
    
    if (sharedSession.sessionConnectionStatus == OTSessionConnectionStatusConnecting ||
        sharedSession.sessionConnectionStatus == OTSessionConnectionStatusReconnecting) return nil;
    
    OTError *error;
    [sharedSession connectWithToken:InternalToken error:&error];
    if (error) {
        NSLog(@"AcceleratorSesssion Error: %@", error.localizedDescription);
    }
    return error;
}

+ (NSError *)deregisterWithAccePack:(id)delegate {
    
    OTAcceleratorSession *sharedSession = [OTAcceleratorSession getAcceleratorPackSession];
    
    // notify sessionDidDisconnect to delegates who has de-registered
    if ([delegate conformsToProtocol:@protocol(OTSessionDelegate)] && [sharedSession.delegates containsObject:delegate]) {
        [sharedSession.delegates removeObject:delegate];
        [sharedSession.inactiveDelegate addObject:delegate];
    }

    if (sharedSession.delegates.count == 0) {
        
        if (sharedSession.sessionConnectionStatus == OTSessionConnectionStatusNotConnected ||
            sharedSession.sessionConnectionStatus == OTSessionConnectionStatusDisconnecting) return nil;
        
        OTError *error;
        [sharedSession disconnect:&error];
        if (error) {
            NSLog(@"AcceleratorSesssion Error: %@", error.localizedDescription);
        }
        return error;
    }
    return nil;
}

+ (BOOL)containsAccePack:(id)delegate {
    
    OTAcceleratorSession *session = [OTAcceleratorSession getAcceleratorPackSession];
    return [session.delegates containsObject:delegate];
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
    
    [self.inactiveDelegate enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {
        
        if ([obj respondsToSelector:@selector(sessionDidDisconnect:)]) {
            [obj sessionDidDisconnect:session];
        }
    }];
    
    [self.inactiveDelegate removeAllObjects];
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

- (void)     session:(OTSession*)session
archiveStartedWithId:(NSString*)archiveId
                name:(NSString*)name {
    
    [self.delegates enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {
        
        if ([obj respondsToSelector:@selector(session:receivedSignalType:fromConnection:withString:)]) {
            [obj session:session archiveStartedWithId:archiveId name:name];
        }
    }];
}

- (void)     session:(OTSession*)session
archiveStoppedWithId:(NSString*)archiveId {
    
    [self.delegates enumerateObjectsUsingBlock:^(id<OTSessionDelegate> obj, BOOL *stop) {
        
        if ([obj respondsToSelector:@selector(session:receivedSignalType:fromConnection:withString:)]) {
            [obj session:session archiveStoppedWithId:archiveId];
        }
    }];
}

@end
