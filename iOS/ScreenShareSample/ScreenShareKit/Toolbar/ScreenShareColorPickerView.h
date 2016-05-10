//
//  ScreenShareColorPickerView.h
//  ScreenShareSample
//
//  Created by Xi Huang on 4/28/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScreenShareColorPickerViewButton: UIButton
@end

@class ScreenShareColorPickerView;
@protocol ScreenShareColorPickerView <NSObject>
- (void)colorPickerView:(ScreenShareColorPickerView *)colorPickerView
       didSelectColor:(UIColor *)color;
@end

@interface ScreenShareColorPickerView : UIView

+ (instancetype)colorPickerView;

@property (readonly, nonatomic) UIColor *selectedColor;
@property (nonatomic) id<ScreenShareColorPickerView> delegate;

@end
