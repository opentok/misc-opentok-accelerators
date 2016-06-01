//
//  ScreenShareToolBarView.m
//  ScreenShareSample
//
//  Created by Xi Huang on 5/10/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "ScreenShareToolbarView.h"

#import "ScreenShareToolbarView_UserInterfaces.h"
#import "ScreenShareToolbarView+Animation.h"

#import "ScreenShareColorPickerView.h"

#import "ScreenShareToolbarButton.h"

#import <LHToolbar/LHToolbar.h>
#import "Constants.h"

@interface ScreenShareToolbarView() <ScreenShareColorPickerViewProtocol>
@property (nonatomic) LHToolbar *toolbar;
@property (nonatomic) ScreenShareView *screenShareView;

@property (nonatomic) UIButton *doneButton;
@property (nonatomic) ScreenShareToolbarButton *annotateButton;
@property (nonatomic) ScreenShareColorPickerViewButton *colorButton;
@property (nonatomic) ScreenShareToolbarButton *textButton;
@property (nonatomic) ScreenShareToolbarButton *screenshotButton;
@property (nonatomic) ScreenShareToolbarButton *eraseButton;
@end

@implementation ScreenShareToolbarView

- (ScreenShareColorPickerView *)colorPickerView {
    if (!_colorPickerView) {
        _colorPickerView = [[ScreenShareColorPickerView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, CGRectGetWidth([UIScreen mainScreen].bounds), HeightOfColorPicker)];
        _colorPickerView.delegate = self;
    }
    return _colorPickerView;
}

- (UIView *)selectionShadowView {
    if (!_selectionShadowView) {
        _selectionShadowView = [[UIView alloc] init];
        _selectionShadowView.backgroundColor = [UIColor blackColor];
        _selectionShadowView.alpha = 0.8;
    }
    return _selectionShadowView;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
    
        _doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds) / 6, CGRectGetHeight(self.bounds))];
        [_doneButton.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [_doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneButton setBackgroundColor:[UIColor colorWithRed:75.0/255.0f green:157.0/255.0f blue:179.0f/255.0f alpha:1.0]];
        [_doneButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _toolbar = [[LHToolbar alloc] initWithNumberOfItems:5];
        _toolbar.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        [self addSubview:_toolbar];
        self.backgroundColor = [UIColor lightGrayColor];
        [self configureToolbarButtons];
        _screenShareView = [ScreenShareView view];
        [_screenShareView selectColor:self.colorPickerView.selectedColor];
        
        [_screenShareView addObserver:self
                           forKeyPath:@"annotating"
                              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                              context:NULL];
    }
    return self;
}

+ (instancetype)toolbar {
    CGRect mainBounds = [UIScreen mainScreen].bounds;
    return [[ScreenShareToolbarView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(mainBounds) - DefaultToolbarHeight, CGRectGetWidth(mainBounds), DefaultToolbarHeight)];
}

- (void)configureToolbarButtons {

    NSBundle *frameworkBundle = [NSBundle bundleForClass:self.class];
    
    _annotateButton = [[ScreenShareToolbarButton alloc] init];
    [_annotateButton setImage:[UIImage imageNamed:@"annotate" inBundle:frameworkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_annotateButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _colorButton = [[ScreenShareColorPickerViewButton alloc] init];
    [_colorButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    _textButton = [[ScreenShareToolbarButton alloc] init];
    [_textButton setImage:[UIImage imageNamed:@"text" inBundle:frameworkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_textButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _screenshotButton = [[ScreenShareToolbarButton alloc] init];
    [_screenshotButton setImage:[UIImage imageNamed:@"screenshot" inBundle:frameworkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    _screenshotButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_screenshotButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _eraseButton = [[ScreenShareToolbarButton alloc] init];
    [_eraseButton setImage:[UIImage imageNamed:@"erase" inBundle:frameworkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_eraseButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.toolbar setContentView:_annotateButton atIndex:0];
    [self.toolbar setContentView:_colorButton atIndex:1];
    [self.toolbar setContentView:_textButton atIndex:2];
    [self.toolbar setContentView:_screenshotButton atIndex:3];
    [self.toolbar setContentView:_eraseButton atIndex:4];
    
    [self.toolbar reloadToolbar];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqual:@"annotating"] && [change[@"new"] boolValue] != [change[@"old"] boolValue]) {
        if ([change[@"new"] boolValue]) {
            [self.toolbar insertContentView:self.doneButton atIndex:0];
        }
        else {
            [self.toolbar removeContentViewAtIndex:0];
        }
    }
}

- (void)toolbarButtonPressed:(UIButton *)sender {
    
    [self.selectionShadowView removeFromSuperview];
    
    if (sender == self.doneButton) {
        self.screenShareView.annotating = NO;
        [self dismissColorPickerView];
    }
    else if (sender == self.annotateButton) {
        self.screenShareView.annotating = YES;
        [self.screenShareView selectColor:self.colorPickerView.selectedColor];
        [self dismissColorPickerView];
    }
    else if (sender == self.textButton) {
        self.screenShareView.annotating = YES;
        [self.screenShareView addTextAnnotationWithColor:self.colorButton.backgroundColor];
    }
    else if (sender == self.colorButton) {
        [self showColorPickerView];
    }
    else if (sender == self.eraseButton) {
        [self.screenShareView erase];
    }
    else if (sender == self.screenshotButton) {
        [self.screenShareView captureAndShare];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (sender != self.eraseButton && sender != self.screenshotButton) {
            [self moveSelectionShadowViewTo:sender];
        }
    });
}

#pragma mark - ScreenShareColorPickerViewProtocol
- (void)colorPickerView:(ScreenShareColorPickerView *)colorPickerView
   didSelectColorButton:(ScreenShareColorPickerViewButton *)button
          selectedColor:(UIColor *)selectedColor {
    
    [self.colorButton setBackgroundColor:selectedColor];
    [self.screenShareView selectColor:selectedColor];
}

@end
