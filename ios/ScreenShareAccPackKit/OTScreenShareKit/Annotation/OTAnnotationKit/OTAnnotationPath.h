//
//  OTAnnotationPath.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotatable.h"
#import "OTAnnotationPoint.h"

@interface OTAnnotationPath : UIBezierPath <OTAnnotatable>

@property (readonly, nonatomic) UIColor *strokeColor;

@property (readonly, nonatomic) CGPoint startPoint;
@property (readonly, nonatomic) CGPoint endPoint;
@property (readonly, nonatomic) NSArray<OTAnnotationPoint *> *points;

+ (instancetype)pathWithStrokeColor:(UIColor *)strokeColor;
- (void)drawAtPoint:(OTAnnotationPoint *)touchPoint;
- (void)drawToPoint:(OTAnnotationPoint *)touchPoint;

+ (instancetype)pathWithPoints:(NSArray<OTAnnotationPoint *> *)points
                   strokeColor:(UIColor *)strokeColor;
- (void)drawWholePath;
@end
