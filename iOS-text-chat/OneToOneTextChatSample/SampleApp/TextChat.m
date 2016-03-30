#import "TextChat.h"

@implementation TextChat

- (instancetype)initWithCommunicator: (OneToOneCommunicator *)Communicator; {
    self.oneToOneCommunicator = Communicator;
    return self;
}

-(BOOL) onMessageReadyToSend:(TextChatComponentMessage *)message; {
    return [self.oneToOneCommunicator readyToSendMessage: (NSString *) message.text];
}

- (void) setListenersAndTitle: (TextChatComponent *)textChat; {
    [textChat setSenderId: self.oneToOneCommunicator.session.connection.connectionId
                    alias: self.oneToOneCommunicator.session.connection.data];

    [textChat setTitleToTopBar: [[NSMutableDictionary alloc] initWithDictionary:@{self.oneToOneCommunicator.session.connection.connectionId: ([self.oneToOneCommunicator.session.connection.data length] > 0 ? self.oneToOneCommunicator.session.connection.data : @"")}]];
}
@end
