//
//  ASTestCase.m
//  AcceleratorSession
//
//  Created by Xi Huang on 4/24/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import <AcceleratorSession/AcceleratorPackSession.h>

SPEC_BEGIN(TestAcceleratorSession)

describe(@"testAcceleratorPackSessionInit", ^(){
    
    [AcceleratorPackSession setOpenTokApiKey:@"testOneToOneCommunicatorInitApiKey"
                                   sessionId:@"testOneToOneCommunicatorInitSessionId"
                                       token:@"testOneToOneCommunicatorInitToken"];

    [[[AcceleratorPackSession getAcceleratorPackSession] shouldNot] beNil];
    [[theValue([AcceleratorPackSession getRegisters].count) should] equal:theValue(0)];
});


describe(@"testAcceleratorPackSessionRegistration", ^(){
    
    KWMock *mock = [KWMock mockForProtocol:@protocol(OTSessionDelegate)];
    [AcceleratorPackSession registerWithAccePack:mock];
    [[theValue([AcceleratorPackSession containsAccePack:mock]) should] equal:theValue(YES)];
    [[theValue([AcceleratorPackSession getRegisters].count) should] equal:theValue(1)];
});

describe(@"testAcceleratorPackSessionDeregistration", ^(){
    
    KWMock *mock = [KWMock mockForProtocol:@protocol(OTSessionDelegate)];
    [AcceleratorPackSession registerWithAccePack:mock];
    [AcceleratorPackSession deregisterWithAccePack:mock];
    [[theValue([AcceleratorPackSession containsAccePack:mock]) should] equal:theValue(NO)];
    [[theValue([AcceleratorPackSession getRegisters].count) should] equal:theValue(0)];
});

SPEC_END