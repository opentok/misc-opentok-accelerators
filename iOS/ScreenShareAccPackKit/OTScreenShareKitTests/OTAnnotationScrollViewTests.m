//
//  OTAnnotationScrollViewTests.m
//  OTScreenShareAccPackKit
//
//  Created by Xi Huang on 6/30/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "OTAnnotationScrollView.h"

SPEC_BEGIN(OTScreenSharerTests)

context(@"Initialization of OTAnnotationScrollView", ^(){
    
    describe(@"An instance of OTAnnotationScrollView", ^(){
        
        OTAnnotationScrollView *annotationView = [[OTAnnotationScrollView init] alloc];
        [[annotationView shouldNot] beNil];
    });
});

SPEC_END
