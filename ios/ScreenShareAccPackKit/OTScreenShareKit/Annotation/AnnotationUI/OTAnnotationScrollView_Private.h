//
//  OTAnnotationScrollView_Private.h
//  ScreenShareSample
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTAnnotationView.h"

@interface OTAnnotationScrollView ()

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *scrollContentView;
@property (nonatomic) OTAnnotationView *annotationView;

@end
