//
//  ScreenSharePath.h
//  ScreenShareSample
//
//  Created by Xi Huang on 4/26/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "ScreenShareView.h"

@interface ScreenSharePath : UIBezierPath

@property (nonatomic) UIColor *strokeColor;

@property (nonatomic, readonly) CGPoint startPoint;
@property (nonatomic, readonly) CGPoint endPoint;
@property (nonatomic, readonly) NSArray<UITouch *> *points;
- (void)drawAtPoint:(UITouch *)touchPoint;
- (void)drawToPoint:(UITouch *)touchPoint;
+ (instancetype)pathWithStrokeColorColor:(UIColor *)strokeColor;
@end
