//
//  ScreenSharePath.m
//  ScreenShareSample
//
//  Created by Xi Huang on 4/26/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "AnnotationPath.h"
#import "AnnotationPoint.h"
#import "AnnotationPoint_Private.h"

@interface AnnotationPath()
@property (nonatomic) UIColor *strokeColor;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic) NSMutableArray<AnnotationPoint *> *mutablePoints;
@end

@implementation AnnotationPath

- (NSArray<AnnotationPoint *> *)points {
    return [_mutablePoints copy];
}

+ (instancetype)pathWithStrokeColor:(UIColor *)strokeColor {
    AnnotationPath *path = [[AnnotationPath alloc] init];
    path.mutablePoints = [[NSMutableArray alloc] init];
    path.strokeColor = strokeColor;
    path.lineWidth = 3.0f;
    return path;
}

+ (instancetype)pathWithPoints:(NSArray<AnnotationPoint *> *)points
                   strokeColor:(UIColor *)strokeColor {
    AnnotationPath *path = [[AnnotationPath alloc] init];
    path.mutablePoints = [[NSMutableArray alloc] initWithArray:points];
    path.strokeColor = strokeColor;
    path.lineWidth = 3.0f;
    
    AnnotationPoint *startPoint = [points firstObject];
    AnnotationPoint *endPoint = [points lastObject];
    path.startPoint = CGPointMake(startPoint.x, startPoint.y);
    path.endPoint = CGPointMake(endPoint.x, endPoint.y);
    
    return path;
}

- (void)drawWholePath {
    AnnotationPoint *fistPoint = [self.points firstObject];
    [self moveToPoint:[fistPoint CGPointValue]];
    for (NSUInteger i = 1; i < self.points.count; i++) {
        [self addLineToPoint:[self.points[i] CGPointValue]];
    }
}

- (void)drawAtPoint:(AnnotationPoint *)touchPoint {

    CGPoint point = [touchPoint CGPointValue];
    [self moveToPoint:point];
    [self addPoint:touchPoint];
}

- (void)drawToPoint:(AnnotationPoint *)touchPoint {
    
    CGPoint p = [touchPoint CGPointValue];
    [self addLineToPoint:p];
    [self addPoint:touchPoint];
}

#pragma mark - private method
- (void)addPoint:(AnnotationPoint *)touchPoint {
    if (_mutablePoints.count == 0) {
        _startPoint = [touchPoint CGPointValue];
    }
    [_mutablePoints addObject:touchPoint];
    _endPoint = [touchPoint CGPointValue];
}
@end
