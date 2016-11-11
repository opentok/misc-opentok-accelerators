//
//  AppDelegate.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OTAcceleratorPackUtil/OTAcceleratorPackUtil.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (OTAcceleratorSession *)getSharedAcceleratorSession;

@end

