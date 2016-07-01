//
//  AnnotationPoint.h
//  
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTAnnotationPoint : NSObject
@property (readonly, nonatomic) CGFloat x;
@property (readonly, nonatomic) CGFloat y;
- (instancetype)initWithX:(CGFloat)x
                     andY:(CGFloat)y;
@end
