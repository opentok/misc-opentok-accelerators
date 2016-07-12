//
//  APSession.h
//  APSessionDemo
//
//  Created by Xi Huang on 4/7/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <OpenTok/OpenTok.h>

@interface OTAcceleratorSession : OTSession

@property (readonly, nonatomic) NSString *apiKey;
@property (readonly, nonatomic) NSString *token;

+ (void)setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token;

+ (instancetype)getAcceleratorPackSession;

+ (NSError *)registerWithAccePack:(id)delegate;

+ (NSError *)deregisterWithAccePack:(id)delegate;

+ (BOOL)containsAccePack:(id)delegate;

+ (NSSet<id<OTSessionDelegate>> *)getRegisters;

@end
