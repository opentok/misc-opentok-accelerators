//
//  OTTextChatter.m
//  OTTextChatAccPackKit
//
//  Created by Xi Huang on 8/5/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTTextChat.h"

#import <OTAcceleratorPackUtil/OTAcceleratorPackUtil.h>
#import <OTKAnalytics/OTKLogger.h>

#import "OTTextMessage.h"
#import "OTTextMessage_Private.h"

#import "OTTextChatKitBundle.h"
#import "Constant.h"
#import "OTTestingInfo.h"

static NSString* const kTextChatType = @"text-chat";

@implementation OTTextChatConnection

- (instancetype)initWithConnectionId:(NSString *)connectionId
                        creationTime:(NSDate *)creationTime
                          customData:(NSString *)customData {
    if (self = [super init]) {
        _connectionId = connectionId;
        _creationTime = creationTime;
        _customdData = customData;
    }
    return self;
}

@end

@interface OTTextChat() <OTSessionDelegate> {
    OTConnection *receiverConnection;
}

@property (nonatomic) OTAcceleratorSession *session;
@property (strong, nonatomic) OTTextChatViewEventBlock handler;

@property (nonatomic) NSString *receiverAlias;
@property (nonatomic) OTTextChatConnection *connection;

@end

@implementation OTTextChat

+ (void)setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token {
    
    [OTAcceleratorSession setOpenTokApiKey:apiKey sessionId:sessionId token:token];
}

+ (instancetype)textChat {
    return [[OTTextChat alloc] init];
}

- (instancetype)init {
    if (![OTTestingInfo isTesting]) {
        [OTKLogger analyticsWithClientVersion:KLogClientVersion
                                       source:[[NSBundle mainBundle] bundleIdentifier]
                                  componentId:kLogComponentIdentifier
                                         guid:[[NSUUID UUID] UUIDString]];
    }
    
    if (![OTTestingInfo isTesting]) {
        [OTKLogger logEventAction:KLogActionInitialize variation:KLogVariationSuccess completion:nil];
    }
    
    if (self = [super init]) {
        _session = [OTAcceleratorSession getAcceleratorPackSession];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)connect {
    
    if (![OTTestingInfo isTesting]) {
        [OTKLogger logEventAction:KLogActionStart
                        variation:KLogVariationAttempt
                       completion:nil];
    }
    
    NSError *connectionError = [OTAcceleratorSession registerWithAccePack:self];
    if(connectionError){
        
        if (![OTTestingInfo isTesting]) {
            [OTKLogger logEventAction:KLogActionStart
                            variation:KLogVariationFailure
                           completion:nil];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(textChat:didConnectWithError:)]) {
            [self.delegate textChat:self didConnectWithError:connectionError];
        }
        
        if (self.handler) {
            self.handler(OTTextChatViewEventSignalDidConnect, nil, connectionError);
        }
    }
    else {
        
        if (![OTTestingInfo isTesting]) {
            [OTKLogger logEventAction:KLogActionStart
                            variation:KLogVariationSuccess
                           completion:nil];
        }
    }
}

- (void)connectWithHandler:(OTTextChatViewEventBlock)handler {
    self.handler = handler;
    [self connect];
}

- (void)disconnect {
    
    if (![OTTestingInfo isTesting]) {
        [OTKLogger logEventAction:KLogActionEnd
                        variation:KLogVariationAttempt
                       completion:nil];
    }
    
    NSError *disconnectionError = [OTAcceleratorSession deregisterWithAccePack:self];
    if(disconnectionError){
        
        if (![OTTestingInfo isTesting]) {
            [OTKLogger logEventAction:KLogActionEnd
                            variation:KLogVariationFailure
                           completion:nil];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(textChat:didDisConnectWithError:)]) {
            [self.delegate textChat:self didDisConnectWithError:disconnectionError];
        }
        
        if (self.handler) {
            self.handler(OTTextChatViewEventSignalDidDisconnect, nil, disconnectionError);
        }
    }
    else {
        
        if (![OTTestingInfo isTesting]) {
            [OTKLogger logEventAction:KLogActionEnd
                            variation:KLogVariationSuccess
                           completion:nil];
        }
    }
}

- (void)sendMessage:(NSString *)text {
    OTTextMessage *textMessage = [[OTTextMessage alloc] initWithMessage:text alias:self.alias senderId:self.connection.connectionId];
    [self sendCustomMessage:textMessage];
}

- (void)sendCustomMessage:(OTTextMessage *)textMessage {
    NSError *error;
    
    if (![OTTestingInfo isTesting]) {
        [OTKLogger logEventAction:KLogActionSendMessage variation:KLogVariationAttempt completion:nil];
    }
    
    if (!textMessage.text || !textMessage.text.length) {
        error = [NSError errorWithDomain:NSCocoaErrorDomain
                                    code:-1
                                userInfo:@{NSLocalizedDescriptionKey:@"Message format is wrong. Text is empty or null"}];
        if (self.delegate) {
            [self.delegate textChat:self didSendTextMessage:nil error:error];
        }
        
        if (![OTTestingInfo isTesting]) {
            [OTKLogger logEventAction:KLogActionSendMessage variation:KLogVariationFailure completion:nil];
        }
        return;
    }
    
    if (self.session.sessionId) {
        
        NSString *jsonString = [textMessage getTextChatSignalJSONString];
        if (!jsonString) {
            if (self.delegate) {
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                     code:-1
                                                 userInfo:@{NSLocalizedDescriptionKey:@"Error in parsing sender data"}];
                [self.delegate textChat:self didSendTextMessage:nil error:error];
            }
            
            if (![OTTestingInfo isTesting]) {
                [OTKLogger logEventAction:KLogActionSendMessage variation:KLogVariationFailure completion:nil];
            }
            return;
        }
        
        [self.session signalWithType:kTextChatType
                              string:jsonString
                          connection:receiverConnection
                               error:&error];
        
        if (error) {
            
            if (![OTTestingInfo isTesting]) {
                [OTKLogger logEventAction:KLogActionSendMessage variation:KLogVariationFailure completion:nil];
            }
            if (self.delegate) {
                [self.delegate textChat:self didSendTextMessage:nil error:error];
            }
            return;
        }
        
        if (![OTTestingInfo isTesting]) {
            [OTKLogger logEventAction:KLogActionSendMessage variation:KLogVariationSuccess completion:nil];
        }
        
        if (self.delegate) {
            [self.delegate textChat:self didSendTextMessage:textMessage error:nil];
        }
        
        if (self.handler) {
            self.handler(OTTextChatViewEventSignalDidSendMessage, textMessage, nil);
        }
    }
    else {
        error = [NSError errorWithDomain:NSCocoaErrorDomain
                                    code:-1
                                userInfo:@{NSLocalizedDescriptionKey:@"OTSession did not connect"}];
        
        if (![OTTestingInfo isTesting]) {
            [OTKLogger logEventAction:KLogActionSendMessage variation:KLogVariationFailure completion:nil];
        }
        
        if (self.delegate) {
            [self.delegate textChat:self didSendTextMessage:nil error:error];
        }
        
        if (self.handler) {
            self.handler(OTTextChatViewEventSignalDidSendMessage, nil, error);
        }
    }
}

#pragma mark - OTSessionDelegate
- (void)sessionDidConnect:(OTSession*)session {
    
    NSLog(@"TextChatComponent sessionDidConnect");
    
    if (![OTTestingInfo isTesting]) {
        [OTKLogger setSessionId:session.sessionId connectionId:session.connection.connectionId partnerId:@([self.session.apiKey integerValue])];
    }
    
    self.connection = [[OTTextChatConnection alloc] initWithConnectionId:session.connection.connectionId
                                                            creationTime:session.connection.creationTime
                                                              customData:session.connection.data];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(textChat:didConnectWithError:)]) {
        [self.delegate textChat:self didConnectWithError:nil];
    }
    
    if (self.handler) {
        self.handler(OTTextChatViewEventSignalDidConnect, nil, nil);
    }
}

- (void)sessionDidDisconnect:(OTSession*)session {
    
    NSLog(@"TextChatComponent sessionDidDisconnect");
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(textChat:didDisConnectWithError:)]) {
        [self.delegate textChat:self didDisConnectWithError:nil];
    }
    
    if (self.handler) {
        self.handler(OTTextChatViewEventSignalDidDisconnect, nil, nil);
    }
}

- (void)session:(OTSession*)session didFailWithError:(OTError*)error {
    NSLog(@"didFailWithError: (%@)", error);
    if (self.delegate && [self.delegate respondsToSelector:@selector(textChat:didConnectWithError:)]) {
        [self.delegate textChat:self didConnectWithError:error];
    }
    
    if (self.handler) {
        self.handler(OTTextChatViewEventSignalDidConnect, nil, error);
    }
}

- (void)session:(OTSession *)session streamCreated:(OTStream *)stream {}
- (void)session:(OTSession *)session streamDestroyed:(OTStream *)stream{}

- (void)session:(OTSession*) session connectionCreated:(OTConnection*)connection {
    
    // store receiverConnection for sending message to a point rather than boardcasting
    receiverConnection = connection;
}

- (void)session:(OTSession *)session connectionDestroyed:(OTConnection *)connection {
    
}

- (void)session:(OTSession*)session
receivedSignalType:(NSString*)type
 fromConnection:(OTConnection*)connection
     withString:(NSString*)string {
    
    if (![connection.connectionId isEqualToString:self.session.connection.connectionId]) {
        
        if (![OTTestingInfo isTesting]) {
            [OTKLogger logEventAction:KLogActionReceiveMessage variation:KLogVariationAttempt completion:nil];
        }
        
        OTTextMessage *textMessage = [[OTTextMessage alloc] initWithJSONString:string];
        
        if (!self.receiverAlias || ![self.receiverAlias isEqualToString:textMessage.alias]) {
            self.receiverAlias = textMessage.alias;
        }
        
        if (textMessage) {
            
            if (self.delegate) {
                [self.delegate textChat:self didReceiveTextMessage:textMessage error:nil];
            }
            
            if (self.handler) {
                self.handler(OTTextChatViewEventSignalDidReceiveMessage, textMessage, nil);
            }
            
            if (![OTTestingInfo isTesting]) {
                [OTKLogger logEventAction:KLogActionReceiveMessage variation:KLogVariationSuccess completion:nil];
            }
        }
        else {
            if (![OTTestingInfo isTesting]) {
                [OTKLogger logEventAction:KLogActionReceiveMessage variation:KLogVariationFailure completion:nil];
            }
        }
    }
}

@end
