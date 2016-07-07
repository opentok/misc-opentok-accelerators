//
//  OTTextChatKitBundle.m
//  OTTextChatAccPackKit
//
//  Created by Xi Huang on 7/7/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTTextChatKitBundle.h"
#import "OTTextChatView.h"

@implementation OTTextChatKitBundle

+ (NSBundle *)textChatKitBundle {
    
    NSURL *textChatKitBundleURL = [[NSBundle mainBundle] URLForResource:@"OTTextChatKitBundle" withExtension:@"bundle"];
    if (textChatKitBundleURL){
        NSBundle *textChatViewBundle = [NSBundle bundleWithURL:textChatKitBundleURL];
        if (!textChatViewBundle.isLoaded) {
            [textChatViewBundle load];
        }
        return textChatViewBundle;
    }
    
    textChatKitBundleURL = [[NSBundle bundleForClass:[OTTextChatView class]] URLForResource:@"OTTextChatKitBundle" withExtension:@"bundle"];
    if (textChatKitBundleURL) {
        NSBundle *textChatViewBundle = [NSBundle bundleWithURL:textChatKitBundleURL];
        if (!textChatViewBundle.isLoaded) {
            [textChatViewBundle load];
        }
        return textChatViewBundle;
    }
    
    return  nil;
}

@end
