//
//  AnnotationView.m
//  ScreenShareSample
//
//  Created by Xi Huang on 5/18/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "AnnotationView.h"
#import "AnnotationDataManager.h"

#import "AnnotationPoint.h"
#import "AnnotationPoint_Private.h"

@interface AnnotationView()
@property (nonatomic) AnnotationTextView *currentEditingTextView;
@property (nonatomic) AnnotationPath *currentDrawPath;
@property (nonatomic) AnnotationDataManager *annotationDataManager;
@end

@implementation AnnotationView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        // init
        _annotationDataManager = [[AnnotationDataManager alloc] init];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)setCurrentAnnotatable:(id<Annotatable>)annotatable {
    
    if ([annotatable isKindOfClass:[AnnotationPath class]]) {
        _currentDrawPath = (AnnotationPath *)annotatable;
    }
    else if ([annotatable isKindOfClass:[AnnotationTextView class]]) {
        _currentEditingTextView = (AnnotationTextView *)annotatable;
    }
    else {
        _currentDrawPath = nil;
        
        if (_currentEditingTextView) {
            [_currentEditingTextView commit];
        }
        _currentEditingTextView = nil;
    }
}

- (void)addAnnotatable:(id<Annotatable>)annotatable {
    
    if (!annotatable || ![annotatable conformsToProtocol:@protocol(Annotatable)]) {
        return;
    }
    
    if ([annotatable isMemberOfClass:[AnnotationPath class]]) {
        AnnotationPath *path = (AnnotationPath *)annotatable;
        [path drawWholePath];
        [self.annotationDataManager addAnnotatable:path];
        [self setNeedsDisplay];
    }
    else if ([annotatable isMemberOfClass:[AnnotationTextView class]]) {
        
        AnnotationTextView *textfield = (AnnotationTextView *)annotatable;
        [self addSubview:textfield];
        [self.annotationDataManager addAnnotatable:textfield];
    }
}

- (void)undoAnnotatable {
    
    id<Annotatable> annotatable = [self.annotationDataManager peakOfAnnotatable];
    if ([annotatable isMemberOfClass:[AnnotationPath class]]) {
        [self.annotationDataManager undo];
        [self setNeedsDisplay];
    }
    else if ([annotatable isMemberOfClass:[AnnotationTextView class]]) {
        [self.annotationDataManager undo];
        AnnotationTextView *textfield = (AnnotationTextView *)annotatable;
        [textfield removeFromSuperview];
    }
}

- (void)removeAllAnnotatables {
    
    for (NSUInteger i = 0; i < self.annotationDataManager.annotatable.count; i++) {
        [self undoAnnotatable];
    }
}

- (void)drawRect:(CGRect)rect {
    [self.annotationDataManager.annotatable enumerateObjectsUsingBlock:^(id<Annotatable> annotatable, NSUInteger idx, BOOL *stop) {
        
        if ([annotatable isMemberOfClass:[AnnotationPath class]]) {
            AnnotationPath *path = (AnnotationPath *)annotatable;
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
        AnnotationPoint *touchPoint = [[AnnotationPoint alloc] initWithTouchPoint:touch];
        [_currentDrawPath drawAtPoint:touchPoint];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_currentDrawPath) {
        UITouch *touch = [touches anyObject];
        AnnotationPoint *touchPoint = [[AnnotationPoint alloc] initWithTouchPoint:touch];
        [_currentDrawPath drawToPoint:touchPoint];
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_currentDrawPath) {
        _currentDrawPath = [AnnotationPath pathWithStrokeColor:_currentDrawPath.strokeColor];
    }
}

@end

