//
//  TextChatComponent.m
//  TextChatComponent
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import <OpenTok/OpenTok.h>

#import "TextMessageManager.h"
#import <OTAcceleratorPackUtil/OTAcceleratorPackUtil.h>

static NSUInteger DefaultTextMessageLength = 120;
static NSUInteger MaximumTextMessageLength = 8196;


NSString* const KLogSource = @"text_chat_acc_pack";
NSString* const KLogClientVersion = @"ios-vsol-1.0.0";
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

@interface TextMessageManager() <OTSessionDelegate>
@property (nonatomic) OTAcceleratorSession *session;

@property (nonatomic) NSMutableArray<TextMessage *> *mutableMessages;

@property (nonatomic) NSString *senderId;
@property (nonatomic) NSString *alias;
@property (nonatomic) NSString *receiverAlias;
@property (nonatomic) NSUInteger maximumTextMessageLength;

@end

static NSString* const kTextChatType = @"text-chat";

@implementation TextMessageManager

- (NSArray<TextMessage *> *)messages {
    return [self.mutableMessages copy];
}

- (void)setAlias:(NSString *)alias {
    _alias = alias;
}

- (void)setMaximumTextMessageLength:(NSUInteger)maximumTextMessageLength {
    if (maximumTextMessageLength > 8196) _maximumTextMessageLength = DefaultTextMessageLength;
    _maximumTextMessageLength = maximumTextMessageLength;
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
    
    [OTKAnalytics logEventAction:KLogActionSendMessage variation:KLogVariationAttempt completion:nil];
    if (!message || !message.length) {
        error = [NSError errorWithDomain:NSCocoaErrorDomain
                                    code:-1
                                userInfo:@{NSLocalizedDescriptionKey:@"Message format is wrong. Text is empty or null"}];
        if (self.delegate) {
            [self.delegate didAddTextChat:nil error:error];
        }
        
        [OTKAnalytics logEventAction:KLogActionSendMessage variation:KLogVariationFailure completion:nil];
        return;
    }
    
    if (self.session.sessionId) {
        
        TextMessage *textChat = [[TextMessage alloc] initWithMessage:message alias:self.alias senderId:self.senderId];
        
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
            [OTKAnalytics logEventAction:KLogActionSendMessage variation:KLogVariationFailure completion:nil];
            return;
        }
        
        // determine new type
        if ([self.messages count] > 0) {
            
            TextMessage *prev = self.messages[self.messages.count - 1];
            
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
        [OTKAnalytics logEventAction:KLogActionSendMessage variation:KLogVariationFailure completion:nil];
        
        if (self.delegate) {
            [self.delegate didAddTextChat:nil error:error];
        }
    }
}

- (TextMessage *)getTextChatFromIndexPath:(NSIndexPath *)indexPath {
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
    [OTKAnalytics analyticsWithApiKey:@(partner) sessionId:sessionId connectionId:self.session.connection.connectionId clientVersion:KLogClientVersion source:KLogSource];
    [OTKAnalytics logEventAction:KLogActionInitialize variation:KLogVariationAttempt completion:nil];
    
    self.senderId = session.connection.connectionId;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectWithError:)]) {
        [self.delegate didConnectWithError:nil];
    }
    
    [OTKAnalytics logEventAction:KLogActionInitialize variation:KLogVariationSuccess completion:nil];
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
        [OTKAnalytics logEventAction:KLogActionReceiveMessage variation:KLogVariationAttempt completion:nil];
        
        TextMessage *textChat = [[TextMessage alloc] initWithJSONString:string];
        
        if (!self.receiverAlias || ![self.receiverAlias isEqualToString:textChat.alias]) {
            self.receiverAlias = textChat.alias;
        }
        
        // determine new type
        if ([self.messages count] > 0) {
            
            TextMessage *prev = self.messages[self.messages.count - 1];
            
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
                [OTKAnalytics logEventAction:KLogActionReceiveMessage variation:KLogVariationSuccess completion:nil];
            }
        }
    }
    else {
        //sent message
        [OTKAnalytics logEventAction:KLogActionSendMessage variation:KLogVariationSuccess completion:nil];
    }
}

@end
