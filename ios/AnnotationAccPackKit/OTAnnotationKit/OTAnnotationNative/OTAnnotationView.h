//
//  AnnotationView.h
//
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <OTAnnotationKit/OTAnnotatable.h>
#import <OTAnnotationKit/OTAnnotationDataManager.h>
#import <OTAnnotationKit/OTAnnotationPath.h>

@interface OTAnnotationView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

- (void)addAnnotatable:(id<OTAnnotatable>)annotatable;

- (void)undoAnnotatable;

- (void)removeAllAnnotatables;

@property (nonatomic) id<OTAnnotatable> currentAnnotatable;

@property (readonly, nonatomic) OTAnnotationDataManager *annotationDataManager;

- (void)commitCurrentAnnotatable;

@end