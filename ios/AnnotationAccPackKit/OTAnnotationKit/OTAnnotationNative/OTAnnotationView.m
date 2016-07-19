//
//  AnnotationView.m
//  ScreenShareSample
//
//  Created by Xi Huang on 5/18/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "OTAnnotationView.h"

#import <OTKAnalytics/OTKLogger.h>

#import "Constants.h"

@interface OTAnnotationView()
@property (nonatomic) OTAnnotationTextView *currentEditingTextView;
@property (nonatomic) OTAnnotationPath *currentDrawPath;
@property (nonatomic) OTAnnotationDataManager *annotationDataManager;
@end

@implementation OTAnnotationView

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
        _currentDrawPath = (OTAnnotationPath *)annotatable;
    }
    else if ([annotatable isKindOfClass:[OTAnnotationTextView class]]) {
        _currentEditingTextView = (OTAnnotationTextView *)annotatable;
    }
    else {
        
        [self commitCurrentAnnotatable];
        _currentAnnotatable = nil;
        _currentDrawPath = nil;
        _currentEditingTextView = nil;
    }
    
    _currentAnnotatable = annotatable;
}

- (void)addAnnotatable:(id<OTAnnotatable>)annotatable {
    
    if (!annotatable || ![annotatable conformsToProtocol:@protocol(OTAnnotatable)]) {
        return;
    }
    
    if ([annotatable isMemberOfClass:[OTAnnotationPath class]]) {
        OTAnnotationPath *path = (OTAnnotationPath *)annotatable;
        [path drawWholePath];
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
        [self.annotationDataManager undo];
        [self setNeedsDisplay];
    }
    else if ([annotatable isMemberOfClass:[OTAnnotationTextView class]]) {
        [self.annotationDataManager undo];
        OTAnnotationTextView *textfield = (OTAnnotationTextView *)annotatable;
        [textfield removeFromSuperview];
    }
}

- (void)removeAllAnnotatables {
    
    [self.annotationDataManager undoAll];
    [self setNeedsDisplay];
}

- (void)commitCurrentAnnotatable {
    
    if ([_currentAnnotatable respondsToSelector:@selector(commit)]) {
        [_currentAnnotatable commit];
    }
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
    
    if (_currentDrawPath) {
        [self.annotationDataManager addAnnotatable:_currentDrawPath];
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:touch.view];
        OTAnnotationPoint *annotatinPoint = [OTAnnotationPoint pointWithX:touchPoint.x andY:touchPoint.y];
        [_currentDrawPath drawAtPoint:annotatinPoint];
        [OTKLogger logEventAction:KLogActionStartDrawing variation:KLogVariationSuccess completion:nil];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_currentDrawPath) {
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:touch.view];
        OTAnnotationPoint *annotatinPoint = [OTAnnotationPoint pointWithX:touchPoint.x andY:touchPoint.y];
        [_currentDrawPath drawToPoint:annotatinPoint];
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_currentDrawPath) {
        _currentDrawPath = [OTAnnotationPath pathWithStrokeColor:_currentDrawPath.strokeColor];
        [OTKLogger logEventAction:KLogActionEndDrawing variation:KLogVariationSuccess completion:nil];
    }
}

@end
