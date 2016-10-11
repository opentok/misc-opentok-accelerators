//
//  OTAnnotator.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OTAnnotationKit/OTAnnotationScrollView.h>

typedef NS_ENUM(NSUInteger, OTAnnotationSignal) {
    OTAnnotationSessionDidConnect = 0,
    OTAnnotationSessionDidDisconnect,
    OTAnnotationConnectionCreated,
    OTAnnotationConnectionDestroyed,
    OTAnnotationSessionDidBeginReconnecting,
    OTAnnotationSessionDidReconnect,
    OTAnnotationSessionDidFail
};

typedef void (^OTAnnotationBlock)(OTAnnotationSignal signal, NSError *error);

typedef void (^OTAnnotationDataSendingBlock)(NSArray *data, NSError * error);

typedef void (^OTAnnotationDataReceivingBlock)(NSArray *data);

@class OTAnnotator;
@protocol AnnotationDelegate <NSObject>

- (void)annotator:(OTAnnotator *)annotator
           signal:(OTAnnotationSignal)signal
            error:(NSError *)error;

- (void)annotator:(OTAnnotator *)annotator sendAnnotationWithData:(NSArray *)data error:(NSError *)error;

- (void)annotator:(OTAnnotator *)annotator receivedAnnotationData:(NSArray *)data;

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

/**
 *  Initialize a new `OTAnnotator` instsance.
 *
 *  @return A new `OTAnnotator` instsance.
 */
- (instancetype)init;

/**
 *  Registers to the shared session: [OTAcceleratorSession] and connect for receiving annotation data.
 *
 *  @param size The size of the annotationScrollView
 *
 *  @return An error to indicate whether it connects successfully, non-nil if it fails.
 */
- (NSError *)connectForReceivingAnnotationWithSize:(CGSize)size;

/**
 *  Registers to the shared session: [OTAcceleratorSession] and connect for sending annotation data.
 *
 *  @param size The size of the annotationScrollView
 *
 *  @return An error to indicate whether it connects successfully, non-nil if it fails.
 */
- (NSError *)connectForSendingAnnotationWithSize:(CGSize)size;

/**
 *  An alternative connect method for receiving annotation data with a completion block handler.
 *
 *  @param handler The completion handler to call with the change.
 */
- (void)connectForReceivingAnnotationWithSize:(CGSize)size
                            completionHandler:(OTAnnotationBlock)handler;

/**
 *  An alternative connect method for sending annotation data with a completion block handler.
 *
 *  @param handler The completion handler to call with the change.
 */
- (void)connectForSendingAnnotationWithSize:(CGSize)size
                          completionHandler:(OTAnnotationBlock)handler;

/**
 *  De-registers to the shared session: [OTAcceleratorSession] and stops publishing/subscriber.
 *
 *  @return An error to indicate whether it disconnects successfully, non-nil if it fails.
 */
- (NSError *)disconnect;

/**
 *  The completion handler to call with the sending data.
 */
@property (copy, nonatomic) OTAnnotationDataSendingBlock dataSendingHandler;

/**
 *  The completion handler to call with the receiving data.
 */
@property (copy, nonatomic) OTAnnotationDataReceivingBlock dataReceivingHandler;

/**
 *  The object that acts as the delegate of the annotator.
 *
 *  The delegate must adopt the AnnotationDelegate protocol. The delegate is not retained.
 */
@property (weak, nonatomic) id<AnnotationDelegate> delegate;

/**
 *  The associated annotation scroll view.
 *
 *  @discussion This will be nil until OTAnnotationSessionDidConnect being signaled.
 */
@property (readonly, nonatomic) OTAnnotationScrollView *annotationScrollView;

@end
