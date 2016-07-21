//
//  OTTestingInfo.m
//  OTTextChatAccPackKit
//
//  Created by Xi Huang on 7/21/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTTestingInfo.h"

@implementation OTTestingInfo

+ (BOOL)isTesting {
    NSDictionary* environment = [[NSProcessInfo processInfo] environment];
    return [environment objectForKey:@"XCInjectBundleInto"] ? NO :  YES;
}

@end
