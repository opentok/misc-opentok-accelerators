//
//  ScreenShareToolbarView+Animation.m
//  ScreenShareSample
//
//  Created by Xi Huang on 5/10/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "ScreenShareToolbarView+Animation.h"
#import "ScreenShareToolbarView_UserInterfaces.h"
#import "Constants.h"

@implementation ScreenShareToolbarView (Animation)

- (void)moveSelectionShadowViewTo:(UIButton *)sender {
    
    [self setUserInteractionEnabled:NO];
    if (![sender isKindOfClass:[UIButton class]]) {
        [self.selectionShadowView removeFromSuperview];
        return;
    }
    
    CGRect holderViewFrame = sender.superview.frame;
    CGRect hodlerViewBounds = sender.superview.bounds;
    self.selectionShadowView.frame = CGRectMake(holderViewFrame.origin.x, holderViewFrame.origin.y, CGRectGetWidth(hodlerViewBounds), CGRectGetHeight(hodlerViewBounds));
    [self insertSubview:self.selectionShadowView atIndex:0];
    [self setUserInteractionEnabled:YES];
}

- (void)showColorPickerView {
    
    CGRect selfFrame = self.frame;
    [self.superview insertSubview:self.colorPickerView belowSubview:self];
    [UIView animateWithDuration:1.0 animations:^(){
        
        CGFloat newY = selfFrame.origin.y - HeightOfColorPicker - GapOfToolBarAndColorPicker;
        self.colorPickerView.frame = CGRectMake(selfFrame.origin.x, newY, CGRectGetWidth(self.bounds), HeightOfColorPicker);
    }];
}

- (void)dismissColorPickerView {

    CGRect colorPickerViewFrame = self.colorPickerView.frame;
    [UIView animateWithDuration:1.0 animations:^(){
        
        CGFloat newY = colorPickerViewFrame.origin.y + HeightOfColorPicker + GapOfToolBarAndColorPicker;
        self.colorPickerView.frame = CGRectMake(0, newY, CGRectGetWidth(colorPickerViewFrame), HeightOfColorPicker);
    } completion:^(BOOL finished){
        
        [self.colorPickerView removeFromSuperview];
    }];
}

@end
