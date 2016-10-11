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

@interface OTTextChat() <OTSessionDelegate> {
    OTConnection *receiverConnection;
}

@property (nonatomic) OTAcceleratorSession *session;
@property (strong, nonatomic) OTTextChatViewEventBlock handler;

@property (nonatomic) NSString *connectionId;
@property (nonatomic) NSString *receiverAlias;

@property (nonatomic) OTKLogger *logger;

@end

@implementation OTTextChat

- (instancetype)init {
    
    if (self = [super init]) {
        self.session = [OTAcceleratorSession getAcceleratorPackSession];
        
        if (![OTTestingInfo isTesting]) {
            _logger = [[OTKLogger alloc] initWithClientVersion:KLogClientVersion
                                                        source:[[NSBundle mainBundle] bundleIdentifier]
                                                   componentId:kLogComponentIdentifier
                                                          guid:[[NSUUID UUID] UUIDString]];
            
            [_logger logEventAction:KLogActionInitialize variation:KLogVariationSuccess completion:nil];
        }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)connect {
    
    if (![OTTestingInfo isTesting]) {
        [_logger logEventAction:KLogActionStart
                      variation:KLogVariationAttempt
                     completion:nil];
    }
    
    NSError *connectionError = [OTAcceleratorSession registerWithAccePack:self];
    if(connectionError){
        
        if (![OTTestingInfo isTesting]) {
            [_logger logEventAction:KLogActionStart
                          variation:KLogVariationFailure
                         completion:nil];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectWithError:)]) {
            [self.delegate didConnectWithError:connectionError];
        }
        
        if (self.handler) {
            self.handler(OTTextChatViewEventSignalDidConnect, nil, connectionError);
        }
    }
    else {
        
        if (![OTTestingInfo isTesting]) {
            [_logger logEventAction:KLogActionStart
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
        [_logger logEventAction:KLogActionEnd
                      variation:KLogVariationAttempt
                     completion:nil];
    }
    
    NSError *disconnectionError = [OTAcceleratorSession deregisterWithAccePack:self];
    if(disconnectionError){
        
        if (![OTTestingInfo isTesting]) {
            [_logger logEventAction:KLogActionEnd
                          variation:KLogVariationFailure
                         completion:nil];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDisConnectWithError:)]) {
            [self.delegate didDisConnectWithError:disconnectionError];
        }
        
        if (self.handler) {
            self.handler(OTTextChatViewEventSignalDidDisconnect, nil, disconnectionError);
        }
    }
    else {
        
        if (![OTTestingInfo isTesting]) {
            [_logger logEventAction:KLogActionEnd
                          variation:KLogVariationSuccess
                         completion:nil];
        }
    }
}

- (void)sendMessage:(NSString *)message {
    NSError *error;
    
    if (![OTTestingInfo isTesting]) {
        [_logger logEventAction:KLogActionSendMessage
                      variation:KLogVariationAttempt
                     completion:nil];
    }
    
    if (!message || !message.length) {
        error = [NSError errorWithDomain:NSCocoaErrorDomain
                                    code:-1
                                userInfo:@{NSLocalizedDescriptionKey:@"Message format is wrong. Text is empty or null"}];
        if (self.delegate) {
            [self.delegate didSendTextMessage:nil error:error];
        }
        
        if (![OTTestingInfo isTesting]) {
            [_logger logEventAction:KLogActionSendMessage
                          variation:KLogVariationFailure
                         completion:nil];
        }
        return;
    }
    
    if (self.session.sessionId) {
        
        OTTextMessage *textMessage = [[OTTextMessage alloc] initWithMessage:message alias:self.alias senderId:self.connectionId];
        
        NSString *jsonString = [textMessage getTextChatSignalJSONString];
        if (!jsonString) {
            if (self.delegate) {
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                     code:-1
                                                 userInfo:@{NSLocalizedDescriptionKey:@"Error in parsing sender data"}];
                [self.delegate didSendTextMessage:nil error:error];
            }
            
            if (![OTTestingInfo isTesting]) {
                [_logger logEventAction:KLogActionSendMessage
                              variation:KLogVariationFailure
                             completion:nil];
            }
            return;
        }
        
        [self.session signalWithType:kTextChatType
                              string:jsonString
                          connection:receiverConnection
                               error:&error];
        
        if (error) {
            
            if (![OTTestingInfo isTesting]) {
                [_logger logEventAction:KLogActionSendMessage
                              variation:KLogVariationFailure
                             completion:nil];
            }
            if (self.delegate) {
                [self.delegate didSendTextMessage:nil error:error];
            }
            return;
        }
        
        if (![OTTestingInfo isTesting]) {
            [_logger logEventAction:KLogActionSendMessage
                          variation:KLogVariationSuccess
                         completion:nil];
        }
        
        if (self.delegate) {
            [self.delegate didSendTextMessage:textMessage error:nil];
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
            [_logger logEventAction:KLogActionSendMessage
                          variation:KLogVariationFailure
                         completion:nil];
        }
        
        if (self.delegate) {
            [self.delegate didSendTextMessage:nil error:error];
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
        [_logger setSessionId:session.sessionId
                 connectionId:session.connection.connectionId
                    partnerId:@([self.session.apiKey integerValue])];
    }
    
    self.connectionId = session.connection.connectionId;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectWithError:)]) {
        [self.delegate didConnectWithError:nil];
    }
    
    if (self.handler) {
        self.handler(OTTextChatViewEventSignalDidConnect, nil, nil);
    }
}

- (void)sessionDidDisconnect:(OTSession*)session {
    
    NSLog(@"TextChatComponent sessionDidDisconnect");
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDisConnectWithError:)]) {
        [self.delegate didDisConnectWithError:nil];
    }
    
    if (self.handler) {
        self.handler(OTTextChatViewEventSignalDidDisconnect, nil, nil);
    }
}

- (void)session:(OTSession*)session didFailWithError:(OTError*)error {
    NSLog(@"didFailWithError: (%@)", error);
    if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectWithError:)]) {
        [self.delegate didConnectWithError:error];
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

- (void)session:(OTSession*)session
receivedSignalType:(NSString*)type
 fromConnection:(OTConnection*)connection
     withString:(NSString*)string {
    
    if (![connection.connectionId isEqualToString:self.session.connection.connectionId]) {
        
        if (![OTTestingInfo isTesting]) {
            [_logger logEventAction:KLogActionReceiveMessage
                          variation:KLogVariationAttempt
                         completion:nil];
        }
        
        OTTextMessage *textMessage = [[OTTextMessage alloc] initWithJSONString:string];
        
        if (!self.receiverAlias || ![self.receiverAlias isEqualToString:textMessage.alias]) {
            self.receiverAlias = textMessage.alias;
        }
        
        if (textMessage) {
            
            if (self.delegate) {
                [self.delegate didReceiveTextMessage:textMessage error:nil];
            }
            
            if (self.handler) {
                self.handler(OTTextChatViewEventSignalDidReceiveMessage, textMessage, nil);
            }
            
            if (![OTTestingInfo isTesting]) {
                [_logger logEventAction:KLogActionReceiveMessage
                              variation:KLogVariationSuccess
                             completion:nil];
            }
        }
        else {
            if (![OTTestingInfo isTesting]) {
                [_logger logEventAction:KLogActionReceiveMessage
                              variation:KLogVariationFailure
                             completion:nil];
            }
        }
    }
}

@end
