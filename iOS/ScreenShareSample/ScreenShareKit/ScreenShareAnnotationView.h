//
//  ScreenShareAnnotationView.h
//  ScreenShareSample
//
//  Created by Xi Huang on 5/2/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "ScreenSharePath.h"

@interface ScreenShareAnnotationView : UIView

@property (nonatomic) ScreenSharePath *drawingPath;
- (instancetype)initWithFrame:(CGRect)frame
                  strokeColor:(UIColor *)strokeColor;

@end
