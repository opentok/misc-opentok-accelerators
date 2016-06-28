//
//  AnnotationView.h
//  ScreenShareSample
//
//  Created by Xi Huang on 5/18/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <ScreenShareKit/OTAnnotationPath.h>
#import <ScreenShareKit/OTAnnotatable.h>

@interface OTAnnotationView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setCurrentAnnotatable:(id<OTAnnotatable>)annotatable;

- (void)addAnnotatable:(id<OTAnnotatable>)annotatable;

- (void)undoAnnotatable;

- (void)removeAllAnnotatables;

@end