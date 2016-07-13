//
//  JSON.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "JSON.h"

@implementation JSON

+ (NSDictionary *)parseJSON:(NSString*)string {
    NSError *error;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    if (error) return nil;
    return dictionary;
}

+ (NSString *)stringify:(NSDictionary*)json {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization  dataWithJSONObject:json options:0 error:&error];
    if (error) return nil;
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
