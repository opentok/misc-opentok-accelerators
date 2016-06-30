//
//  ScreenShareColorPickerView.h
//  ScreenShareSample
//
//  Created by Xi Huang on 4/28/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OTAnnotationColorPickerView;

@interface OTAnnotationColorPickerViewButton : UIButton
@end

@protocol OTAnnotationColorPickerViewProtocol <NSObject>
- (void)colorPickerView:(OTAnnotationColorPickerView *)colorPickerView
   didSelectColorButton:(OTAnnotationColorPickerViewButton *)button
          selectedColor:(UIColor *)selectedColor;
@end

@interface OTAnnotationColorPickerView : UIView
- (instancetype)initWithFrame:(CGRect)frame;
@property (readonly, nonatomic) UIColor *selectedColor;
@property (nonatomic) id<OTAnnotationColorPickerViewProtocol> delegate;
@end
