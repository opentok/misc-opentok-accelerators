//
//  AppDelegate.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <OTScreenShareKit/OTScreenShareKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [OTScreenSharer setOpenTokApiKey:@"45621172"
                           sessionId:@"1_MX40NTYyMTE3Mn5-MTQ2ODQwNzgxNjY4NX5CaFRLV2J5RDZUUXBZek1xTVVoZEtyQ25-fg"
                               token:@"T1==cGFydG5lcl9pZD00NTYyMTE3MiZzZGtfdmVyc2lvbj10YnBocC12MC45MS4yMDExLTA3LTA1JnNpZz03MDJjMDgwMjU0ZmNlMmMzNGVhYjEwOWZjMGUzZGQ2OGZkNWI3ZTI5OnNlc3Npb25faWQ9MV9NWDQwTlRZeU1URTNNbjUtTVRRMk9EUXdOemd4TmpZNE5YNUNhRlJMVjJKNVJEWlVVWEJaZWsxeFRWVm9aRXR5UTI1LWZnJmNyZWF0ZV90aW1lPTE0Njg0MDgyMzkmcm9sZT1tb2RlcmF0b3Imbm9uY2U9MTQ2ODQwODIzOS40Nzg2MzY2NDI5NjI5JmV4cGlyZV90aW1lPTE0NzEwMDAyMzk="];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
