//
//  ScreenShareView.h
//  ScreenShareSample
//
//  Created by Xi Huang on 4/26/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScreenShareView : UIView

+ (instancetype)viewWithStrokeColor:(UIColor *)color;

@property (nonatomic) UIColor *strokeColor;
@property (nonatomic) BOOL scrollEnabled;

@end
