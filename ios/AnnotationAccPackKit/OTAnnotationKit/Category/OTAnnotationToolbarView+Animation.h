//
//  OTAnnotationToolbarView+Animation.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <OTAnnotationKit/OTAnnotationKit.h>

@interface OTAnnotationToolbarView (Animation)

- (void)moveSelectionShadowViewTo:(UIButton *)sender;
- (void)showColorPickerView;
- (void)dismissColorPickerView;

@end
