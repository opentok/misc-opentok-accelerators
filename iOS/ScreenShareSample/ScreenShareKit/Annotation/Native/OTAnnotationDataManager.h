//
//  AnnotationManager.h
//  ScreenShareSample
//
//  Created by Xi Huang on 5/18/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <ScreenShareKit/OTAnnotationPath.h>
#import <ScreenShareKit/OTAnnotationTextView.h>

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