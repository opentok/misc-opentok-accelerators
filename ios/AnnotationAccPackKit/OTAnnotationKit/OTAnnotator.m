//
//  OTAnnotator.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

// defines for image scaling
// From https://bugs.chromium.org/p/webrtc/issues/detail?id=4643#c7 :
// Don't send any image larger than 1280px on either edge. Additionally, don't
// send any image with dimensions %16 != 0
#define MAX_EDGE_SIZE_LIMIT 1280.0f
#define EDGE_DIMENSION_COMMON_FACTOR 16.0f

#import <OTAcceleratorPackUtil/OTAcceleratorPackUtil.h>
#import "OTAnnotator.h"
#import "UIColor+HexString.h"
#import "JSON.h"

@interface OTAnnotator() <OTSessionDelegate, OTAnnotationViewDelegate> {
    NSMutableDictionary *signalingPoint;
    NSMutableArray *signalingPoints;
    OTStream *latestScreenShareStream;
    CGSize canvasSize;
}
@property (nonatomic) BOOL receiveAnnotationEnabled;
@property (nonatomic) BOOL sendAnnotationEnabled;

@property (nonatomic) OTAnnotationScrollView *annotationScrollView;
@property (nonatomic) OTAcceleratorSession *session;
@property (strong, nonatomic) OTAnnotationBlock handler;

@end

@implementation OTAnnotator

- (instancetype)init {
    
    if (![OTAcceleratorSession getAcceleratorPackSession]) return nil;
    
    if (self = [super init]) {
        _session = [OTAcceleratorSession getAcceleratorPackSession];
    }
    return self;
}

- (NSError *)connectWithSize:(CGSize)size {
    if (!self.delegate && !self.handler) return nil;
    canvasSize = size;
    return [OTAcceleratorSession registerWithAccePack:self];
}

- (void)connectWithSize:(CGSize)size
      completionHandler:(OTAnnotationBlock)handler {
    
    self.handler = handler;
    [self connectWithSize:size];
}

- (NSError *)connectForReceivingAnnotationWithSize:(CGSize)size {
    _receiveAnnotationEnabled = YES;
    _sendAnnotationEnabled = NO;
    return [self connectWithSize:size];
}

- (NSError *)connectForSendingAnnotationWithSize:(CGSize)size {
    _receiveAnnotationEnabled = NO;
    _sendAnnotationEnabled = YES;
    return [self connectWithSize:size];
}

- (void)connectForReceivingAnnotationWithSize:(CGSize)size
                            completionHandler:(OTAnnotationBlock)handler {
    _receiveAnnotationEnabled = YES;
    _sendAnnotationEnabled = NO;
    [self connectWithSize:size completionHandler:handler];
}

- (void)connectForSendingAnnotationWithSize:(CGSize)size
                          completionHandler:(OTAnnotationBlock)handler {
    _receiveAnnotationEnabled = NO;
    _sendAnnotationEnabled = YES;
    [self connectWithSize:size completionHandler:handler];
}

- (NSError *)disconnect {
    if (self.annotationScrollView) {
        [self.annotationScrollView.annotationView removeAllAnnotatables];
    }
    canvasSize = CGSizeZero;
    return [OTAcceleratorSession deregisterWithAccePack:self];
}

- (void)notifiyAllWithSignal:(OTAnnotationSignal)signal error:(NSError *)error {
    
    if (self.handler) {
        self.handler(signal, error);
    }
    
    if (self.delegate) {
        [self.delegate annotator:self signal:signal error:error];
    }
}

- (void) sessionDidConnect:(OTSession *)session {
    
    self.annotationScrollView = [[OTAnnotationScrollView alloc] init];
    self.annotationScrollView.scrollView.contentSize = canvasSize;
    self.annotationScrollView.annotationView.annotationViewDelegate = self;
    [self.annotationScrollView.annotationView setCurrentAnnotatable:[OTAnnotationPath pathWithStrokeColor:nil]];
    [self notifiyAllWithSignal:OTAnnotationSessionDidConnect
                         error:nil];
}

- (void) sessionDidDisconnect:(OTSession *)session {
    self.annotationScrollView = nil;
    
    [self notifiyAllWithSignal:OTAnnotationSessionDidDisconnect
                         error:nil];
}

- (void)session:(OTSession *)session streamCreated:(OTStream *)stream {
    if (stream.videoType == OTStreamVideoTypeScreen) {
        latestScreenShareStream = stream;
    }
}

- (void)session:(OTSession *)session streamDestroyed:(OTStream *)stream {
    if (stream.videoType == OTStreamVideoTypeScreen) {
        latestScreenShareStream = nil;
    }
}

- (void)session:(OTSession *)session didFailWithError:(OTError *)error {
    [self notifiyAllWithSignal:OTAnnotationSessionDidFail
                         error:error];
}

- (void)session:(OTSession *)session connectionCreated:(OTConnection *)connection {
    
}

- (void)session:(OTSession *)session connectionDestroyed:(OTStream *)stream {
    
}

- (void)sessionDidBeginReconnecting:(OTSession *)session {
    [self notifiyAllWithSignal:OTAnnotationSessionDidBeginReconnecting
                         error:nil];
}

- (void)sessionDidReconnect:(OTSession *)session {
    [self notifiyAllWithSignal:OTAnnotationSessionDidReconnect
                         error:nil];
}

// OPENTOK SIGNALING
- (void)session:(OTSession*)session
receivedSignalType:(NSString*)type
 fromConnection:(OTConnection*)connection
     withString:(NSString*)string {
    
    if (![type containsString:@"otAnnotation_pen"]) return;

    if (self.receiveAnnotationEnabled &&
        self.session.sessionConnectionStatus == OTSessionConnectionStatusConnected &&
        ![self.session.connection.connectionId isEqualToString:connection.connectionId]) {
        
        NSArray *jsonArray = [JSON parseJSON:string];
        
        // notify receving data
        if (self.dataReceivingHandler) {
            self.dataReceivingHandler(jsonArray);
        }
        
        if (self.delegate) {
            [self.delegate annotator:self receivedAnnotationData:jsonArray];
        }
        if (jsonArray.count == 0) return;
        
        // set path attributes
        if ([jsonArray firstObject][@"color"] && [jsonArray firstObject][@"lineWidth"]) {
            UIColor *drawingColor = [UIColor colorFromHexString:[jsonArray firstObject][@"color"]];
            self.annotationScrollView.annotationView.currentAnnotatable = [OTAnnotationPath pathWithStrokeColor:drawingColor];
            OTAnnotationPath *currentPath = (OTAnnotationPath *)self.annotationScrollView.annotationView.currentAnnotatable;
            
            CGFloat lineWidth = [[jsonArray firstObject][@"lineWidth"] floatValue];
            currentPath.lineWidth = lineWidth;
        }
        else {
            self.annotationScrollView.annotationView.currentAnnotatable = [OTAnnotationPath pathWithStrokeColor:nil];
        }
        
        // calculate drawing position
        for (NSDictionary *json in jsonArray) {
            
            // this is the unique property from web
            if (![type containsString:@"ios_"]) {
                [self drawOnFitModeWithJson:json path:(OTAnnotationPath *)self.annotationScrollView.annotationView.currentAnnotatable];
                continue;
            }
            
            // the size of remote canvas(same with the ss size)
            CGFloat remoteCanvasWidth = [json[@"canvasWidth"] floatValue];
            CGFloat remoteCanvasHeight = [json[@"canvasHeight"] floatValue];
            
            // video W/H(width/height produced by the core codes of SS and Opentok)
            CGFloat videoWidth = [json[@"videoWidth"] floatValue];
            CGFloat videoHeight = [json[@"videoHeight"] floatValue];
            
            // the size of the current canvas
            CGFloat thisCanvasWidth = CGRectGetWidth(self.annotationScrollView.annotationView.bounds);
            CGFloat thisCanvasHeight = CGRectGetHeight(self.annotationScrollView.annotationView.bounds);
            
            // the aspect ratio of the remote/current canvas
            CGFloat remoteCanvasAspectRatio = remoteCanvasWidth / remoteCanvasHeight;
            CGFloat thisCanvasAspectRatio = thisCanvasWidth / thisCanvasHeight;

            if ((remoteCanvasWidth == videoWidth && remoteCanvasHeight == videoHeight) || thisCanvasAspectRatio == remoteCanvasAspectRatio) {
                // draw on the fill mode or on the same aspect ratio
                [self drawOnFillModeWithJson:json path:(OTAnnotationPath *)self.annotationScrollView.annotationView.currentAnnotatable];
            }
            else {
                // draw on irregular aspect ratio
                [self drawOnFitModeWithJson:json path:(OTAnnotationPath *)self.annotationScrollView.annotationView.currentAnnotatable];
            }
        }
    }
}

- (void)drawOnFillModeWithJson:(NSDictionary *)json
                          path:(OTAnnotationPath *)path {
    
    CGFloat remoteCanvasWidth = [json[@"canvasWidth"] floatValue];
    CGFloat remoteCanvasHeight = [json[@"canvasHeight"] floatValue];
    CGFloat xScaleFactor = canvasSize.width / remoteCanvasWidth;
    CGFloat yScaleFactor = canvasSize.height / remoteCanvasHeight;
    
    CGFloat fromX = [json[@"fromX"] floatValue] * xScaleFactor;
    CGFloat fromY = [json[@"fromY"] floatValue] * yScaleFactor;
    CGFloat toX = [json[@"toX"] floatValue] * xScaleFactor;
    CGFloat toY = [json[@"toY"] floatValue] * yScaleFactor;
    
    OTAnnotationPoint *pt1 = [OTAnnotationPoint pointWithX:fromX andY:fromY];
    OTAnnotationPoint *pt2 = [OTAnnotationPoint pointWithX:toX andY:toY];
    
    if (path.points.count == 0) {
        [path startAtPoint:pt1];
        [path drawToPoint:pt2];
    }
    else {
        [path drawToPoint:pt1];
        [path drawToPoint:pt2];
    }
}

// this method is always work when web annotations as a subscriber
- (void)drawOnFitModeWithJson:(NSDictionary *)json
                         path:(OTAnnotationPath *)path {
    
    CGFloat remoteCanvasWidth = [json[@"canvasWidth"] floatValue];
    CGFloat remoteCanvasHeight = [json[@"canvasHeight"] floatValue];
    CGFloat thisCanvasWidth = CGRectGetWidth(self.annotationScrollView.annotationView.bounds);
    CGFloat thisCanvasHeight = CGRectGetHeight(self.annotationScrollView.annotationView.bounds);
    
    CGFloat remoteCanvasAspectRatio = remoteCanvasWidth / remoteCanvasHeight;
    CGFloat thisCanvasAspectRatio = thisCanvasWidth / thisCanvasHeight;
    
    // apply scale factor
    // Based on this: http://www.iosres.com/index-legacy.html
    // iPhone 4&4s aspect ratio is 3:2 = 0.666
    // iPhone 5&5s&6&6s aspect ratio is 16:9 = 0.5625
    // iPad aspect ratio is 4:3 = 0.75
    
    // we don't even need to calculate whether letter boxing is produced on horizontal or vertical level
    // and we can calculate whether the scale should apply on horizontal or vertical level
    CGFloat scale = 1.0f;
    if (thisCanvasAspectRatio < remoteCanvasAspectRatio) {
        scale = thisCanvasHeight / remoteCanvasHeight;
    }
    else {
        scale = thisCanvasWidth / remoteCanvasWidth;
    }

    CGFloat canvasCenterX = remoteCanvasWidth / 2.0f * scale;
    CGFloat canvasCenterY = remoteCanvasHeight / 2.0f * scale;
    
    // remote x and y
    CGFloat fromX = [json[@"fromX"] floatValue] * scale;
    CGFloat fromY = [json[@"fromY"] floatValue] * scale;
    CGFloat toX = [json[@"toX"] floatValue] * scale;
    CGFloat toY = [json[@"toY"] floatValue] * scale;
    
    OTAnnotationPoint *pt1;
    OTAnnotationPoint *pt2;
    
    if (thisCanvasAspectRatio < remoteCanvasAspectRatio) {
        
        // letter boxing is produced on horizontal level
        CGFloat actualDrawingFromX = fromX - (canvasCenterX - self.annotationScrollView.annotationView.center.x);
        CGFloat actualDrawingToX = toX - (canvasCenterX - self.annotationScrollView.annotationView.center.x);
        pt1 = [OTAnnotationPoint pointWithX:actualDrawingFromX andY:fromY];
        pt2 = [OTAnnotationPoint pointWithX:actualDrawingToX andY:toY];
    }
    else {
        
        // letter boxing is produced on vertical level
        CGFloat actualDrawingFromY = fromY - (canvasCenterY - self.annotationScrollView.annotationView.center.y);
        CGFloat actualDrawingToY = toY - (canvasCenterY - self.annotationScrollView.annotationView.center.y);
        pt1 = [OTAnnotationPoint pointWithX:fromX andY:actualDrawingFromY];
        pt2 = [OTAnnotationPoint pointWithX:toX andY:actualDrawingToY];
    }

    if (path.points.count == 0) {
        [path startAtPoint:pt1];
        [path drawToPoint:pt2];
    }
    else {
        [path drawToPoint:pt1];
        [path drawToPoint:pt2];
    }
}

#pragma mark - OTAnnotationViewDelegate

- (void)annotationView:(OTAnnotationView *)annotationView
            touchBegan:(UITouch *)touch
             withEvent:(UIEvent *)event {
    
    signalingPoints = [[NSMutableArray alloc] init];
    [self signalAnnotatble:annotationView.currentAnnotatable
                     touch:touch
             addtionalInfo:@{@"startPoint":@(YES), @"endPoint":@(NO)}];
}

- (void)annotationView:(OTAnnotationView *)annotationView
            touchMoved:(UITouch *)touch
             withEvent:(UIEvent *)event {
    [self signalAnnotatble:annotationView.currentAnnotatable
                     touch:touch
             addtionalInfo:@{@"startPoint":@(NO), @"endPoint":@(NO)}];
}

- (void)annotationView:(OTAnnotationView *)annotationView
            touchEnded:(UITouch *)touch
             withEvent:(UIEvent *)event {
    
    if (signalingPoint) {
        [self signalAnnotatble:annotationView.currentAnnotatable
                         touch:touch
                 addtionalInfo:@{@"startPoint":@(NO), @"endPoint":@(NO)}];  // the `endPoint` is not `NO` here because web does not recognize it, we can change this later.
    }
    
    NSError *error;
    NSString *jsonString = [JSON stringify:signalingPoints];
    [[OTAcceleratorSession getAcceleratorPackSession] signalWithType:@"ios_otAnnotation_pen" string:jsonString connection:latestScreenShareStream.connection error:&error];
    
    // notify sending data
    if (self.dataReceivingHandler) {
        self.dataReceivingHandler(signalingPoints);
    }
    
    if (self.delegate) {
        [self.delegate annotator:self receivedAnnotationData:signalingPoints];
    }
    
    signalingPoints = nil;
}

- (void)signalAnnotatble:(id<OTAnnotatable>)annotatble
                   touch:(UITouch *)touch
           addtionalInfo:(NSDictionary *)info {
    
    if ([annotatble isKindOfClass:[OTAnnotationPath class]]) {
        
        CGPoint touchPoint = [touch locationInView:touch.view];
        if (!signalingPoint) {
            signalingPoint = [NSMutableDictionary dictionaryWithDictionary:info];
            signalingPoint[@"id"] = latestScreenShareStream.connection.connectionId;    // receiver id
            signalingPoint[@"fromId"] = self.session.connection.connectionId;   // sender id
            signalingPoint[@"fromX"] = @(touchPoint.x);
            signalingPoint[@"fromY"] = @(touchPoint.y);
            signalingPoint[@"videoWidth"] = @(latestScreenShareStream.videoDimensions.width);
            signalingPoint[@"videoHeight"] = @(latestScreenShareStream.videoDimensions.height);
            signalingPoint[@"canvasWidth"] = @(canvasSize.width);
            signalingPoint[@"canvasHeight"] = @(canvasSize.height);
            signalingPoint[@"lineWidth"] = @(2);
            signalingPoint[@"mirrored"] = @(NO);
            signalingPoint[@"smoothed"] = @(YES);    // this is to enable drawing smoothly
        }
        else {
            signalingPoint[@"toX"] = @(touchPoint.x);
            signalingPoint[@"toY"] = @(touchPoint.y);
            [signalingPoints addObject:signalingPoint];
            signalingPoint = nil;
        }
    }
}

@end
