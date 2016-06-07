//
//  APAppDelegate.m
//  OTAcceleratorPackUtil
//
//  Created by Lucas Huang on 04/27/2016.
//  Copyright (c) 2016 Lucas Huang. All rights reserved.
//

#import "APAppDelegate.h"
#import <OTAcceleratorPackUtil/OTAcceleratorPackUtil.h>

@implementation APAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [OTAcceleratorSession setOpenTokApiKey:@"100"
                                 sessionId:@"1_MX4xMDB-fjE0NjUzMzU4OTkyMzZ-OHFvbWt1c29INVdGUjRuYUJDMG1idEpnfn4"
                                     token:@"T1==cGFydG5lcl9pZD0xMDAmc2RrX3ZlcnNpb249dGJwaHAtdjAuOTEuMjAxMS0wNy0wNSZzaWc9MTIxMzU3N2RhMjQ3MDgzMzQwOGUzOTAwOTQ5OTBkMzEzN2UwOGVkYzpzZXNzaW9uX2lkPTFfTVg0eE1EQi1makUwTmpVek16VTRPVGt5TXpaLU9IRnZiV3QxYzI5SU5WZEdValJ1WVVKRE1HMWlkRXBuZm40JmNyZWF0ZV90aW1lPTE0NjUzMzM1NDUmcm9sZT1tb2RlcmF0b3Imbm9uY2U9MTQ2NTMzMzU0NS4yNjE2MTg0MTYzNTM2NyZleHBpcmVfdGltZT0xNDY3OTI1NTQ1"];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
