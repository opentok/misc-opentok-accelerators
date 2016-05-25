//
//  ScreenShareColorPickerView.h
//  ScreenShareSample
//
//  Created by Xi Huang on 4/28/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScreenShareColorPickerView;

@interface ScreenShareColorPickerViewButton : UIButton
@end

@protocol ScreenShareColorPickerViewProtocol <NSObject>
- (void)colorPickerView:(ScreenShareColorPickerView *)colorPickerView
   didSelectColorButton:(ScreenShareColorPickerViewButton *)button
          selectedColor:(UIColor *)selectedColor;
@end

@interface ScreenShareColorPickerView : UIView
- (instancetype)initWithFrame:(CGRect)frame;
@property (readonly, nonatomic) UIColor *selectedColor;
@property (nonatomic) id<ScreenShareColorPickerViewProtocol> delegate;
@end
