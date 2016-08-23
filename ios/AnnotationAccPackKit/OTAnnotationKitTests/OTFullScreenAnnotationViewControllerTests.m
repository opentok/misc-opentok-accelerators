//
//  OTFullScreenAnnotationViewControllerTests.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "OTFullScreenAnnotationViewController.h"

SPEC_BEGIN(OTFullScreenAnnotationViewControllerTests)

context(@"Initialization of OTFullScreenAnnotationViewController", ^(){
    
    describe(@"An instance of OTFullScreenAnnotationViewController", ^(){
        
        OTFullScreenAnnotationViewController *fullSreenAnnotationVC = [[OTFullScreenAnnotationViewController alloc]  init];
        [[fullSreenAnnotationVC shouldNot] beNil];
    });
});

SPEC_END
