//
//  OTScreenSharerTests.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "OTScreenSharer.h"
#import "OTScreenSharer_Private.h"

SPEC_BEGIN(OTScreenSharerTests)

__block OTScreenSharer *ss;

context(@"Initialization of OTScreenSharer", ^(){

    beforeAll(^(){
        ss = [OTScreenSharer sharedInstance];
    });
    
    describe(@"An instance of OTScreenSharer", ^(){
        
        it(@"should not be nil", ^(){
            [[ss shouldNot] beNil];
        });
        
        it(@"screensharing flag should be FALSE", ^(){
            [[theValue(ss.isScreenSharing) should] equal:theValue(NO)];
        });
        
        it(@"subscriberView should be NIL", ^(){
            [[ss.subscriberView should] beNil];
        });
        
        it(@"PublisherView should be NIL", ^(){
            [[ss.publisherView should] beNil];
        });
        
        it(@"flag subscribe to audio should be NO", ^(){
            [[theValue(ss.isSubscribeToAudio) should] equal:theValue(NO)];
        });
        
        it(@"flag subscribe to video should be NO", ^(){
            [[theValue(ss.isSubscribeToVideo) should] equal:theValue(NO)];
        });
        
        it(@"flag publish audio should be NO", ^(){
            [[theValue(ss.isPublishAudio) should] equal:theValue(NO)];
        });
        
        it(@"flag publish video should be NO", ^(){
            [[theValue(ss.isPublishVideo) should] equal:theValue(NO)];
        });
    });
    
    describe(@"Screen Share functionalities that don't require to connect to OpenTok", ^{
        
        describe(@"updateView", ^{
            
            it(@"should not allow change view while not screensharing", ^{
                [ss updateView:[[UIView alloc] init]];
                // should not allow change the view while not screensharing
                [[ss.screenCapture.view should] beNil];
            });
        });
        
    });

});


SPEC_END
