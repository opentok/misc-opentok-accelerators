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

#import <LHToolbar/LHToolbar.h>
#import "Constants.h"

@interface ScreenShareToolbarView()
@property (nonatomic) LHToolbar *toolbar;

@property (nonatomic) UIButton *annotateButton;
@property (nonatomic) UIButton *colorButton;
@property (nonatomic) UIButton *textButton;
@property (nonatomic) UIButton *screenshotButton;
@property (nonatomic) UIButton *eraseButton;
@end

@implementation ScreenShareToolbarView

- (ScreenShareColorPickerView *)colorPickerView {
    if (!_colorPickerView) {
        _colorPickerView = [[ScreenShareColorPickerView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, CGRectGetWidth([UIScreen mainScreen].bounds), HeightOfColorPicker)];
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

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _toolbar = [[LHToolbar alloc] initWithNumberOfItems:5];
        _toolbar.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        [self addSubview:_toolbar];
        self.backgroundColor = [UIColor lightGrayColor];
        [self configureToolbarButtons];
    }
    return self;
}

- (void)configureToolbarButtons {
    NSUInteger gap = 4;
    CGRect mainScreenBounds = [UIScreen mainScreen].bounds;
    CGFloat widthOfButton = CGRectGetWidth(mainScreenBounds) / 5;
    NSBundle *frameworkBundle = [NSBundle bundleForClass:self.class];
    
    _annotateButton = [[UIButton alloc] init];
    [_annotateButton setImage:[UIImage imageNamed:@"annotate" inBundle:frameworkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_annotateButton setBackgroundColor:[UIColor clearColor]];
    _annotateButton.frame = CGRectMake(gap, gap, widthOfButton - gap * 2, CGRectGetHeight(self.frame) - gap * 2);
    [_annotateButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _colorButton = [[UIButton alloc] init];
    [_colorButton setBackgroundColor:[UIColor blackColor]];
    _colorButton.frame = CGRectMake(gap, gap, CGRectGetHeight(self.frame) - gap * 2, CGRectGetHeight(self.frame) - gap * 2);
    [_colorButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    _textButton = [[UIButton alloc] init];
    [_textButton setImage:[UIImage imageNamed:@"text" inBundle:frameworkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_textButton setBackgroundColor:[UIColor clearColor]];
    _textButton.frame = CGRectMake(gap, gap, widthOfButton - gap * 2, CGRectGetHeight(self.frame) - gap * 2);
    [_textButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _screenshotButton = [[UIButton alloc] init];
    [_screenshotButton setImage:[UIImage imageNamed:@"screenshot" inBundle:frameworkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_screenshotButton setBackgroundColor:[UIColor clearColor]];
    _screenshotButton.frame = CGRectMake(gap, gap, widthOfButton - gap * 2, CGRectGetHeight(self.frame) - gap * 2);
    [_screenshotButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _eraseButton = [[UIButton alloc] init];
    [_eraseButton setImage:[UIImage imageNamed:@"erase" inBundle:frameworkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_eraseButton setBackgroundColor:[UIColor clearColor]];
    _eraseButton.frame = CGRectMake(gap, gap, widthOfButton - gap * 2, CGRectGetHeight(self.frame) - gap * 2);
    [_eraseButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.toolbar setContentView:_annotateButton atIndex:0];
    [self.toolbar setContentView:_colorButton atIndex:1];
    [self.toolbar setContentView:_textButton atIndex:2];
    [self.toolbar setContentView:_screenshotButton atIndex:3];
    [self.toolbar setContentView:_eraseButton atIndex:4];
    
    [self.toolbar reloadToolbar];
}

- (void)toolbarButtonPressed:(UIButton *)sender {
    [self moveSelectionShadowViewTo:sender animated:YES];
    
    if (sender == self.colorButton) {
        [self showColorPickerViewWithAnimation:YES];
    }
    else {
        [self dismissColorPickerViewWithAnimation:YES];
    }
}

@end
