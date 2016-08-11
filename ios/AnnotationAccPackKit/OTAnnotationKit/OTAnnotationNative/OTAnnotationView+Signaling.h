//
//  OTAnnotationView+Signaling.h
//  OTAnnotationAccPackKit
//
//  Created by Xi Huang on 7/26/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <OTAnnotationKit/OTAnnotationKit.h>

@interface OTAnnotationView (Signaling)

- (void)signalAnnotatble:(id<OTAnnotatable>)annotatble
                   touch:(UITouch *)touch
           addtionalInfo:(NSDictionary *)info;

@end
