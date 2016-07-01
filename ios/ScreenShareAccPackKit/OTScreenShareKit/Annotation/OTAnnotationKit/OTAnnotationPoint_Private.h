//
//  AnnotationPoint_Private.h
//  
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotationPoint.h"

@interface OTAnnotationPoint ()
- (instancetype)initWithTouchPoint:(UITouch *)touchPoint;
- (CGPoint)CGPointValue;
@end
