//
//  OTAnnotationScrollViewTests.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "OTAnnotationScrollView.h"

SPEC_BEGIN(OTAnnotationScrollViewTests)

context(@"Initialization of OTAnnotationScrollView", ^(){
    
    describe(@"An instance of OTAnnotationScrollView", ^(){
        
        OTAnnotationScrollView *annotationView = [[OTAnnotationScrollView alloc] init];
        [[annotationView shouldNot] beNil];
    });
});

SPEC_END
