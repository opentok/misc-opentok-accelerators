#import <Foundation/Foundation.h>
#import <Opentok/OpenTok.h>

typedef NS_ENUM(NSUInteger, OneToOneCommunicationSignal) {
    OneToOneCommunicationSignalSessionDidConnect = 0,
    OneToOneCommunicationSignalSessionDidDisconnect,
    OneToOneCommunicationSignalSessionDidFail,
    OneToOneCommunicationSignalSessionStreamCreated,
    OneToOneCommunicationSignalSessionStreamDestroyed,
    OneToOneCommunicationSignalPublisherDidFail,
    OneToOneCommunicationSignalSubscriberConnect,
    OneToOneCommunicationSignalSubscriberDidFail,
    OneToOneCommunicationSignalSubscriberVideoDisabled,
    OneToOneCommunicationSignalSubscriberVideoEnabled,
    OneToOneCommunicationSignalSubscriberVideoDisableWarning,
    OneToOneCommunicationSignalSubscriberVideoDisableWarningLifted,
};

typedef void (^OneToOneCommunicatorBlock)(OneToOneCommunicationSignal signal, NSError *error);

@interface OneToOneCommunicator : NSObject

@property (nonatomic) BOOL isCallEnabled;
@property (readonly, nonatomic) OTSubscriber *subscriber;
@property (readonly, nonatomic) OTPublisher *publisher;
@property (nonatomic) OTSession *session;

+ (instancetype)oneToOneCommunicator;
+ (void)setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token
          selfSubscribed:(BOOL)isSelfSubscribed;

- (void)connectWithHandler:(OneToOneCommunicatorBlock)handler;
- (void)disconnect;

- (BOOL) readyToSendMessage: (NSString *) message;

@end
