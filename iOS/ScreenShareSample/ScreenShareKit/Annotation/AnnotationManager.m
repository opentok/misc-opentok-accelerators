//
//  AnnotationManager.m
//  ScreenShareSample
//
//  Created by Xi Huang on 5/18/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "AnnotationManager.h"

@interface AnnotationManager()
@property (nonatomic) NSMutableArray<id<Annotatable>> *mutableAnnotatable;
@end

@implementation AnnotationManager

- (NSArray <AnnotationPath *> *)annotatable {
    return [_mutableAnnotatable copy];
}

- (instancetype)init {
    if (self = [super init]) {
        _mutableAnnotatable = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addAnnotatable:(id<Annotatable>)annotatable {
    if (!annotatable || ![annotatable conformsToProtocol:@protocol(Annotatable)]) return;
    [self.mutableAnnotatable addObject:annotatable];
}

- (id<Annotatable>)pop {
    if (self.mutableAnnotatable.count == 0) return nil;
    id<Annotatable> lastObject = [self.mutableAnnotatable lastObject];
    [self.mutableAnnotatable removeLastObject];
    return lastObject;
}

- (id<Annotatable>)peakOfPaths {
    if (self.mutableAnnotatable.count == 0) return nil;
    return [self.mutableAnnotatable lastObject];
}

- (BOOL)containsAnnotatable:(id<Annotatable>)annotatable {
    if (!annotatable || ![annotatable conformsToProtocol:@protocol(Annotatable)]) return NO;
    return [self.mutableAnnotatable containsObject:annotatable];
}

@end

