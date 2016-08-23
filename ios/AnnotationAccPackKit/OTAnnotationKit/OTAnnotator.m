//
//  OTAnnotator.m
//  OTAnnotationAccPackKit
//
//  Created by Xi Huang on 7/18/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <OTAcceleratorPackUtil/OTAcceleratorPackUtil.h>
#import "OTAnnotator.h"
#import "JSON.h"

@interface OTAnnotator() <OTSessionDelegate>

@property (nonatomic) OTAnnotationView *annotationView;
@property (nonatomic) OTAcceleratorSession *session;
@property (nonatomic) OTAnnotationBlock handler;

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

- (void) session:(OTSession *)session streamCreated:(OTStream *)stream {}

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
//    if (self.receiveAnnotationEnabled &&
//        self.session.sessionConnectionStatus == OTSessionConnectionStatusConnected &&
//        ![self.session.connection.connectionId isEqualToString:connection.connectionId]) {
//        
//        
//        if (!self.annotationView.currentAnnotatable) {
//            OTAnnotationPath *path = [OTAnnotationPath pathWithStrokeColor:nil];
//            [self.annotationView setCurrentAnnotatable:path];
//            [self.annotationView.annotationDataManager addAnnotatable:path];
//        }
//        
//        NSArray *jsonArray = [JSON parseJSON:string];
//        for (NSDictionary *json in jsonArray) {
//            if ([self.annotationView.currentAnnotatable isKindOfClass:[OTAnnotationPath class]]) {
//                
//                OTAnnotationPath *currentPath = (OTAnnotationPath *)self.annotationView.currentAnnotatable;
//                CGFloat fromX = [json[@"fromX"] floatValue];
//                CGFloat fromY = [json[@"fromY"] floatValue];
//                CGFloat toX = [json[@"toX"] floatValue];
//                CGFloat toY = [json[@"toY"] floatValue];
//                OTAnnotationPoint *pt1 = [OTAnnotationPoint pointWithX:fromX andY:fromY];
//                OTAnnotationPoint *pt2 = [OTAnnotationPoint pointWithX:toX andY:toY];
//                [currentPath drawAtPoint:pt1];
//                [currentPath drawToPoint:pt2];
//                [self.annotationView setNeedsDisplay];
//            }
//        }
//    }
    
    //    OTAnnotationPoint *p1 = [[OTAnnotationPoint alloc] initWithX:119 andY:16];
    //    OTAnnotationPoint *p2 = [[OTAnnotationPoint alloc] initWithX:122 andY:16];
    //    OTAnnotationPoint *p3 = [[OTAnnotationPoint alloc] initWithX:126 andY:18];
    //    OTAnnotationPoint *p4 = [[OTAnnotationPoint alloc] initWithX:134 andY:21];
    //    OTAnnotationPoint *p5 = [[OTAnnotationPoint alloc] initWithX:144 andY:28];
    //    OTAnnotationPath *path = [OTAnnotationPath pathWithPoints:@[p1, p2, p3, p4, p5] strokeColor:nil];
    //    [self.remoteAnnotator.annotationView addAnnotatable:path];
    //
    //
    //    OTAnnotationPoint *p6 = [[OTAnnotationPoint alloc] initWithX:160 andY:16];
    //    OTAnnotationPoint *p7 = [[OTAnnotationPoint alloc] initWithX:160 andY:20];
    //    OTAnnotationPoint *p8 = [[OTAnnotationPoint alloc] initWithX:160 andY:24];
    //    OTAnnotationPoint *p9 = [[OTAnnotationPoint alloc] initWithX:160 andY:26];
    //    OTAnnotationPoint *p10 = [[OTAnnotationPoint alloc] initWithX:160 andY:30];
    //    OTAnnotationPath *path1 = [OTAnnotationPath pathWithPoints:@[p6, p7, p8, p9, p10] strokeColor:[UIColor yellowColor]];
    //    [self.remoteAnnotator.annotationView addAnnotatable:path1];
    
}

@end
