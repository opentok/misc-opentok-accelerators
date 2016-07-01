//
//  AnnotationView.h
//  
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotationPath.h"
#import "OTAnnotatable.h"

@interface OTAnnotationView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setCurrentAnnotatable:(id<OTAnnotatable>)annotatable;

- (void)addAnnotatable:(id<OTAnnotatable>)annotatable;

- (void)undoAnnotatable;

- (void)removeAllAnnotatables;

@end