//
//  AnnotationPoint_Private.h
//  ScreenShareSample
//
//  Created by Xi Huang on 5/18/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "OTAnnotationPoint.h"

@interface OTAnnotationPoint ()
- (instancetype)initWithTouchPoint:(UITouch *)touchPoint;
- (CGPoint)CGPointValue;
@end
