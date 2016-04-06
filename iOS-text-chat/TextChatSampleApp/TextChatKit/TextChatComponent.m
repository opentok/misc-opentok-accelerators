//
//  TextChatComponent.m
//  TextChatComponent
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import "TextChatComponent.h"

#define DEFAULT_TTextChatE_SPAN 120

@interface TextChatComponent() <OTSessionDelegate>
@property (nonatomic) OTSession *session;

@property (nonatomic) NSMutableArray<TextChat *> *mutableMessages;
@property (nonatomic) NSMutableSet<NSString *> *mutableSenders;

@property (nonatomic) NSString *senderId;
@property (nonatomic) NSString *alias;

@end

// ===============================================================================================//
// *** Fill the following variables using your own Project info  ***
// ***          https://dashboard.tokbox.com/projects            ***
// Replace with your OpenTok API key
static NSString* const kApiKey = @"100";
// Replace with your generated session ID
static NSString* const kSessionId = @"2_MX4xMDB-flR1ZSBOb3YgMTkgMTE6MDk6NTggUFNUIDIwMTN-MC4zNzQxNzIxNX4";
// Replace with your generated token
static NSString* const kToken = @"T1==cGFydG5lcl9pZD0xMDAmc2RrX3ZlcnNpb249dGJwaHAtdjAuOTEuMjAxMS0wNy0wNSZzaWc9OTU3ZmU3MDhjNDFhNmJjYmE3NjhmYmE3YzU1NjUyMGZlNTJmYTJhMTpzZXNzaW9uX2lkPTJfTVg0eE1EQi1mbFIxWlNCT2IzWWdNVGtnTVRFNk1EazZOVGdnVUZOVUlESXdNVE4tTUM0ek56UXhOekl4Tlg0JmNyZWF0ZV90aW1lPTE0NTkzNjAyMjcmcm9sZT1tb2RlcmF0b3Imbm9uY2U9MTQ1OTM2MDIyNy44MjY3MjQyNjk1OTU2JmV4cGlyZV90aW1lPTE0NjE5NTIyMjc=";
// ===============================================================================================//
static NSString* const kTextChatType = @"TextChat";

@implementation TextChatComponent

- (NSArray<TextChat *> *)messages {
    return [self.mutableMessages copy];
}

- (NSSet<NSString *> *)senders {
    return [self.mutableSenders copy];
}

- (instancetype)init {
    if (self = [super init]) {
        _mutableMessages = [[NSMutableArray alloc] init];
        _session= [[OTSession alloc] initWithApiKey:kApiKey
                                          sessionId:kSessionId
                                           delegate:self];
    }
    return self;
}

- (void)connect {
    OTError *error = nil;
    [self.session connectWithToken:kToken error:&error];
    
    if (self.delegate && error) {
        [self.delegate didConnectWithError:error];
    }
}

- (void)sendMessage:(NSString *)message {
    NSError *error = nil;
    if (self.session.sessionId) {
        
        TextChat *textChat = [[TextChat alloc] init];
        textChat.senderAlias = [self.alias length]> 0 ? self.alias : @"";
        textChat.senderId = [self.senderId length] > 0 ? self.senderId : @"";
        textChat.text = message;
        textChat.type = TCMessageTypesSent;
        textChat.dateTime = [[NSDate alloc] init];
        [self.session signalWithType:kTextChatType
                              string:message
                          connection:nil
                               error:&error];
        
        // determine new type
        if ([self.messages count] > 0) {
            
            TextChat *prev = self.messages[self.messages.count - 1];
            if ([textChat.dateTime timeIntervalSinceDate:prev.dateTime] < DEFAULT_TTextChatE_SPAN &&
                [textChat.senderId isEqualToString:prev.senderId]) {
                
                if (textChat.type == TCMessageTypesReceived) {
                    textChat.type = TCMessageTypesReceivedShort;
                }
                else {
                    textChat.type = TCMessageTypesSentShort;
                }
            }
            else {
                TextChat *div = [[TextChat alloc] init];
                div.type = TCMessageTypesDivider;
                [self.mutableMessages addObject:div];
            }
        }
        [self.mutableMessages addObject:textChat];
    }
    else {
        error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:@"OTSession did not connect"}];
    }
    
    if (self.delegate) {
        [self.delegate didAddMessageWithError:error];
    }
}

#pragma mark - OTSessionDelegate
- (void)sessionDidConnect:(OTSession*)session {
    
    NSLog(@"session sessionDidConnect (%@)", session.sessionId);
    // When we've connected to the session, we can create the chat component.
    
    self.senderId = session.connection.connectionId;
    self.alias = session.connection.data;
    if (![self.mutableSenders containsObject:self.senderId]) {
        [self.mutableSenders addObject:self.senderId];
    }
    
    if (self.delegate) {
        [self.delegate didConnectWithError:nil];
    }
}

- (void)sessionDidDisconnect:(OTSession*)session {
    NSLog(@"session sessionDidDisconnect (%@)", session.sessionId);
}

- (void)session:(OTSession*)session didFailWithError:(OTError*)error {
    NSLog(@"didFailWithError: (%@)", error);
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
        TextChat *textChat = [[TextChat alloc]init];
        textChat.senderAlias = [connection.data length] > 0 ? connection.data : @"";
        textChat.senderId = connection.connectionId;
        textChat.text = string;
        textChat.type = TCMessageTypesReceived;
        // determine new type
        if ([self.messages count] > 0) {
            
            TextChat *prev = self.messages[self.messages.count - 1];
            if ([textChat.dateTime timeIntervalSinceDate:prev.dateTime] < DEFAULT_TTextChatE_SPAN &&
                [textChat.senderId isEqualToString:prev.senderId]) {
                
                if (textChat.type == TCMessageTypesReceived) {
                    textChat.type = TCMessageTypesReceivedShort;
                }
                else {
                    textChat.type = TCMessageTypesSentShort;
                }
            }
            else {
                TextChat *div = [[TextChat alloc] init];
                div.type = TCMessageTypesDivider;
                [self.mutableMessages addObject:div];
            }
        }
        
        [self.mutableMessages addObject:textChat];
        if (self.delegate) {
            [self.delegate didReceiveMessage];
        }
    }
}
@end
