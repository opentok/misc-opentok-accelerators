#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "OTTextMessageManager.h"


SPEC_BEGIN(OTTextChatComponentTests)

__block OTTextMessageManager *tcc;

beforeAll(^(){
    [OTTextChatView setOpenTokApiKey:@"testTextChatComponent"
                                 sessionId:@"testTextChatComponent"
                                     token:@"testTextChatComponent"];
    tcc = [[OTTextMessageManager alloc] init];
});

describe(@"init", ^(){
    
    it(@"tcc should be init", ^{
        [[tcc shouldNot] beNil];
    });
    it(@"maximumTextMessageLength should be init", ^{
        [[theValue([tcc maximumTextMessageLength]) should] equal:theValue(8196)];
    });
    it(@"messages should be init", ^{
        [[[tcc messages] shouldNot] beNil];
    });
    
});

describe(@"setMaximumTextMessageLength", ^(){

    it(@"Maximum Text Length is Default", ^{
        [[theValue([tcc maximumTextMessageLength]) should] equal:theValue(8196)];
    });
    
    it(@"Maximum Text Length is set properly", ^{
        [tcc setMaximumTextMessageLength:8190];
        [[theValue([tcc maximumTextMessageLength]) should] equal:theValue(8190)];
    });
    
    it(@"Maximum Text Length is set lower than zero", ^{
        [tcc setMaximumTextMessageLength:-1];
        [[theValue([tcc maximumTextMessageLength]) should] equal:theValue(120)];
    });

    it(@"Maximum Text Length is set zero", ^{
        [tcc setMaximumTextMessageLength:0];
        [[theValue([tcc maximumTextMessageLength]) should] equal:theValue(0)];
    });

});

describe(@"setAlias", ^(){
    
    it(@"Alias is set properly", ^{
        [tcc setAlias:@"Bob"];
        [[[tcc alias] should] equal:@"Bob"];
    });
    
    it(@"Alias is set nulll", ^{
        [tcc setAlias:nil];
        [[[tcc alias] should] beNil];
    });
    
    it(@"Alias is empty string", ^{
        [tcc setAlias:@""];
        [[[tcc alias] should] equal:@""];
    });    
});


SPEC_END