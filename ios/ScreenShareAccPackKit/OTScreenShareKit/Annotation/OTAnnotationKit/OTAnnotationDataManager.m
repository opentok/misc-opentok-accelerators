//
//  AnnotationManager.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotationDataManager.h"

@interface OTAnnotationDataManager()
@property (nonatomic) NSMutableArray<id<OTAnnotatable>> *mutableAnnotatable;
@end

@implementation OTAnnotationDataManager

- (NSArray <OTAnnotationPath *> *)annotatable {
    return [_mutableAnnotatable copy];
}

- (instancetype)init {
    if (self = [super init]) {
        _mutableAnnotatable = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addAnnotatable:(id<OTAnnotatable>)annotatable {
    if (!annotatable || ![annotatable conformsToProtocol:@protocol(OTAnnotatable)]) return;
    [self.mutableAnnotatable addObject:annotatable];
    [self annotatable];
}

- (id<OTAnnotatable>)pop {
    if (self.annotatable.count == 0) return nil;
    id<OTAnnotatable> lastObject = [self.mutableAnnotatable lastObject];
    [self.mutableAnnotatable removeLastObject];
    [self annotatable];
    return lastObject;
}

- (id<OTAnnotatable>)peakOfAnnotatable {
    if (self.annotatable.count == 0) return nil;
    return [self.annotatable lastObject];
}

- (BOOL)containsAnnotatable:(id<OTAnnotatable>)annotatable {
    if (!annotatable || ![annotatable conformsToProtocol:@protocol(OTAnnotatable)]) return NO;
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
