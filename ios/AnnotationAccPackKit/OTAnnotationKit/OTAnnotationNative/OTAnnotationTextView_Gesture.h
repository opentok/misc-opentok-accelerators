//
//  OTAnnotationTextView_Gesture.h
//  OTAnnotationAccPackKit
//
//  Created by Xi Huang on 8/1/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <OTAnnotationKit/OTAnnotationKit.h>

@interface OTAnnotationTextView ()

@property (nonatomic) CGPoint referenceCenter;
@property (nonatomic) CGPoint currentCenter;
@property (nonatomic) CGAffineTransform referenceTransform;
@property (nonatomic) CGAffineTransform currentTransform;
@property (nonatomic) UIPanGestureRecognizer *onViewPanRecognizer;
@property (nonatomic) UIPinchGestureRecognizer *onViewPinchRecognizer;
@property (nonatomic) UIRotationGestureRecognizer *onViewRotationRecognizer;

// external button
@property (nonatomic) CGPoint referencePoint;
@property (nonatomic) CGFloat referenceDistance;
@property (nonatomic) UIPanGestureRecognizer *onButtonZoomRecognizer;
@property (nonatomic) UIPanGestureRecognizer *onButtonRotateRecognizer;
@end
