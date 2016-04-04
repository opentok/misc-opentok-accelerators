//
//  TextChatComponent.m
//  TextChatComponent
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import "TextChatComponent.h"
#import <OpenTok/OpenTok.h>

@interface TextChatComponent() <OTSessionDelegate>
@property (strong, nonatomic) OTSession *session;
@property (strong, nonatomic) TextChatView *textChatView;
@property (strong, nonatomic) TextChatBlock handler;
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

- (instancetype)init {
    if (self = [super init]) {
        _messages = [[NSMutableArray alloc] init];
        _session= [[OTSession alloc] initWithApiKey:kApiKey
                                          sessionId:kSessionId
                                           delegate:self];
    }
    return self;
}

- (void)connectWithHandler:(TextChatBlock)handler {
    
    self.handler = handler;
    if (self.session) {
        OTError *error = nil;
        [self.session connectWithToken:kToken error:&error];
        
        if (error) {
            handler(error);
        }
    }
    else {
        handler([NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:@"connectWithHandler is empty"}]);
    }
}

- (NSError *)sendMessage:(TextChat *)message {
    OTError *error = nil;
    [self.session signalWithType:kTextChatType
                          string:message.text
                      connection:nil
                           error:&error];
    return error;
}

#pragma mark - OTSessionDelegate
- (void)sessionDidConnect:(OTSession*)session {
    
    NSLog(@"session sessionDidConnect (%@)", session.sessionId);
    // When we've connected to the session, we can create the chat component.
    self.textChatView = [TextChatView textChatView];
    [self.textChatView setSenderId:session.connection.connectionId
                        alias:session.connection.data];
    [self.textChatView setTitleToTopBar: [[NSMutableDictionary alloc] initWithDictionary:@{session.connection.connectionId: ([session.connection.data length] > 0 ? session.connection.data : @"")}]];
    
    if (self.handler) {
        self.handler(nil);
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
        TextChat *msg = [[TextChat alloc]init];
        msg.senderAlias = [connection.data length] > 0 ? connection.data : @"";
        msg.senderId = connection.connectionId;
        msg.text = string;
        [self.textChatView addMessage:msg];
        [self.textChatView setTitleToTopBar: [[NSMutableDictionary alloc] initWithDictionary:@{msg.senderId: msg.senderAlias}]];
    }
}
@end
