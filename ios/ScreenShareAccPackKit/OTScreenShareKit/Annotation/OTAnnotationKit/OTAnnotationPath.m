//
//  ScreenSharePath.m
//  
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotationPath.h"
#import "OTAnnotationPoint.h"
#import "OTAnnotationPoint_Private.h"

@interface OTAnnotationPath()
@property (nonatomic) UIColor *strokeColor;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic) NSMutableArray<OTAnnotationPoint *> *mutablePoints;
@end

@implementation OTAnnotationPath

- (NSArray<OTAnnotationPoint *> *)points {
    return [_mutablePoints copy];
}

+ (instancetype)pathWithStrokeColor:(UIColor *)strokeColor {
    OTAnnotationPath *path = [[OTAnnotationPath alloc] init];
    path.mutablePoints = [[NSMutableArray alloc] init];
    path.strokeColor = strokeColor;
    path.lineWidth = 3.0f;
    return path;
}

+ (instancetype)pathWithPoints:(NSArray<OTAnnotationPoint *> *)points
                   strokeColor:(UIColor *)strokeColor {
    OTAnnotationPath *path = [[OTAnnotationPath alloc] init];
    path.mutablePoints = [[NSMutableArray alloc] initWithArray:points];
    path.strokeColor = strokeColor;
    path.lineWidth = 3.0f;
    
    OTAnnotationPoint *startPoint = [points firstObject];
    OTAnnotationPoint *endPoint = [points lastObject];
    path.startPoint = CGPointMake(startPoint.x, startPoint.y);
    path.endPoint = CGPointMake(endPoint.x, endPoint.y);
    
    return path;
}

- (void)drawWholePath {
    OTAnnotationPoint *fistPoint = [self.points firstObject];
    [self moveToPoint:[fistPoint CGPointValue]];
    for (NSUInteger i = 1; i < self.points.count; i++) {
        [self addLineToPoint:[self.points[i] CGPointValue]];
    }
}

- (void)drawAtPoint:(OTAnnotationPoint *)touchPoint {

    CGPoint point = [touchPoint CGPointValue];
    [self moveToPoint:point];
    [self addPoint:touchPoint];
}

- (void)drawToPoint:(OTAnnotationPoint *)touchPoint {
    
    CGPoint p = [touchPoint CGPointValue];
    [self addLineToPoint:p];
    [self addPoint:touchPoint];
}

#pragma mark - private method
- (void)addPoint:(OTAnnotationPoint *)touchPoint {
    if (_mutablePoints.count == 0) {
        _startPoint = [touchPoint CGPointValue];
    }
    [_mutablePoints addObject:touchPoint];
    _endPoint = [touchPoint CGPointValue];
}
@end
