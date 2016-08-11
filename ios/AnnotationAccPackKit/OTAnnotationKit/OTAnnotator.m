//
//  OTAnnotator.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <OTAcceleratorPackUtil/OTAcceleratorPackUtil.h>
#import "OTAnnotator.h"
#import "JSON.h"

@interface OTAnnotator() <OTSessionDelegate>
@property (nonatomic) BOOL receiveAnnotationEnabled;
@property (nonatomic) BOOL sendAnnotationEnabled;

@property (nonatomic) OTAnnotationView *annotationView;
@property (nonatomic) OTAcceleratorSession *session;
@property (strong, nonatomic) OTAnnotationBlock handler;

@end

@implementation OTAnnotator

+ (instancetype)annotator {
    return [OTAnnotator sharedInstance];
}

+ (void)setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token; {
    
    [OTAcceleratorSession setOpenTokApiKey:apiKey sessionId:sessionId token:token];
    [OTAnnotator sharedInstance];
}

+ (instancetype)sharedInstance {
    
    static OTAnnotator *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OTAnnotator alloc] init];
        sharedInstance.session = [OTAcceleratorSession getAcceleratorPackSession];
    });
    
    return sharedInstance;
}

- (void)connect {
    if (!self.delegate && !self.handler) return;
    
    NSError *registerError = [OTAcceleratorSession registerWithAccePack:self];
    if (registerError) {
    
    }
    else {
        
    }
}

- (void)connectWithHandler:(OTAnnotationBlock)handler {
    self.handler = handler;
    [self connect];
}

- (void)connectForReceivingAnnotation {
    _receiveAnnotationEnabled = YES;
    _sendAnnotationEnabled = NO;
    [self connect];
}

- (void)connectForSendingAnnotation {
    _receiveAnnotationEnabled = NO;
    _sendAnnotationEnabled = YES;
    [self connect];
}

- (void)connectForReceivingAnnotationWithHandler:(OTAnnotationBlock)handler {
    _receiveAnnotationEnabled = YES;
    _sendAnnotationEnabled = NO;
    [self connectWithHandler:handler];
}

- (void)connectForSendingAnnotationWithHandler:(OTAnnotationBlock)handler {
    _receiveAnnotationEnabled = NO;
    _sendAnnotationEnabled = YES;
    [self connectWithHandler:handler];
}

- (void)disconnect {
    
    NSError *disconnectError = [OTAcceleratorSession deregisterWithAccePack:self];
    if (!disconnectError) {
        
    }
    else {
        
    }
}

- (void)notifiyAllWithSignal:(OTAnnotationSignal)signal error:(NSError *)error {
    
    if (self.handler) {
        self.handler(signal, error);
    }
    
    if (self.delegate) {
        [self.delegate annotationWithSignal:signal error:error];
    }
}

- (void) sessionDidConnect:(OTSession *)session {
    self.annotationView = [[OTAnnotationView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.annotationView setCurrentAnnotatable:[OTAnnotationPath pathWithStrokeColor:nil]];
    [self notifiyAllWithSignal:OTAnnotationSessionDidConnect
                         error:nil];
}

- (void) sessionDidDisconnect:(OTSession *)session {
    self.annotationView = nil;
    
    [self notifiyAllWithSignal:OTAnnotationSessionDidDisconnect
                         error:nil];
}

- (void)session:(OTSession *)session streamCreated:(OTStream *)stream {}

- (void)session:(OTSession *)session streamDestroyed:(OTStream *)stream {}

- (void)session:(OTSession *)session didFailWithError:(OTError *)error {
    [self notifiyAllWithSignal:OTAnnotationSessionDidFail
                         error:error];
}

// OPENTOK SIGNALING
- (void)session:(OTSession*)session
receivedSignalType:(NSString*)type
 fromConnection:(OTConnection*)connection
     withString:(NSString*)string {

    // TODO: continue here
    if (self.receiveAnnotationEnabled &&
        self.session.sessionConnectionStatus == OTSessionConnectionStatusConnected &&
        ![self.session.connection.connectionId isEqualToString:connection.connectionId]) {
        
        
        
//        NSArray *jsonArray = [JSON parseJSON:string];
//        for (NSDictionary *json in jsonArray) {
//            if ([self.annotationView.currentAnnotatable isKindOfClass:[OTAnnotationPath class]]) {
//                
//                CGFloat fromX = [json[@"fromX"] floatValue];
//                CGFloat fromY = [json[@"fromY"] floatValue];
//                CGFloat toX = [json[@"toX"] floatValue];
//                CGFloat toY = [json[@"toY"] floatValue];
//                OTAnnotationPoint *pt1 = [OTAnnotationPoint pointWithX:fromX andY:fromY];
//                OTAnnotationPoint *pt2 = [OTAnnotationPoint pointWithX:toX andY:toY];
//                
//                [tempPoints addObject:pt1];
//                [tempPoints addObject:pt2];
//                
//                if ([json[@"endPoint"] boolValue]) {
//                    [self.annotationView addAnnotatable:[OTAnnotationPath pathWithPoints:tempPoints strokeColor:nil]];
//                    [tempPoints removeAllObjects];
//                }
//            }
//        }
        
        NSArray *jsonArray = [JSON parseJSON:string];
        for (NSDictionary *json in jsonArray) {
            if ([self.annotationView.currentAnnotatable isKindOfClass:[OTAnnotationPath class]]) {
                
                if (!self.annotationView.currentAnnotatable) {
                    self.annotationView.currentAnnotatable = [OTAnnotationPath pathWithStrokeColor:nil];
                }
                
                CGFloat fromX = [json[@"fromX"] floatValue];
                CGFloat fromY = [json[@"fromY"] floatValue];
                CGFloat toX = [json[@"toX"] floatValue];
                CGFloat toY = [json[@"toY"] floatValue];
                OTAnnotationPoint *pt1 = [OTAnnotationPoint pointWithX:fromX andY:fromY];
                OTAnnotationPoint *pt2 = [OTAnnotationPoint pointWithX:toX andY:toY];
                
                OTAnnotationPath *path = (OTAnnotationPath *)self.annotationView.currentAnnotatable;
                if (path.points.count == 0) {
                    [path startAtPoint:pt1];
                    [path drawToPoint:pt2];
                }
                else {
                    [path drawToPoint:pt1];
                    [path drawToPoint:pt2];
                }
            
                if ([json[@"endPoint"] boolValue]) {
                    [self.annotationView commitCurrentAnnotatable];
                    self.annotationView.currentAnnotatable = [OTAnnotationPath pathWithStrokeColor:[UIColor blueColor]];
                }
            }
        }
    }
}

@end
