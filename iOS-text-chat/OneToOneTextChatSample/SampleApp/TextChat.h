#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <TextChatKit/TextChatComponent.h>
#import "OneToOneCommunicator.h"

@interface TextChat : NSObject<TextChatComponentDelegate>

@property (nonatomic) OneToOneCommunicator *oneToOneCommunicator;

- (instancetype)initWithCommunicator: (OneToOneCommunicator *)Communicator;

- (BOOL) onMessageReadyToSend:(TextChatComponentMessage *)message;

- (void) setListenersAndTitle: (TextChatComponent *)textChat;
@end
