//
//  TextChatComponent.m
//  TextChatComponent
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import <OpenTok/OpenTok.h>

#import "TextChatComponent.h"
#import "AcceleratorPackSession.h"

static NSUInteger DefaultTextMessageLength = 120;
static NSUInteger MaximumTextMessageLength = 8196;

@interface TextChatComponent() <OTSessionDelegate>
@property (nonatomic) AcceleratorPackSession *session;

@property (nonatomic) NSMutableArray<TextChat *> *mutableMessages;

@property (nonatomic) NSString *senderId;
@property (nonatomic) NSString *alias;
@property (nonatomic) NSString *receiverAlias;
@property (nonatomic) NSUInteger maximumTextMessageLength;

@end

static NSString* const kTextChatType = @"text-chat";

@implementation TextChatComponent

- (NSArray<TextChat *> *)messages {
    return [self.mutableMessages copy];
}

- (void)setAlias:(NSString *)alias {
    
    if (!alias) return;
    _alias = alias;
}

- (void)setMaximumTextMessageLength:(NSUInteger)maximumTextMessageLength {
    
    if (maximumTextMessageLength > 8196) _maximumTextMessageLength = DefaultTextMessageLength;
    _maximumTextMessageLength = maximumTextMessageLength;
}

- (instancetype)init {
    if (self = [super init]) {
        _mutableMessages = [[NSMutableArray alloc] init];
        _session = [AcceleratorPackSession getAcceleratorPackSession];
        _maximumTextMessageLength = MaximumTextMessageLength;
    }
    return self;
}

- (void)connect {
    
    [AcceleratorPackSession registerWithAccePack:self];
}

- (void)disconnect {
    
    [AcceleratorPackSession deregisterWithAccePack:self];
}

- (void)sendMessage:(NSString *)message {
    NSError *error;
    
    if (!message || !message.length) {
        error = [NSError errorWithDomain:NSCocoaErrorDomain
                                    code:-1
                                userInfo:@{NSLocalizedDescriptionKey:@"Message format is wrong. Text is empty or null"}];
        if (self.delegate) {
            [self.delegate didAddMessageWithError:error];
        }
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
                [self.delegate didAddMessageWithError:error];
            }
            return;
        }
        
        [self.session signalWithType:kTextChatType
                              string:jsonString
                          connection:nil
                               error:&error];
        
        if (error) {
            if (self.delegate) {
                [self.delegate didAddMessageWithError:error];
            }
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
    }
    else {
        error = [NSError errorWithDomain:NSCocoaErrorDomain
                                    code:-1
                                userInfo:@{NSLocalizedDescriptionKey:@"OTSession did not connect"}];
    }
    
    if (self.delegate) {
        [self.delegate didAddMessageWithError:error];
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
                [self.delegate didReceiveMessage];
            }
        }
    }
}
@end
