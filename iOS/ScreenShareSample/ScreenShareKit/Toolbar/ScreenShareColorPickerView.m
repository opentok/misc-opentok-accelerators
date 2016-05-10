//
//  ScreenShareColorPickerView.m
//  ScreenShareSample
//
//  Created by Xi Huang on 4/28/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "ScreenShareColorPickerView.h"

#pragma mark - ScreenShareColorPickerViewButton
@implementation ScreenShareColorPickerViewButton

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.borderWidth = 2.0f;
    self.layer.borderColor = [UIColor clearColor].CGColor;
    self.clipsToBounds = YES;
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

#pragma mark - ScreenShareColorPickerView
@interface ScreenShareColorPickerView()
@property (nonatomic) ScreenShareColorPickerViewButton *selectedButton;
@end

@implementation ScreenShareColorPickerView

- (UIColor *)selectedColor {
    if (!self.selectedButton) return nil;
    return self.selectedButton.backgroundColor;
}

- (instancetype)init {
    return [ScreenShareColorPickerView colorPickerView];
}

- (instancetype)initWithFrame:(CGRect)frame {
    ScreenShareColorPickerView *pickerView = [ScreenShareColorPickerView colorPickerView];
    pickerView.frame = frame;
    return pickerView;
}

+ (instancetype)colorPickerView {
    
    NSBundle *bundle = [NSBundle bundleForClass:[ScreenShareColorPickerView class]];
    ScreenShareColorPickerView *colorPickerView = [[bundle loadNibNamed:NSStringFromClass([ScreenShareColorPickerView class])
                                                                  owner:nil
                                                                options:nil] lastObject];
    [colorPickerView configureColorPickerButtons];
    return colorPickerView;
}

- (void)configureColorPickerButtons {
    
    
    NSDictionary *colorDict = @{
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
    
    
    for (NSUInteger i = 1; i < 10; i++) {
        
        ScreenShareColorPickerViewButton *button = [self viewWithTag:i];
        UIColor *buttonColor = colorDict[@(i)];
        [button setBackgroundColor:buttonColor];
    }
}

- (IBAction)colorButtonPressed:(ScreenShareColorPickerViewButton *)sender {
    [self.selectedButton setSelected:NO];
    self.selectedButton = sender;
    [self.selectedButton setSelected:YES];
    
    if (self.delegate) {
        [self.delegate colorPickerView:self didSelectColor:self.selectedButton.backgroundColor];
    }
}


@end
