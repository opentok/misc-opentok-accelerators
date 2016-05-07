#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "TextChatComponent.h"


SPEC_BEGIN(TextChatComponentTests)

__block TextChatComponent *tcc;

beforeAll(^(){
    [TextChatView setOpenTokApiKey:@"testTextChatComponent"
                                 sessionId:@"testTextChatComponent"
                                     token:@"testTextChatComponent"];
    tcc = [[TextChatComponent alloc] init];
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
        [[theValue([tcc maximumTextMessageLength]) should] equal:theValue(NSUIntegerMax)];
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
    
    it(@"Alias is a long string", ^{
        NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        
        NSMutableString *randomString = [NSMutableString stringWithCapacity: 100*1024*1024];
        
        for (int i=0; i<100*1024*1024; i++) {
            [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
        }
        
        [tcc setAlias:randomString];
        [[[tcc alias] should] equal:randomString];
    });
    
});

describe(@"sendMessage", ^(){

    [tcc connect];
    
    it(@"Message is null", ^{
        [tcc sendMessage:nil];
        //should
    });
    
    it(@"Message is empty", ^{
        [tcc sendMessage:@""];
        //should
    });
    
    it(@"Message is sent properly", ^{
        [tcc sendMessage:@"Good mmorning!"];
        //should
    });
    
    it(@"Message is a long string", ^{
        NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        
        NSMutableString *randomString = [NSMutableString stringWithCapacity: 100*1024*1024];
        
        for (int i=0; i<100*1024*1024; i++) {
            [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
        }
        
        [tcc sendMessage:randomString];
        //[should
    });
    
});


describe(@"getTextChatFromIndexPath", ^(){

    it(@"Index is lower than zero", ^{
        //Set NSIndexPath row lower than zero
        //Should
    });
    
    it(@"Index is zero", ^{
        //Set NSIndexPath row to zero
        //Should
    });
    
    it(@"Index is greater than count", ^{
        //Set NSIndexPath row greater than count
        //Should
    });
    
    it(@"Index is set properly", ^{
        //Set NSIndexPath row greater than count
        //Should
    });
    
});


SPEC_END