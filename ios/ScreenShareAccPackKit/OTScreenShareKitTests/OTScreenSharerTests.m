//
//  OTScreenSharerTests.m
//  OTScreenShareAccPackKit
//
//  Created by Xi Huang on 6/30/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
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
