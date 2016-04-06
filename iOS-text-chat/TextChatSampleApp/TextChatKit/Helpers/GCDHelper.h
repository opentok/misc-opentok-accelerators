//
//  GCDHelper.h
//  TextChatSampleApp
//
//  Created by Xi Huang on 4/5/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDHelper : NSObject

+ (void)executeDelayedWithBlock:(void (^)(void))block;

@end
