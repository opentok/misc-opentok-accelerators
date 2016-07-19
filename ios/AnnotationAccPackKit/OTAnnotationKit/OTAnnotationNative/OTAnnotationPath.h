//
//  ScreenSharePath.h
//
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <OTAnnotationKit/OTAnnotatable.h>

@interface OTAnnotationPoint : NSObject

@property (readonly, nonatomic) CGFloat x;

@property (readonly, nonatomic) CGFloat y;

@property (readonly, nonatomic) CGPoint cgPoint;

+ (instancetype)pointWithX:(CGFloat)x
                      andY:(CGFloat)y;

@end

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
