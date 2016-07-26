//
//  OTTextMessageManager.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <OpenTok/OpenTok.h>

#import "OTTextMessageManager.h"
#import <OTAcceleratorPackUtil/OTAcceleratorPackUtil.h>
#import <OTKAnalytics/OTKLogger.h>

#import "OTTestingInfo.h"

static NSUInteger DefaultTextMessageLength = 120;
static NSUInteger MaximumTextMessageLength = 8196;

NSString* const kLogComponentIdentifier = @"textChatAccPack";
NSString* const KLogClientVersion = @"ios-vsol-1.0.0";
NSString* const KLogActionInitialize = @"Init";
NSString* const KLogActionStart = @"Start";
NSString* const KLogActionEnd = @"End";
NSString* const KLogActionOpen = @"OpenTC";
NSString* const KLogActionClose = @"CloseTC";
NSString* const KLogActionSendMessage = @"Send Msg";
NSString* const KLogActionReceiveMessage = @"Receive Msg";
NSString* const KLogActionSetMaxLength = @"SetMaxLength";
NSString* const KLogVariationAttempt = @"Attempt";
NSString* const KLogVariationSuccess = @"Success";
NSString* const KLogVariationFailure = @"Failure";

@interface OTTextMessageManager() <OTSessionDelegate>
@property (nonatomic) OTAcceleratorSession *session;

@property (nonatomic) NSMutableArray<OTTextMessage *> *mutableMessages;

@property (nonatomic) NSString *senderId;
@property (nonatomic) NSString *alias;
@property (nonatomic) NSString *receiverAlias;

@end

static NSString* const kTextChatType = @"text-chat";

@implementation OTTextMessageManager

- (NSArray<OTTextMessage *> *)messages {
    return [self.mutableMessages copy];
}

- (void)setAlias:(NSString *)alias {
    _alias = alias;
}

- (void)setMaximumTextMessageLength:(NSUInteger)maximumTextMessageLength {
    
    if (![OTTestingInfo isTesting]) {
        [OTKLogger logEventAction:KLogActionSetMaxLength variation:KLogVariationAttempt completion:nil];
    }
    
    if (maximumTextMessageLength > 8196) {
        _maximumTextMessageLength = DefaultTextMessageLength;
        
        if (![OTTestingInfo isTesting]) {
            [OTKLogger logEventAction:KLogActionSetMaxLength variation:KLogVariationFailure completion:nil];
        }
    }
    else {
        _maximumTextMessageLength = maximumTextMessageLength;
        
        if (![OTTestingInfo isTesting]) {
            [OTKLogger logEventAction:KLogActionSetMaxLength variation:KLogVariationSuccess completion:nil];
        }
    }
}

- (instancetype)init {
    if (self = [super init]) {
        _mutableMessages = [[NSMutableArray alloc] init];
        _session = [OTAcceleratorSession getAcceleratorPackSession];
        _maximumTextMessageLength = MaximumTextMessageLength;
        
        if (![OTTestingInfo isTesting]) {
            [OTKLogger logEventAction:KLogActionInitialize variation:KLogVariationSuccess completion:nil];
        }
    }
    return self;
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
    } else {
        
        if (![OTTestingInfo isTesting]) {
            [OTKLogger logEventAction:KLogActionStart
                            variation:KLogVariationSuccess
                           completion:nil];
        }
    }
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
    } else {
        
        if (![OTTestingInfo isTesting]) {
            [OTKLogger logEventAction:KLogActionEnd
                            variation:KLogVariationSuccess
                           completion:nil];
        }
    }
}

- (void)sendMessage:(NSString *)message {
    NSError *error;
    
    if (![OTTestingInfo isTesting]) {
        [OTKLogger logEventAction:KLogActionSendMessage variation:KLogVariationAttempt completion:nil];
    }
    
    if (!message || !message.length) {
        error = [NSError errorWithDomain:NSCocoaErrorDomain
                                    code:-1
                                userInfo:@{NSLocalizedDescriptionKey:@"Message format is wrong. Text is empty or null"}];
        if (self.delegate) {
            [self.delegate didAddTextChat:nil error:error];
        }
        
        if (![OTTestingInfo isTesting]) {
            [OTKLogger logEventAction:KLogActionSendMessage variation:KLogVariationFailure completion:nil];
        }
        return;
    }
    
    if (self.session.sessionId) {
        
        OTTextMessage *textChat = [[OTTextMessage alloc] initWithMessage:message alias:self.alias senderId:self.senderId];
        
        NSString *jsonString = [textChat getTextChatSignalJSONString];
        if (!jsonString) {
            if (self.delegate) {
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                     code:-1
                                                 userInfo:@{NSLocalizedDescriptionKey:@"Error in parsing sender data"}];
                [self.delegate didAddTextChat:nil error:error];
            }
            
            if (![OTTestingInfo isTesting]) {
                [OTKLogger logEventAction:KLogActionSendMessage variation:KLogVariationFailure completion:nil];
            }
            return;
        }
        
        [self.session signalWithType:kTextChatType
                              string:jsonString
                          connection:nil
                               error:&error];
        
        if (error) {
            
            if (![OTTestingInfo isTesting]) {
                [OTKLogger logEventAction:KLogActionSendMessage variation:KLogVariationFailure completion:nil];
            }
            if (self.delegate) {
                [self.delegate didAddTextChat:nil error:error];
            }
            return;
        }
        
        // determine new type
        if ([self.messages count] > 0) {
            
            OTTextMessage *prev = self.messages[self.messages.count - 1];
            
            // not sure why 120
            if ([textChat.dateTime timeIntervalSinceDate:prev.dateTime] < 120 &&
                [textChat.senderId isEqualToString:prev.senderId]) {
                
                if (textChat.type == TCMessageTypesReceived) {
                    textChat.type = TCMessageTypesReceivedShort;
                }
                else {
                    textChat.type = TCMessageTypesSentShort;
                }
            }
        }
        [self.mutableMessages addObject:textChat];
        
        if (![OTTestingInfo isTesting]) {
            [OTKLogger logEventAction:KLogActionSendMessage variation:KLogVariationSuccess completion:nil];
        }
        
        if (self.delegate) {
            [self.delegate didAddTextChat:textChat error:nil];
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
            [self.delegate didAddTextChat:nil error:error];
        }
    }
}

- (OTTextMessage *)getTextChatFromIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 0 || indexPath.row >= self.messages.count) {
        return nil;
    }
    return self.messages[indexPath.row];
}

#pragma mark - OTSessionDelegate
- (void)sessionDidConnect:(OTSession*)session {
    
    NSLog(@"TextChatComponent sessionDidConnect");
    
    if (![OTTestingInfo isTesting]) {
        [OTKLogger setSessionId:session.sessionId connectionId:session.connection.connectionId partnerId:@([self.session.apiKey integerValue])];
    }
    
    self.senderId = session.connection.connectionId;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectWithError:)]) {
        [self.delegate didConnectWithError:nil];
    }
}

- (void)sessionDidDisconnect:(OTSession*)session {
    
    NSLog(@"TextChatComponent sessionDidDisconnect");
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDisConnectWithError:)]) {
        [self.delegate didDisConnectWithError:nil];
    }
}

- (void)session:(OTSession*)session didFailWithError:(OTError*)error {
    NSLog(@"didFailWithError: (%@)", error);
    if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectWithError:)]) {
        [self.delegate didConnectWithError:error];
    }
 }

- (void)session:(OTSession*)session streamCreated:(OTStream*)stream {
    NSLog(@"session streamCreated (%@)", stream.streamId);
}

- (void)session:(OTSession*)session streamDestroyed:(OTStream*)stream {
    NSLog(@"session streamDestroyed (%@)", stream.streamId);
}

- (void)session:(OTSession *)session connectionCreated:(OTConnection *)connection {
    NSLog(@"session connectionCreated (%@)", connection.connectionId);
}

- (void)session:(OTSession *)session connectionDestroyed:(OTConnection *)connection {
    NSLog(@"session connectionDestroyed (%@)", connection.connectionId);
}

- (void)session:(OTSession*)session
receivedSignalType:(NSString*)type
 fromConnection:(OTConnection*)connection
     withString:(NSString*)string {
    
    if (![connection.connectionId isEqualToString:self.session.connection.connectionId]) {
        
        if (![OTTestingInfo isTesting]) {
            [OTKLogger logEventAction:KLogActionReceiveMessage variation:KLogVariationAttempt completion:nil];
        }
        
        OTTextMessage *textChat = [[OTTextMessage alloc] initWithJSONString:string];
        
        if (!self.receiverAlias || ![self.receiverAlias isEqualToString:textChat.alias]) {
            self.receiverAlias = textChat.alias;
        }
        
        // determine new type
        if ([self.messages count] > 0) {
            
            OTTextMessage *prev = self.messages[self.messages.count - 1];
            
            // not sure why 120
            if ([textChat.dateTime timeIntervalSinceDate:prev.dateTime] < 120 &&
                [textChat.senderId isEqualToString:prev.senderId]) {
                
                if (textChat.type == TCMessageTypesReceived) {
                    textChat.type = TCMessageTypesReceivedShort;
                }
                else {
                    textChat.type = TCMessageTypesSentShort;
                }
            }
        }
        
        if (textChat) {
            [self.mutableMessages addObject:textChat];
            if (self.delegate) {
                [self.delegate didReceiveTextChat:textChat];
                
                if (![OTTestingInfo isTesting]) {
                    [OTKLogger logEventAction:KLogActionReceiveMessage variation:KLogVariationSuccess completion:nil];
                }
            }
        }
    }
    else {
        //sent message
        
        if (![OTTestingInfo isTesting]) {
            [OTKLogger logEventAction:KLogActionSendMessage variation:KLogVariationSuccess completion:nil];
        }
    }
}

@end
