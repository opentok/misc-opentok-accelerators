//
//  ScreenShareColorPickerView.h
//  ScreenShareSample
//
//  Created by Xi Huang on 4/28/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AnnotationColorPickerView;

@interface AnnotationColorPickerViewButton : UIButton
@end

@protocol AnnotationColorPickerViewProtocol <NSObject>
- (void)colorPickerView:(AnnotationColorPickerView *)colorPickerView
   didSelectColorButton:(AnnotationColorPickerViewButton *)button
          selectedColor:(UIColor *)selectedColor;
@end

@interface AnnotationColorPickerView : UIView
- (instancetype)initWithFrame:(CGRect)frame;
@property (readonly, nonatomic) UIColor *selectedColor;
@property (nonatomic) id<AnnotationColorPickerViewProtocol> delegate;
@end
