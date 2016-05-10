//
//  ScreenShareToolBarView.m
//  ScreenShareSample
//
//  Created by Xi Huang on 5/10/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "ScreenShareToolbarView.h"
#import "ScreenShareColorPickerView.h"

@interface ScreenShareToolbarView()
@property (weak, nonatomic) IBOutlet UIButton *annotateButton;
@property (weak, nonatomic) IBOutlet ScreenShareColorPickerViewButton *colorPickerButton;
@property (weak, nonatomic) IBOutlet UIButton *textButton;
@property (weak, nonatomic) IBOutlet UIButton *screenShotButton;
@property (weak, nonatomic) IBOutlet UIButton *eraseButton;
@end

@implementation ScreenShareToolbarView

+ (instancetype)screenShareToolbarView {
    
    NSBundle *bundle = [NSBundle bundleForClass:[ScreenShareToolbarView class]];
    ScreenShareToolbarView *toolbarView = [[bundle loadNibNamed:NSStringFromClass([ScreenShareToolbarView class])
                                                                  owner:nil
                                                                options:nil] lastObject];
    return toolbarView;
}

@end
