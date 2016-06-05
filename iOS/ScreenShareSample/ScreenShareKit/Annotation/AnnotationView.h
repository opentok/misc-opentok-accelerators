//
//  AnnotationView.h
//  ScreenShareSample
//
//  Created by Xi Huang on 5/18/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <ScreenShareKit/AnnotationPath.h>
#import <ScreenShareKit/Annotatable.h>

@interface AnnotationView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setCurrentAnnotatable:(id<Annotatable>)annotatable;

- (void)addAnnotatable:(id<Annotatable>)annotatable;

- (void)undoAnnotatable;

@end