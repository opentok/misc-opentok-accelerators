//
//  ScreenShareView.h
//  ScreenShareSample
//
//  Created by Xi Huang on 4/26/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScreenShareView : UIView

+ (instancetype)view;

- (void)addContentView:(UIView *)view;

@property (nonatomic, getter = isAnnotating) BOOL annotating;

- (void)addTextAnnotationWithColor:(UIColor *)color;

- (void)selectColor:(UIColor *)selectedColor;

- (void)captureAndShare;

- (void)erase;

@end
