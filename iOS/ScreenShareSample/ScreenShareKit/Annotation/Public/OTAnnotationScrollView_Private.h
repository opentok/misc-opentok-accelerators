//
//  OTAnnotationScrollView_Private.h
//  ScreenShareSample
//
//  Created by Xi Huang on 6/26/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTAnnotationView.h"

@interface OTAnnotationScrollView ()

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *scrollContentView;
@property (nonatomic) OTAnnotationView *annotationView;

@end
