//
//  AnnotationManager.h
//  ScreenShareSample
//
//  Created by Xi Huang on 5/18/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "AnnotationPath.h"

@interface AnnotationManager : NSObject

@property (readonly, nonatomic) NSArray<id<Annotatable>> *annotatable;

- (instancetype)init;

- (void)addAnnotatable:(id<Annotatable>)annotatable;

- (id<Annotatable>)pop;

- (id<Annotatable>)peakOfPaths;

- (BOOL)containsAnnotatable:(id<Annotatable>)annotatable;

@end