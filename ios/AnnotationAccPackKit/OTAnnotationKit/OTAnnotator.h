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

/**
 *  A boolean value to indicate whether the annotationView should receive remote annotation data and then annotate. Enabling this property will not allow to anntoate locally.
 */
@property (readonly, nonatomic, getter=isReceiveAnnotationEnabled) BOOL receiveAnnotationEnabled;

/**
 *  A boolean value to indicate whether the annotationView should send annotation data.
 */
@property (readonly, nonatomic, getter=isSendAnnotationEnabled) BOOL sendAnnotationEnabled;

+ (instancetype)annotator;

+ (void)setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token;

- (void)connectForReceivingAnnotation;

- (void)connectForSendingAnnotation;

- (void)connectForReceivingAnnotationWithHandler:(OTAnnotationBlock)handler;

- (void)connectForSendingAnnotationWithHandler:(OTAnnotationBlock)handler;

- (void)disconnect;

@property (weak, nonatomic) id<AnnotationDelegate> delegate;

@property (readonly, nonatomic) OTAnnotationView *annotationView;

@end
