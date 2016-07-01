//
//  OTAnnotationDataManager.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotationPath.h"
#import "OTAnnotationTextView.h"

@interface OTAnnotationDataManager : NSObject

@property (readonly, nonatomic) NSArray<id<OTAnnotatable>> *annotatable;

- (instancetype)init;

- (void)addAnnotatable:(id<OTAnnotatable>)annotatable;

- (id<OTAnnotatable>)pop;

- (id<OTAnnotatable>)peakOfAnnotatable;

- (BOOL)containsAnnotatable:(id<OTAnnotatable>)annotatable;

- (void)undo;

- (void)undoAll;

@end