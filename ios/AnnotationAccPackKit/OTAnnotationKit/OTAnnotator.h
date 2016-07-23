//
//  OTAnnotator.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OTAnnotationKit/OTAnnotationView.h>

typedef NS_ENUM(NSUInteger, OTAnnotationSignal) {
    OTAnnotationSessionDidConnect = 0,
    OTAnnotationSessionDidDisconnect,
    OTAnnotationSessionDidFail
};

typedef void (^OTAnnotationBlock)(OTAnnotationSignal signal, NSError *error);

@protocol AnnotationDelegate <NSObject>
- (void)annotationWithSignal:(OTAnnotationSignal)signal
                       error:(NSError *)error;
@end

@interface OTAnnotator : NSObject

@property (nonatomic, getter=isReceiveAnnotationEnabled) BOOL receiveAnnotationEnabled;

@property (nonatomic, getter=isSendAnnotationEnabled) BOOL sendAnnotationEnabled;

+ (instancetype)annotator;

+ (void)setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token;

- (void)connect;

- (void)connectWithHandler:(OTAnnotationBlock)handler;

- (void)disconnect;

@property (weak, nonatomic) id<AnnotationDelegate> delegate;

@property (readonly, nonatomic) OTAnnotationView *annotationView;

@end
