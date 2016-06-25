//
//  AnnotationPoint.m
//  ScreenShareSample
//
//  Created by Xi Huang on 5/18/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "AnnotationPoint.h"

@interface AnnotationPoint()
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) CGPoint point;
@end

@implementation AnnotationPoint

- (instancetype)initWithX:(CGFloat)x andY:(CGFloat)y {
    if (self = [super init]) {
        _x = x;
        _y = y;
    }
    return self;
}

- (instancetype)initWithTouchPoint:(UITouch *)touchPoint {
    
    if (self = [super init]) {
        CGPoint point = [touchPoint locationInView:touchPoint.view];
        _point = point;
        _x = point.x;
        _y = point.y;
    }
    return self;
}

- (CGPoint)CGPointValue {
    return CGPointMake(_x, _y);
}
@end