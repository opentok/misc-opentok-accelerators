//
//  TextChatComponent.m
//  TextChatComponent
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import <OpenTok/OpenTok.h>

#import "TextChatComponent.h"
#import "OTAcceleratorSession.h"


static NSUInteger DefaultTextMessageLength = 120;
static NSUInteger MaximumTextMessageLength = 8196;


NSString* const KLogSource = @"text_chat_acc_pack";
NSString* const KLogClientVersion = @"ios-vsol-0.9";
NSString* const KLogActionInitialize = @"initialize";
NSString* const KLogActionSendMessage = @"send_message";
NSString* const KLogActionReceiveMessage = @"receive_message";
NSString* const KLogActionMaxLength = @"set_max_length";
NSString* const KLogActionSenderAlias = @"set_sender_alias";
NSString* const KLogActionMinimize = @"minimize";
NSString* const KLogActionMaximize = @"maximize";
NSString* const KLogActionClose = @"close";
NSString* const KLogVariationAttempt = @"Attempt";
NSString* const KLogVariationSuccess = @"Success";
NSString* const KLogVariationFailure = @"Failure";

@interface TextChatComponent() <OTSessionDelegate>
@property (nonatomic) OTAcceleratorSession *session;

@property (nonatomic) NSMutableArray<TextChat *> *mutableMessages;

@property (nonatomic) NSString *senderId;
@property (nonatomic) NSString *alias;
@property (nonatomic) NSString *receiverAlias;
@property (nonatomic) NSUInteger maximumTextMessageLength;
@property (nonatomic) OTKAnalytics *analytics;

@end

static NSString* const kTextChatType = @"text-chat";

@implementation TextChatComponent

- (NSArray<TextChat *> *)messages {
    return [self.mutableMessages copy];
}

- (void)setAlias:(NSString *)alias {
    _alias = alias;
}

- (void)setMaximumTextMessageLength:(NSUInteger)maximumTextMessageLength {
    if (maximumTextMessageLength > 8196) _maximumTextMessageLength = DefaultTextMessageLength;
    _maximumTextMessageLength = maximumTextMessageLength;
}

- (void)addLogEvent:(NSString*)action variation:(NSString*)variation {
    [_analytics logEventAction:action variation:variation];
}

- (instancetype)init {
    if (self = [super init]) {
        _mutableMessages = [[NSMutableArray alloc] init];
        _session = [OTAcceleratorSession getAcceleratorPackSession];
        _maximumTextMessageLength = MaximumTextMessageLength;
    }
    return self;
}

- (void)connect {
    
    [OTAcceleratorSession registerWithAccePack:self];
}

- (void)disconnect {
    
    [OTAcceleratorSession deregisterWithAccePack:self];
}

- (void)sendMessage:(NSString *)message {
    NSError *error;
    
    [self addLogEvent:KLogActionSendMessage variation:KLogVariationAttempt];

    if (!message || !message.length) {
        error = [NSError errorWithDomain:NSCocoaErrorDomain
                                    code:-1
                                userInfo:@{NSLocalizedDescriptionKey:@"Message format is wrong. Text is empty or null"}];
        if (self.delegate) {
            [self.delegate didAddTextChat:nil error:error];
        }
        
        [self addLogEvent:KLogActionSendMessage variation:KLogVariationFailure];

        return;
    }
    
    if (self.session.sessionId) {
        
        TextChat *textChat = [[TextChat alloc] initWithMessage:message alias:self.alias senderId:self.senderId];
        
        NSString *jsonString = [textChat getTextChatSignalJSONString];
        if (!jsonString) {
            if (self.delegate) {
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                     code:-1
                                                 userInfo:@{NSLocalizedDescriptionKey:@"Error in parsing sender data"}];
                [self.delegate didAddTextChat:nil error:error];
            }
            return;
        }
        
        [self.session signalWithType:kTextChatType
                              string:jsonString
                          connection:nil
                               error:&error];
        
        if (error) {
            if (self.delegate) {
                [self.delegate didAddTextChat:nil error:error];
            }
            [self addLogEvent:KLogActionSendMessage variation:KLogVariationFailure];
            
            return;
        }
        
        // determine new type
        if ([self.messages count] > 0) {
            
            TextChat *prev = self.messages[self.messages.count - 1];
            
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
        
        if (self.delegate) {
            [self.delegate didAddTextChat:textChat error:nil];
        }
    }
    else {
        error = [NSError errorWithDomain:NSCocoaErrorDomain
                                    code:-1
                                userInfo:@{NSLocalizedDescriptionKey:@"OTSession did not connect"}];
        [self addLogEvent:KLogActionSendMessage variation:KLogVariationFailure];
        
        if (self.delegate) {
            [self.delegate didAddTextChat:nil error:error];
        }
    }
}

- (TextChat *)getTextChatFromIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 0 || indexPath.row >= self.messages.count) {
        return nil;
    }
    return self.messages[indexPath.row];
}

#pragma mark - OTSessionDelegate
- (void)sessionDidConnect:(OTSession*)session {
    
    NSLog(@"TextChatComponent sessionDidConnect");
    
    //Init otkanalytics. Internal use
    NSString *apiKey = _session.apiKey;
    NSString *sessionId = _session.sessionId;
    NSInteger partner = [apiKey integerValue];
    _analytics = [[OTKAnalytics alloc] initWithSessionId:sessionId connectionId:self.session.connection.connectionId partnerId:partner clientVersion:KLogClientVersion source: KLogSource];
    [self addLogEvent:KLogActionInitialize variation:KLogVariationAttempt];
    
    self.senderId = session.connection.connectionId;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectWithError:)]) {
        [self.delegate didConnectWithError:nil];
    }
    
    [self addLogEvent:KLogActionInitialize variation:KLogVariationSuccess];
    
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
        [self addLogEvent:KLogActionReceiveMessage variation:KLogVariationAttempt];
        
        TextChat *textChat = [[TextChat alloc] initWithJSONString:string];
        
        if (!self.receiverAlias || ![self.receiverAlias isEqualToString:textChat.alias]) {
            self.receiverAlias = textChat.alias;
        }
        
        // determine new type
        if ([self.messages count] > 0) {
            
            TextChat *prev = self.messages[self.messages.count - 1];
            
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
                [self addLogEvent:KLogActionReceiveMessage variation:KLogVariationSuccess];
            }
        }
    }
    else {
        //sent message
        [self addLogEvent:KLogActionSendMessage variation:KLogVariationSuccess];
    }
}

@end
