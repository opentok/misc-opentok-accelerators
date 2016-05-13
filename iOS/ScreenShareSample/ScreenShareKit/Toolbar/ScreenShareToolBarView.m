//
//  ScreenShareToolBarView.m
//  ScreenShareSample
//
//  Created by Xi Huang on 5/10/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "ScreenShareToolbarView.h"
#import "ScreenShareColorPickerView.h"

#import "ScreenShareToolbarView_UserInterfaces.h"
#import "ScreenShareToolbarView+Animation.h"

@interface ScreenShareToolbarView()
@end

@implementation ScreenShareToolbarView

- (ScreenShareColorPickerView *)colorPickerView {
    if (!_colorPickerView) {
        _colorPickerView = [ScreenShareColorPickerView colorPickerView];
    }
    return _colorPickerView;
}

- (UIView *)selectionShadowView {
    if (!_selectionShadowView) {
        _selectionShadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds) / 5, CGRectGetHeight([UIScreen mainScreen].bounds))];
        _selectionShadowView.backgroundColor = [UIColor blackColor];
        _selectionShadowView.alpha = 0.8;
    }
    return _selectionShadowView;
}

+ (instancetype)screenShareToolbarView {
    
    NSBundle *bundle = [NSBundle bundleForClass:[ScreenShareToolbarView class]];
    ScreenShareToolbarView *toolbarView = [[bundle loadNibNamed:NSStringFromClass([ScreenShareToolbarView class])
                                                                  owner:nil
                                                                options:nil] lastObject];
    return toolbarView;
}

- (IBAction)toolbarButtonPressed:(UIButton *)sender {
    [self moveSelectionShadowViewTo:sender animated:YES];
    
    if (sender == self.toolbarButtons[1]) {
        [self addColorPickerViewWithAnimation:YES];
    }
    else {
        [self removeColorPickerViewWithAnimation:YES];
    }
}

@end
