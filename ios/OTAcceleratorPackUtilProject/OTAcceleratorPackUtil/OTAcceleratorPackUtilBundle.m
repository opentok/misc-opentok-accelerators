//
//  OTAnnotationKitBundle.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAcceleratorPackUtilBundle.h"

@implementation OTAcceleratorPackUtilBundle

+ (NSBundle *)acceleratorPackUtilBundle {
    
    NSURL *acceleratorPackUtilBundleURL = [[NSBundle mainBundle] URLForResource:@"OTAcceleratorPackUtilBundle" withExtension:@"bundle"];
    if (acceleratorPackUtilBundleURL){
        NSBundle *annotationBundle = [NSBundle bundleWithURL:acceleratorPackUtilBundleURL];
        if (!annotationBundle.isLoaded) {
            [annotationBundle load];
        }
        return annotationBundle;
    }
    
    return  nil;
}

@end
