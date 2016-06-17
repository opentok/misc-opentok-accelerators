//
//  ScreenShareToolbarView+Animation.h
//  ScreenShareSample
//
//  Created by Xi Huang on 5/10/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <ScreenShareKit/ScreenShareKit.h>

@interface ScreenShareToolbarView (Animation)

- (void)moveSelectionShadowViewTo:(UIButton *)sender;
- (void)showColorPickerView;
- (void)dismissColorPickerView;

@end
