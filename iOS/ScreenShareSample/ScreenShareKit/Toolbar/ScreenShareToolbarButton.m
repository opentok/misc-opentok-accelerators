//
//  ScreenShareToolbarButton.m
//  ScreenShareSample
//
//  Created by Xi Huang on 5/24/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "ScreenShareToolbarButton.h"
#import "UIButton+AutoLayoutHelper.h"

@implementation ScreenShareToolbarButton

- (instancetype)init {
    if (self = [super init]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
    }
    return self;
}

- (void)didMoveToSuperview {
    
    if (!self.superview) return;
    [self addCenterConstraints];
}

@end
