//
//  OTAnnotationEditTextViewControllerTests.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "OTAnnotationEditTextViewController.h"

SPEC_BEGIN(OTAnnotationEditTextViewControllerTests)

context(@"Initialization of OTAnnotationEditTextViewController", ^(){
    
    describe(@"An instance of OTAnnotationEditTextViewController", ^(){
        
        it(@"should not be nil", ^{
            [[[[OTAnnotationEditTextViewController alloc] init] shouldNot] beNil];
        });
        
        it(@"init with text should not be nil", ^{
            [[[[OTAnnotationEditTextViewController alloc] initWithText:@"" textColor:[UIColor blackColor] fontSize:0.0f] shouldNot] beNil];
        });
        
    });
    
    describe(@"OTAnnotationEditTextViewController Factory", ^{
        it(@"should be able to set default text color", ^{
            [[[OTAnnotationEditTextViewController defaultWithTextColor:[UIColor blackColor]] shouldNot] beNil];
        });
    });
});

SPEC_END