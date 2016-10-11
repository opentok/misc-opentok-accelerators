//
//  OTAnnotationToolbarView+Animation.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotationToolbarView+Animation.h"
#import "OTAnnotationToolbarView_UserInterfaces.h"
#import "Constants.h"

@implementation OTAnnotationToolbarView (Animation)

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
    
    if (!self.colorPickerView.superview) {
        CGRect selfFrame = self.frame;
        self.colorPickerView.frame = selfFrame;
        [self.superview insertSubview:self.colorPickerView belowSubview:self];
        
        [UIView animateWithDuration:1.0 animations:^(){
            
            
            if (self.toolbarViewOrientation == OTAnnotationToolbarViewOrientationPortraitlBottom) {
                CGFloat newY = selfFrame.origin.y - HeightOfColorPicker;
                self.colorPickerView.frame = CGRectMake(selfFrame.origin.x, newY, CGRectGetWidth(self.bounds), HeightOfColorPicker);
            }
            else if (self.toolbarViewOrientation == OTAnnotationToolbarViewOrientationLandscapeLeft) {
                CGFloat newX = selfFrame.origin.x + HeightOfColorPicker;
                self.colorPickerView.frame = CGRectMake(newX, selfFrame.origin.y, WidthOfColorPicker, CGRectGetHeight(self.bounds));
            }
            else if (self.toolbarViewOrientation == OTAnnotationToolbarViewOrientationLandscapeRight) {
                CGFloat newX = selfFrame.origin.x - HeightOfColorPicker;
                self.colorPickerView.frame = CGRectMake(newX, selfFrame.origin.y, WidthOfColorPicker, CGRectGetHeight(self.bounds));
            }
        }];
    }
    else {
        [self dismissColorPickerView];
    }
}

- (void)dismissColorPickerView {

    CGRect colorPickerViewFrame = self.colorPickerView.frame;
    [UIView animateWithDuration:1.0 animations:^(){
        
        if (self.toolbarViewOrientation == OTAnnotationToolbarViewOrientationPortraitlBottom) {
            CGFloat newY = colorPickerViewFrame.origin.y + HeightOfColorPicker;
            self.colorPickerView.frame = CGRectMake(0, newY, CGRectGetWidth(colorPickerViewFrame), HeightOfColorPicker);
        }
        else if (self.toolbarViewOrientation == OTAnnotationToolbarViewOrientationLandscapeLeft) {
            CGFloat newX = colorPickerViewFrame.origin.x - WidthOfColorPicker;
            self.colorPickerView.frame = CGRectMake(newX, 0, WidthOfColorPicker, CGRectGetHeight(colorPickerViewFrame));
        }
        else if (self.toolbarViewOrientation == OTAnnotationToolbarViewOrientationLandscapeRight) {
            CGFloat newX = colorPickerViewFrame.origin.x + WidthOfColorPicker;
            self.colorPickerView.frame = CGRectMake(newX, 0, WidthOfColorPicker, CGRectGetHeight(colorPickerViewFrame));
        }
    } completion:^(BOOL finished){
        
        [self.colorPickerView removeFromSuperview];
    }];
}

@end
