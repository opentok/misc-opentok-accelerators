//
//  AnnotationManager.h
//
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <OTAnnotationKit/OTAnnotationPath.h>
#import <OTAnnotationKit/OTAnnotationTextView.h>

@interface OTAnnotationDataManager : NSObject

@property (readonly, nonatomic) NSArray<id<OTAnnotatable>> *annotatable;

@property (readonly, nonatomic) id<OTAnnotatable> peakOfAnnotatable;

- (instancetype)init;

- (void)addAnnotatable:(id<OTAnnotatable>)annotatable;

- (id<OTAnnotatable>)pop;

- (BOOL)containsAnnotatable:(id<OTAnnotatable>)annotatable;

- (void)undo;

- (void)undoAll;

@end