//
//  ScreenShareColorPickerView.m
//  ScreenShareSample
//
//  Created by Xi Huang on 4/28/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "ScreenShareColorPickerView.h"

@interface ScreenShareColorPickerViewButton : UIButton
@end

#pragma mark - ScreenShareColorPickerViewButton
@implementation ScreenShareColorPickerViewButton

- (instancetype)init {
    if (self = [super init]) {
        self.layer.borderWidth = 2.0f;
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2.0;
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
#import "Constants.h"

#pragma mark - ScreenShareColorPickerView
@interface ScreenShareColorPickerView()
@property (nonatomic) ScreenShareColorPickerViewButton *selectedButton;
@property (nonatomic) NSDictionary *colorDict;
@property (nonatomic) LHToolbar *colorToolbar;
@end

@implementation ScreenShareColorPickerView

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
        _colorToolbar.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        [self addSubview:_colorToolbar];
        self.backgroundColor = [UIColor colorWithRed:38.0 / 255.0 green:38.0 / 255.0 blue:38.0 / 255.0 alpha:1.0];
        [self configureColorPickerButtons];
    }
    return self;
}

- (void)configureColorPickerButtons {
    
    NSUInteger gap = 4;
    CGRect mainScreenBounds = [UIScreen mainScreen].bounds;
    CGFloat widthOfButton = CGRectGetWidth(mainScreenBounds) / self.colorDict.count;
    
    for (NSUInteger i = 1; i < 10; i++) {
        
        ScreenShareColorPickerViewButton *button = [[ScreenShareColorPickerViewButton alloc] init];
        button.frame = CGRectMake(gap, gap, widthOfButton - 2 * gap, widthOfButton - 2 * gap);
        [button setBackgroundColor:self.colorDict[@(i)]];
        [button addTarget:self action:@selector(colorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.colorToolbar addContentView:button atIndex:i - 1];
    }
    [self.colorToolbar reloadToolbar];
}

- (void)colorButtonPressed:(ScreenShareColorPickerViewButton *)sender {
    [self.selectedButton setSelected:NO];
    self.selectedButton = sender;
    [self.selectedButton setSelected:YES];
    
    if (self.delegate) {
        [self.delegate colorPickerView:self didSelectColor:self.selectedButton.backgroundColor];
    }
}


@end
