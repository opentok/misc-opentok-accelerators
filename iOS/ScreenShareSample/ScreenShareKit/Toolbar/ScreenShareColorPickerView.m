//
//  ScreenShareColorPickerView.m
//  ScreenShareSample
//
//  Created by Xi Huang on 4/28/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "ScreenShareColorPickerView.h"

@interface ScreenShareColorPickerViewButton()

@end

@implementation ScreenShareColorPickerViewButton

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setTitle:nil forState:UIControlStateNormal];
    self.layer.backgroundColor = [UIColor redColor].CGColor;
    self.layer.cornerRadius = CGRectGetWidth([UIScreen mainScreen].bounds) / 9 / 2;
}

@end

@interface ScreenShareColorPickerView()

@end

@implementation ScreenShareColorPickerView

+ (instancetype)colorPickerView {
    
    NSBundle *bundle = [NSBundle bundleForClass:[ScreenShareColorPickerView class]];
    ScreenShareColorPickerView *colorPickerView = [[bundle loadNibNamed:NSStringFromClass([ScreenShareColorPickerView class])
                                                                  owner:nil
                                                                options:nil] lastObject];
    [colorPickerView setBackgroundColor:[UIColor yellowColor]];
    return colorPickerView;
}

@end
