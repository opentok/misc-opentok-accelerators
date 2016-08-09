//
//  CustomDateFormatter.h
//  OTTextChatAccPackKit
//
//  Created by Xi Huang on 8/8/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomDateFormatter : NSObject

+ (instancetype)sharedInstance;

+ (NSString *)convertToTimeFromDate:(NSDate *)date;

+ (NSString *)convertToTimestampFromDate:(NSDate *)date;

@end
