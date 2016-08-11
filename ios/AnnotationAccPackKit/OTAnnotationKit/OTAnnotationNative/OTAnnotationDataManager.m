//
//  AnnotationManager.m
//
//  Copyright © 2016 Tokbox. All rights reserved.
//

#import "OTAnnotationDataManager.h"

@interface OTAnnotationDataManager()
@property (nonatomic) NSMutableArray<id<OTAnnotatable>> *mutableAnnotatable;
@property (nonatomic) id<OTAnnotatable> peakOfAnnotatable;
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
    [_mutableAnnotatable addObject:annotatable];
    _peakOfAnnotatable = annotatable;
    [self annotatable];
}

- (id<OTAnnotatable>)pop {
    if (self.annotatable.count == 0) return nil;
    id<OTAnnotatable> lastObject = [_mutableAnnotatable lastObject];
    [_mutableAnnotatable removeLastObject];
    _peakOfAnnotatable = [_mutableAnnotatable lastObject];
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

- (void)popAll {
    [_mutableAnnotatable removeAllObjects];
    [self annotatable];
}

@end
