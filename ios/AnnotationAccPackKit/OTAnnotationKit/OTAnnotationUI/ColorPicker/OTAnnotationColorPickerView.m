//
//  OTAnnotationColorPickerView.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotationColorPickerView.h"
#import "UIButton+AutoLayoutHelper.h"
#import "UIView+Helper.h"
#import "Constants.h"

#pragma mark - ScreenShareColorPickerViewButton
@implementation OTAnnotationColorPickerViewButton

- (instancetype)init {
    if (self = [super init]) {
        self.layer.borderWidth = 2.0f;
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.clipsToBounds = YES;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor colorWithRed:68.0/255.0f green:140.0/255.0f blue:230.0/255.0f alpha:1.0];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2.0;
}

- (void)didMoveToSuperview {
    if (!self.superview) return;
    [self addCenterConstraints];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    heightConstraint.active = YES;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        self.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    else {
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

@end


#import <LHToolbar/LHToolbar.h>

#pragma mark - ScreenShareColorPickerView
@interface OTAnnotationColorPickerView()
@property (nonatomic) OTAnnotationColorPickerViewButton *selectedButton;
@property (nonatomic) NSDictionary *colorDict;
@property (nonatomic) LHToolbar *colorToolbar;
@end

@implementation OTAnnotationColorPickerView

- (void)setAnnotationColorPickerViewOrientation:(OTAnnotationColorPickerViewOrientation)annotationColorPickerViewOrientation {
    _annotationColorPickerViewOrientation = annotationColorPickerViewOrientation;
    if (annotationColorPickerViewOrientation == OTAnnotationColorPickerViewOrientationPortrait) {
        self.colorToolbar.orientation = LHToolbarOrientationHorizontal;
    }
    else if (annotationColorPickerViewOrientation == OTAnnotationColorPickerViewOrientationLandscape) {
        self.colorToolbar.orientation = LHToolbarOrientationVertical;
    }
    [self.colorToolbar reloadToolbar];
}

- (UIColor *)selectedColor {
    if (!self.selectedButton) return nil;
    return self.selectedButton.backgroundColor;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        _colorDict = @{
                       @1: [UIColor colorWithRed:68.0/255.0f green:140.0/255.0f blue:230.0/255.0f alpha:1.0],
                       @2: [UIColor colorWithRed:179.0/255.0f green:0/255.0f blue:223.0/255.0f alpha:1.0],
                       @3: [UIColor redColor],
                       @4: [UIColor colorWithRed:245.0/255.0f green:152.0/255.0f blue:0/255.0f alpha:1.0],
                       @5: [UIColor colorWithRed:247.0/255.0f green:234.0/255.0f blue:0/255.0f alpha:1.0],
                       @6: [UIColor colorWithRed:101.0/255.0f green:210.0/255.0f blue:0.0/255.0f alpha:1.0],
                       @7: [UIColor blackColor],
                       @8: [UIColor grayColor],
                       @9: [UIColor whiteColor]
                    };
        
        
        _colorToolbar = [[LHToolbar alloc] initWithNumberOfItems:self.colorDict.count];
        _colorToolbar.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_colorToolbar];
        [_colorToolbar addAttachedLayoutConstantsToSuperview];
        self.backgroundColor = [UIColor colorWithRed:38.0 / 255.0 green:38.0 / 255.0 blue:38.0 / 255.0 alpha:1.0];
        [self configureColorPickerButtons];
    }
    return self;
}

- (void)configureColorPickerButtons {

    // first button
    OTAnnotationColorPickerViewButton *button = [[OTAnnotationColorPickerViewButton alloc] init];
    [button setBackgroundColor:self.colorDict[@(1)]];
    [button addTarget:self action:@selector(colorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.colorToolbar setContentView:button atIndex:0];
    self.selectedButton = button;
    [self.selectedButton setSelected:YES];
    
    for (NSUInteger i = 2; i < 10; i++) {
        
        OTAnnotationColorPickerViewButton *button = [[OTAnnotationColorPickerViewButton alloc] init];
        [button setBackgroundColor:self.colorDict[@(i)]];
        [button addTarget:self action:@selector(colorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.colorToolbar setContentView:button atIndex:i - 1];
    }
    [self.colorToolbar reloadToolbar];
}

- (void)colorButtonPressed:(OTAnnotationColorPickerViewButton *)sender {
    [self.selectedButton setSelected:NO];
    self.selectedButton = sender;
    [self.selectedButton setSelected:YES];
    
    if (self.delegate) {
        [self.delegate colorPickerView:self
                  didSelectColorButton:self.selectedButton
                         selectedColor:self.selectedColor];
    }
}


@end
