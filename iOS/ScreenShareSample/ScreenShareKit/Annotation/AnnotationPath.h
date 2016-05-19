//
//  ScreenSharePath.h
//  ScreenShareSample
//
//  Created by Xi Huang on 4/26/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <ScreenShareKit/Annotatable.h>
#import <ScreenShareKit/AnnotationPoint.h>

@interface AnnotationPath : UIBezierPath <Annotatable>

@property (readonly, nonatomic) UIColor *strokeColor;

@property (readonly, nonatomic) CGPoint startPoint;
@property (readonly, nonatomic) CGPoint endPoint;
@property (readonly, nonatomic) NSArray<AnnotationPoint *> *points;

+ (instancetype)pathWithStrokeColor:(UIColor *)strokeColor;
- (void)drawAtPoint:(AnnotationPoint *)touchPoint;
- (void)drawToPoint:(AnnotationPoint *)touchPoint;

+ (instancetype)pathWithPoints:(NSArray<AnnotationPoint *> *)points
                   strokeColor:(UIColor *)strokeColor;
- (void)drawWholePath;
@end
