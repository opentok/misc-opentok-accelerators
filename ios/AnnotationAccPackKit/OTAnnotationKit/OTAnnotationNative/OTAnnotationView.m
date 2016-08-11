//
//  AnnotationView.m
//
//  Copyright © 2016 Tokbox. All rights reserved.
//

#import "OTAnnotationView.h"

#import <OTKAnalytics/OTKLogger.h>
#import "OTAnnotator.h"
#import "OTAnnotationView+Signaling.h"

#import "Constants.h"

@interface OTAnnotationView()
@property (nonatomic) OTAnnotationTextView *currentEditingTextView;
@property (nonatomic) OTAnnotationPath *currentDrawPath;
@property (nonatomic) OTAnnotationDataManager *annotationDataManager;
@property (weak, nonatomic) OTAnnotator *annotator;
@end

@implementation OTAnnotationView

- (OTAnnotator *)annotator {
    if (!_annotator) {
        if ([OTAnnotator annotator].annotationView == self) {
            _annotator = [OTAnnotator annotator];
        }
    }
    return _annotator;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [OTKLogger analyticsWithClientVersion:KLogClientVersion
                                       source:[[NSBundle mainBundle] bundleIdentifier]
                                  componentId:kLogComponentIdentifier
                                         guid:[[NSUUID UUID] UUIDString]];
        
        [OTKLogger logEventAction:KLogActionInitialize variation:KLogVariationSuccess completion:nil];
        
        _annotationDataManager = [[OTAnnotationDataManager alloc] init];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)setCurrentAnnotatable:(id<OTAnnotatable>)annotatable {
    
    if ([annotatable isKindOfClass:[OTAnnotationPath class]]) {
        _currentAnnotatable = annotatable;
        _currentDrawPath = (OTAnnotationPath *)annotatable;
        [self addAnnotatable:annotatable];
        [OTKLogger logEventAction:KLogActionFreeHand variation:KLogVariationSuccess completion:nil];
    }
    else if ([annotatable isKindOfClass:[OTAnnotationTextView class]]) {
        _currentAnnotatable = annotatable;
        _currentEditingTextView = (OTAnnotationTextView *)annotatable;
        [self addAnnotatable:annotatable];
    }
    else {
        [self commitCurrentAnnotatable];
    }
}

- (void)addAnnotatable:(id<OTAnnotatable>)annotatable {
    
    if (!annotatable || ![annotatable conformsToProtocol:@protocol(OTAnnotatable)]) {
        return;
    }
    
    if ([annotatable isMemberOfClass:[OTAnnotationPath class]]) {
        OTAnnotationPath *path = (OTAnnotationPath *)annotatable;
        if (path.points.count != 0) {
            [path drawWholePath];
        }
        [self.annotationDataManager addAnnotatable:path];
        [self setNeedsDisplay];
    }
    else if ([annotatable isMemberOfClass:[OTAnnotationTextView class]]) {
        
        OTAnnotationTextView *textfield = (OTAnnotationTextView *)annotatable;
        [self addSubview:textfield];
        [self.annotationDataManager addAnnotatable:textfield];
    }
}

- (void)undoAnnotatable {
    
    id<OTAnnotatable> annotatable = [self.annotationDataManager peakOfAnnotatable];
    if ([annotatable isMemberOfClass:[OTAnnotationPath class]]) {
        [self.annotationDataManager pop];
        [self setNeedsDisplay];
        [OTKLogger logEventAction:KLogActionErase variation:KLogVariationSuccess completion:nil];
    }
    else if ([annotatable isMemberOfClass:[OTAnnotationTextView class]]) {
        [self.annotationDataManager pop];
        OTAnnotationTextView *textfield = (OTAnnotationTextView *)annotatable;
        [textfield removeFromSuperview];
        [OTKLogger logEventAction:KLogActionErase variation:KLogVariationSuccess completion:nil];
    }
}

- (void)removeAllAnnotatables {
    
    [self.annotationDataManager pop];
    [self setNeedsDisplay];
    [OTKLogger logEventAction:KLogActionErase variation:KLogVariationSuccess completion:nil];
}

- (void)commitCurrentAnnotatable {
    
    if ([self.currentAnnotatable respondsToSelector:@selector(commit)]) {
        [self.currentAnnotatable commit];
    }
    _currentAnnotatable = nil;
    _currentDrawPath = nil;
    _currentEditingTextView = nil;
}

- (UIImage *)captureScreen {
    [OTKLogger logEventAction:KLogActionScreenCapture variation:KLogVariationSuccess completion:nil];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContext(screenRect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextFillRect(ctx, screenRect);
    [self.window.layer renderInContext:ctx];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)drawRect:(CGRect)rect {
    [self.annotationDataManager.annotatable enumerateObjectsUsingBlock:^(id<OTAnnotatable> annotatable, NSUInteger idx, BOOL *stop) {
        
        if ([annotatable isMemberOfClass:[OTAnnotationPath class]]) {
            OTAnnotationPath *path = (OTAnnotationPath *)annotatable;
            [path.strokeColor setStroke];
            [path stroke];
        }
    }];
}

#pragma mark - UIResponder
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_currentEditingTextView) return;
    
    if (!_currentDrawPath || _currentDrawPath.points.count != 0) {
        self.currentAnnotatable = [OTAnnotationPath pathWithStrokeColor:_currentDrawPath.strokeColor];
    }
    UITouch *touch = [touches anyObject];
    
    if (self.annotator && self.annotator.isSendAnnotationEnabled){
        [self signalAnnotatble:_currentAnnotatable touch:touch addtionalInfo:nil];
    }
    
    CGPoint touchPoint = [touch locationInView:touch.view];
    OTAnnotationPoint *annotatinPoint = [OTAnnotationPoint pointWithX:touchPoint.x andY:touchPoint.y];
    [_currentDrawPath startAtPoint:annotatinPoint];
    [OTKLogger logEventAction:KLogActionStartDrawing variation:KLogVariationSuccess completion:nil];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_currentDrawPath) {
        UITouch *touch = [touches anyObject];
        
        if (self.annotator && self.annotator.isSendAnnotationEnabled){
            [self signalAnnotatble:_currentAnnotatable touch:touch addtionalInfo:nil];
        }
        
        CGPoint touchPoint = [touch locationInView:touch.view];
        OTAnnotationPoint *annotatinPoint = [OTAnnotationPoint pointWithX:touchPoint.x andY:touchPoint.y];
        [_currentDrawPath drawToPoint:annotatinPoint];
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_currentDrawPath) {
        UITouch *touch = [touches anyObject];
        
        if (self.annotator && self.annotator.isSendAnnotationEnabled){
            [self signalAnnotatble:_currentAnnotatable touch:touch addtionalInfo:@{@"endPoint":@(YES)}];
        }
        
        CGPoint touchPoint = [touch locationInView:touch.view];
        OTAnnotationPoint *annotatinPoint = [OTAnnotationPoint pointWithX:touchPoint.x andY:touchPoint.y];
        [_currentDrawPath drawToPoint:annotatinPoint];
        [self setNeedsDisplay];
        [self commitCurrentAnnotatable];
        [OTKLogger logEventAction:KLogActionEndDrawing variation:KLogVariationSuccess completion:nil];
    }
}

@end
