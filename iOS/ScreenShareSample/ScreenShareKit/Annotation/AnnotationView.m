//
//  AnnotationView.m
//  ScreenShareSample
//
//  Created by Xi Huang on 5/18/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "AnnotationView.h"
#import "AnnotationManager.h"

#import "AnnotationPoint.h"
#import "AnnotationPoint_Private.h"

@interface AnnotationView()
@property (nonatomic) AnnotationPath *drawingPath;
@property (nonatomic) AnnotationManager *annotationnManager;
@end

@implementation AnnotationView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        // init
        _annotationnManager = [[AnnotationManager alloc] init];
        _drawingPath = [AnnotationPath pathWithStrokeColor: nil];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)setCurrentDrawPath:(AnnotationPath *)drawingPath {
    if (!drawingPath) return;
    _drawingPath = drawingPath;
}

- (void)addAnnotatable:(id<Annotatable>)annotatable {
    
    if (!annotatable || ![annotatable conformsToProtocol:@protocol(Annotatable)]) {
        return;
    }
    
    if ([annotatable isMemberOfClass:[AnnotationPath class]]) {
        AnnotationPath *path = (AnnotationPath *)annotatable;
        [path drawWholePath];
        [self.annotationnManager addAnnotatable:path];
        [self setNeedsDisplay];
    }
    else if ([annotatable isMemberOfClass:[AnnotationTextField class]]) {
        
        AnnotationTextField *textfield = (AnnotationTextField *)annotatable;
        [self addSubview:textfield];
        [self.annotationnManager addAnnotatable:textfield];
    }
}

- (void)drawRect:(CGRect)rect {
    [self.annotationnManager.annotatable enumerateObjectsUsingBlock:^(id<Annotatable> annotatable, NSUInteger idx, BOOL *stop) {
        
        if ([annotatable isMemberOfClass:[AnnotationPath class]]) {
            AnnotationPath *path = (AnnotationPath *)annotatable;
            [path.strokeColor setStroke];
            [path stroke];
        }
    }];
}

#pragma mark - UIResponder
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.annotationnManager addAnnotatable:_drawingPath];
    UITouch *touch = [touches anyObject];
    AnnotationPoint *touchPoint = [[AnnotationPoint alloc] initWithTouchPoint:touch];
    [_drawingPath drawAtPoint:touchPoint];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    AnnotationPoint *touchPoint = [[AnnotationPoint alloc] initWithTouchPoint:touch];
    [_drawingPath drawToPoint:touchPoint];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _drawingPath = [AnnotationPath pathWithStrokeColor:_drawingPath.strokeColor];
}

@end

