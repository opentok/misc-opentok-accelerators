//
//  OTAnnotationViewTests.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "OTAnnotationView.h"

SPEC_BEGIN(OTAnnotationViewTests)

describe(@"Initialization of OTAnnotationView", ^(){
    
    OTAnnotationView *annotationView = [[OTAnnotationView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    context(@"An instance of OTAnnotationView", ^(){
        
        it(@"should not be nil", ^{
            [[annotationView shouldNot] beNil];
        });
        
        it(@"annotationDataManager should not be nil", ^{
            [[annotationView.annotationDataManager shouldNot] beNil];
        });
    });
});

describe(@"Methods of OTAnnotationView", ^{
    
    OTAnnotationView *annotationView = [[OTAnnotationView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    context(@"Method", ^{
        
        it(@"captureScreen result image should not be nil", ^{
            [[[annotationView captureScreen] shouldNot] beNil];
        });
    });
});

SPEC_END
