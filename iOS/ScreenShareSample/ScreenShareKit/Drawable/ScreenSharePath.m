//
//  ScreenSharePath.m
//  ScreenShareSample
//
//  Created by Xi Huang on 4/26/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "ScreenSharePath.h"

@interface ScreenSharePath()
@property (nonatomic) NSMutableArray<UITouch *> *mutablePoints;
@end

@implementation ScreenSharePath

- (NSArray<UITouch *> *)points {
    return [_mutablePoints copy];
}

+ (instancetype)pathWithStrokeColorColor:(UIColor *)strokeColor {
    ScreenSharePath *path = [[ScreenSharePath alloc] init];
    path.mutablePoints = [[NSMutableArray alloc] init];
    path.strokeColor = strokeColor;
    path.lineWidth = 3.0f;
    return path;
}

- (void)drawAtPoint:(UITouch *)touchPoint {

    CGPoint point = [touchPoint locationInView:touchPoint.view];
    [self moveToPoint:point];
    [self addPoint:touchPoint];
}

- (void)drawToPoint:(UITouch *)touchPoint {
    
    CGPoint p = [touchPoint locationInView:touchPoint.view];
    [self addLineToPoint:p];
    [self addPoint:touchPoint];
}

- (void)addPoint:(UITouch *)touchPoint {
    if (_mutablePoints.count == 0) {
        _startPoint = [touchPoint locationInView:touchPoint.view];
    }
    [_mutablePoints addObject:touchPoint];
    _endPoint = [touchPoint locationInView:touchPoint.view];
}
@end
