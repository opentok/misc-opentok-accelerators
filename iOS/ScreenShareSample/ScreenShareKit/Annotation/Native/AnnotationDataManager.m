//
//  AnnotationManager.m
//  ScreenShareSample
//
//  Created by Xi Huang on 5/18/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "AnnotationDataManager.h"

@interface AnnotationDataManager()
@property (nonatomic) NSMutableArray<id<Annotatable>> *mutableAnnotatable;
@end

@implementation AnnotationDataManager

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
    [self annotatable];
}

- (id<Annotatable>)pop {
    if (self.annotatable.count == 0) return nil;
    id<Annotatable> lastObject = [self.mutableAnnotatable lastObject];
    [self.mutableAnnotatable removeLastObject];
    [self annotatable];
    return lastObject;
}

- (id<Annotatable>)peakOfAnnotatable {
    if (self.annotatable.count == 0) return nil;
    return [self.annotatable lastObject];
}

- (BOOL)containsAnnotatable:(id<Annotatable>)annotatable {
    if (!annotatable || ![annotatable conformsToProtocol:@protocol(Annotatable)]) return NO;
    return [self.annotatable containsObject:annotatable];
}

- (void)undo {
    [self pop];
}

- (void)undoAll {
    [self.mutableAnnotatable removeAllObjects];
    [self annotatable];
}

@end
