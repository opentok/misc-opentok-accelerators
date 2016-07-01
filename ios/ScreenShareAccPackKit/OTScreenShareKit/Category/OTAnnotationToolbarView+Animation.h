//
//  OTAnnotationToolbarView+Animation.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <OTScreenShareKit/OTScreenShareKit.h>

@interface OTAnnotationToolbarView (Animation)

- (void)moveSelectionShadowViewTo:(UIButton *)sender;
- (void)showColorPickerView;
- (void)dismissColorPickerView;

@end
