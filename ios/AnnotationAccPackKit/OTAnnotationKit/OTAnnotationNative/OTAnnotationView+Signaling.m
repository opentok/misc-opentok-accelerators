//
//  OTAnnotationView+Signaling.m
//  OTAnnotationAccPackKit
//
//  Created by Xi Huang on 7/26/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotationView+Signaling.h"
#import <OTAcceleratorPackUtil/OTAcceleratorPackUtil.h>

#import "JSON.h"

@implementation OTAnnotationView (Signaling)

#pragma mark - signling
- (void)signalAnnotatble:(id<OTAnnotatable>)annotatble
                   touch:(UITouch *)touch
           addtionalInfo:(NSDictionary *)info{
    
    if ([annotatble isKindOfClass:[OTAnnotationPath class]]) {
        
        CGPoint touchPoint = [touch locationInView:touch.view];
        
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithDictionary:info];
        paramDict[@"fromX"] = @(touchPoint.x);
        paramDict[@"fromY"] = @(touchPoint.y);
        paramDict[@"toX"] = @(touchPoint.x + 1);
        paramDict[@"toY"] = @(touchPoint.y + 1);
        
        NSString *jsonString = [JSON stringify:@[paramDict]];
        NSError *error;
        [[OTAcceleratorSession getAcceleratorPackSession] signalWithType:@"testing" string:jsonString connection:nil error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    }
}

@end
