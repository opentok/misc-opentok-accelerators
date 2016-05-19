//
//  AnnotationPoint.h
//  ScreenShareSample
//
//  Created by Xi Huang on 5/18/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnnotationPoint : NSObject
@property (readonly, nonatomic) CGFloat x;
@property (readonly, nonatomic) CGFloat y;
- (instancetype)initWithX:(CGFloat)x
                     andY:(CGFloat)y;
@end
