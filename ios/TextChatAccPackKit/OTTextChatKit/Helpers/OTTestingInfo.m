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
    return [[NSProcessInfo processInfo].processName isEqualToString:@"OTTextChatKitTests"] ? YES : NO;
}

@end
