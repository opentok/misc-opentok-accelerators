//
//  ScreenShareToolbarButton.m
//  ScreenShareSample
//
//  Created by Xi Huang on 5/24/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "AnnotationToolbarButton.h"
#import "UIButton+AutoLayoutHelper.h"

@implementation AnnotationToolbarButton

- (instancetype)init {
    if (self = [super init]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    super.enabled = enabled;
    
    if (enabled) {
        [self setAlpha:1.0];
    }
    else {
        [self setAlpha:0.6];
    }
}

- (void)didMoveToSuperview {
    if (!self.superview) return;
    [self addCenterConstraints];
}

@end
