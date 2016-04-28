//
//  ScreenShareView.m
//  ScreenShareSample
//
//  Created by Xi Huang on 4/26/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "ScreenShareView.h"
#import "ScreenSharePath.h"
#import "ScreenShareViewManager.h"

@interface ScreenShareView()
@property (nonatomic) ScreenSharePath *drawingPath;
@property (nonatomic) ScreenShareViewManager *manager;
@end

@implementation ScreenShareView

+ (instancetype)viewWithStrokeColor:(UIColor *)color {
    return [[ScreenShareView alloc] initWithStrokeColor:color];
}

- (instancetype)initWithStrokeColor:(UIColor *)strokeColor {
    if (self = [super init]) {
        _drawingPath = [ScreenSharePath pathWithStrokeColorColor:strokeColor];
        _manager = [ScreenShareViewManager sharedManager];
        [ScreenShareViewManager addPath:_drawingPath];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

//TODO: this needs to be re-implemented using cache image rather than drawing all the path
- (void)drawRect:(CGRect)rect
{
    [self.manager.paths enumerateObjectsUsingBlock:^(ScreenSharePath *path, NSUInteger idx, BOOL *stop) {
        
        [path.strokeColor setStroke];
        [path stroke];
    }];
}

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
