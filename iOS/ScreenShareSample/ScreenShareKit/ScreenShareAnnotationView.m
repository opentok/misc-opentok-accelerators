//
//  ScreenShareAnnotationView.m
//  ScreenShareSample
//
//  Created by Xi Huang on 5/2/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "ScreenShareAnnotationView.h"
#import "ScreenShareViewManager.h"

@interface ScreenShareAnnotationView()
@property (nonatomic) ScreenShareViewManager *manager;
@end

@implementation ScreenShareAnnotationView

- (instancetype)initWithFrame:(CGRect)frame
                  strokeColor:(UIColor *)strokeColor {
    if (self = [super initWithFrame:frame]) {
        // init
        _drawingPath = [ScreenSharePath pathWithStrokeColorColor:strokeColor];
        _manager = [ScreenShareViewManager sharedManager];
        [ScreenShareViewManager addPath:_drawingPath];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self.manager.paths enumerateObjectsUsingBlock:^(ScreenSharePath *path, NSUInteger idx, BOOL *stop) {
        
        [path.strokeColor setStroke];
        [path stroke];
    }];
}

#pragma mark - UIResponder
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    [_drawingPath drawAtPoint:touch];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    [_drawingPath drawToPoint:touch];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _drawingPath = [ScreenSharePath pathWithStrokeColorColor:_drawingPath.strokeColor];
    [ScreenShareViewManager addPath:_drawingPath];
}

@end
