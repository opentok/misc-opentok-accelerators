//
//  ScreenShareViewManager.m
//  ScreenShareSample
//
//  Created by Xi Huang on 4/26/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "ScreenShareViewManager.h"

@interface ScreenShareViewManager()
@property (nonatomic) NSMutableArray<ScreenSharePath *> *mutablePaths;
@end

@implementation ScreenShareViewManager

- (NSArray <ScreenSharePath *> *)paths {
    return [_mutablePaths copy];
}

+ (instancetype)sharedManager {
    
    static ScreenShareViewManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedManager = [[ScreenShareViewManager alloc] init];
        sharedManager.mutablePaths = [[NSMutableArray alloc] init];
    });
    return sharedManager;
}

+ (void)addPath:(ScreenSharePath *)path {
    if (!path) return;
    [[ScreenShareViewManager sharedManager].mutablePaths addObject:path];
}

+ (ScreenSharePath *)pop {
    ScreenShareViewManager *sharedManager = [ScreenShareViewManager sharedManager];
    if (sharedManager.mutablePaths.count == 0) return nil;
    ScreenSharePath *lastObject = [sharedManager.mutablePaths lastObject];
    [sharedManager.mutablePaths removeLastObject];
    return lastObject;
}

+ (ScreenSharePath *)peakOfPaths {
    if ([ScreenShareViewManager sharedManager].mutablePaths.count == 0) return nil;
    return [[ScreenShareViewManager sharedManager].mutablePaths lastObject];
}

+ (BOOL)containsPath:(ScreenSharePath *)path {
    if (!path) return NO;
    return [[ScreenShareViewManager sharedManager].mutablePaths containsObject:path];
}

@end
