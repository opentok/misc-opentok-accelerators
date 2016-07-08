//
//  OTScreenSharerTests.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "OTScreenSharer.h"

SPEC_BEGIN(OTScreenSharerTests)

context(@"Initialization of OTScreenSharer", ^(){
    
    describe(@"An instance of OTScreenSharer", ^(){
        
        OTScreenSharer *screenSharer = [OTScreenSharer screenSharer];
        [[screenSharer shouldNot] beNil];
    });
});

SPEC_END
