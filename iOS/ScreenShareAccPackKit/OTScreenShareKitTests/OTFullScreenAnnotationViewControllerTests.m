//
//  OTFullScreenAnnotationViewControllerTests.m
//  OTScreenShareAccPackKit
//
//  Created by Xi Huang on 6/30/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "OTFullScreenAnnotationViewController.h"

SPEC_BEGIN(OTScreenSharerTests)

context(@"Initialization of OTFullScreenAnnotationViewController", ^(){
    
    describe(@"An instance of OTFullScreenAnnotationViewController", ^(){
        
        OTFullScreenAnnotationViewController *fullSreenAnnotationVC = [[OTFullScreenAnnotationViewController alloc]  init];
        [[fullSreenAnnotationVC shouldNot] beNil];
    });
});

SPEC_END
