//
//  OTKLogger.h
//  OTKAnalytics
//
//  Created by Xi Huang on 6/27/16.
//  Copyright © 2016 tokbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface OTKLogger : NSObject

+ (void)analyticsWithClientVersion:(NSString *)clientVersion
                            source: (NSString *)source
                       componentId:(NSString *)componentId
                              guid: (NSString *)guid;

+ (void)setSessionId:(NSString *)sessionId
        connectionId:(NSString *)connectionId
           partnerId:(NSNumber *)partnerId;

+ (void)logEventAction:(NSString *)action
             variation:(NSString *)variation
            completion:(nullable void (^)(NSError *))completion;

@end
NS_ASSUME_NONNULL_END
