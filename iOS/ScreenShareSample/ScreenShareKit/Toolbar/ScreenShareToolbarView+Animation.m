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

- (void)moveSelectionShadowViewTo:(UIButton *)sender
                         animated:(BOOL)animated {
    
    [self setUserInteractionEnabled:NO];
    if (![sender isKindOfClass:[UIButton class]]) return;
    
    CGRect holderViewFrame = sender.superview.frame;
    CGRect hodlerViewBounds = sender.superview.bounds;
    CGPoint holderViewCenter = sender.superview.center;
    if (![self.subviews containsObject:self.selectionShadowView]) {
        
        if (animated) {
            self.selectionShadowView.frame = CGRectMake(holderViewCenter.x, holderViewCenter.y, 0, 0);
            [self insertSubview:self.selectionShadowView atIndex:0];
            [UIView animateWithDuration:1.0 animations:^(){
                self.selectionShadowView.frame = CGRectMake(holderViewFrame.origin.x, holderViewFrame.origin.y, CGRectGetWidth(hodlerViewBounds), CGRectGetHeight(hodlerViewBounds));
            }];
        }
        else {
            self.selectionShadowView.frame = CGRectMake(holderViewFrame.origin.x, holderViewFrame.origin.y, CGRectGetWidth(hodlerViewBounds), CGRectGetHeight(hodlerViewBounds));
            [self insertSubview:self.selectionShadowView atIndex:0];
        }
    }
    else {
        
        if (animated) {
            
            [UIView animateWithDuration:1.0 animations:^(){
                self.selectionShadowView.frame = CGRectMake(holderViewFrame.origin.x, holderViewFrame.origin.y, CGRectGetWidth(hodlerViewBounds), CGRectGetHeight(hodlerViewBounds));
            }];
        }
        else {
            
            self.selectionShadowView.frame = CGRectMake(holderViewFrame.origin.x, holderViewFrame.origin.y, CGRectGetWidth(hodlerViewBounds), CGRectGetHeight(hodlerViewBounds));
        }
    }
    [self setUserInteractionEnabled:YES];
}

- (void)showColorPickerViewWithAnimation:(BOOL)animated; {
    
    CGRect selfFrame = self.frame;
    CGRect selfBounds = self.bounds;
    if (animated) {
        
        [self.superview insertSubview:self.colorPickerView belowSubview:self];
        [UIView animateWithDuration:1.0 animations:^(){
            
            CGFloat newY = selfFrame.origin.y - HeightOfColorPicker - GapOfToolBarAndColorPicker;
            self.colorPickerView.frame = CGRectMake(selfFrame.origin.x, newY, CGRectGetWidth(self.bounds), HeightOfColorPicker);
        }];
    }
    else {
        
        CGFloat newY = selfFrame.origin.y - HeightOfColorPicker - GapOfToolBarAndColorPicker;
        self.colorPickerView.frame = CGRectMake(0, newY, CGRectGetWidth(selfBounds), HeightOfColorPicker);
        [self.superview addSubview:self.colorPickerView];
    }
}

- (void)dismissColorPickerViewWithAnimation:(BOOL)animated {
    
    if (animated) {
        CGRect colorPickerViewFrame = self.colorPickerView.frame;
        [UIView animateWithDuration:1.0 animations:^(){
            
            CGFloat newY = colorPickerViewFrame.origin.y + HeightOfColorPicker + GapOfToolBarAndColorPicker;
            self.colorPickerView.frame = CGRectMake(0, newY, CGRectGetWidth(colorPickerViewFrame), HeightOfColorPicker);
        } completion:^(BOOL finished){
            
            [self.colorPickerView removeFromSuperview];
        }];
    }
    else {
        [self.colorPickerView removeFromSuperview];
    }
}

@end
