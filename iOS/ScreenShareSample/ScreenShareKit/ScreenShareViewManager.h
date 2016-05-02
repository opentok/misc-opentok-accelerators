//
//  ScreenShareViewManager.h
//  ScreenShareSample
//
//  Created by Xi Huang on 4/26/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "ScreenSharePath.h"

@interface ScreenShareViewManager : NSObject
@property (nonatomic, readonly) NSArray<ScreenSharePath *> *paths;
+ (instancetype)sharedManager;
+ (void)addPath:(ScreenSharePath *)path;
+ (ScreenSharePath *)pop;
+ (ScreenSharePath *)peakOfPaths;
+ (BOOL)containsPath:(ScreenSharePath *)path;
@end
