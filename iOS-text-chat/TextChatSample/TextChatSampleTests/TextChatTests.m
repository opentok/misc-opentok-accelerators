#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import <TextChatkit/TextChatKit.h>
#import "TextChat_Private.h"


SPEC_BEGIN(TextChatTest)

__block TextChat *tc;

beforeAll(^(){
    [OneToOneCommunicator setOpenTokApiKey:@"testTextChat"
                                 sessionId:@"testTextChat"
                                     token:@"testTextChat"];
    
    tc = [[TextChat alloc] init];
});

describe(@"initWithMessage", ^(){
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: 100*1024*1024];
    
    for (int i=0; i<100*1024*1024; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    it(@"Message is null", ^{
        tc = [tc initWithMessage:nil alias:@"Bob" senderId:@"1234"];
        [[tc shouldNot] beNil];
        [[[tc dateTime] shouldNot] beNil];
        [[[tc text] should] beNil];
        [[[tc alias] should] equal:@"Bob"];
        [[[tc senderId] should] equal:@"1234"];
    });
    it(@"Message is empty", ^{
        tc = [tc initWithMessage:@"" alias:@"Bob" senderId:@"1234"];
        [[tc shouldNot] beNil];
        [[[tc dateTime] shouldNot] beNil];
        [[[tc text] should] equal:@""];
        [[[tc alias] should] equal:@"Bob"];
        [[[tc senderId] should] equal:@"1234"];
    });
    it(@"Message is long string", ^{
        tc = [tc initWithMessage:randomString alias:@"Bob" senderId:@"1234"];
        [[tc shouldNot] beNil];
        [[[tc dateTime] shouldNot] beNil];
        [[[tc text] should] equal:randomString];
        [[[tc alias] should] equal:@"Bob"];
        [[[tc senderId] should] equal:@"1234"];
    });
    it(@"Alias is null", ^{
        tc = [tc initWithMessage:@"Good morning!" alias:nil senderId:@"1234"];
        [[tc shouldNot] beNil];
        [[[tc dateTime] shouldNot] beNil];
        [[[tc alias] should] equal:@"Tokboxer"];
        [[[tc text] should] equal:@"Good morning!"];
        [[[tc senderId] should] equal:@"1234"];
    });
    it(@"Alias is empty", ^{
        tc = [tc initWithMessage:@"Good morning!" alias:@"" senderId:@"1234"];
        [[tc shouldNot] beNil];
        [[[tc dateTime] shouldNot] beNil];
        [[[tc alias] should] equal:@"Tokboxer"];
        [[[tc text] should] equal:@"Good morning!"];
        [[[tc senderId] should] equal:@"1234"];
    });
    it(@"Alias is long string", ^{
        tc = [tc initWithMessage:@"Good morning!" alias:randomString senderId:@"1234"];
        [[tc shouldNot] beNil];
        [[[tc dateTime] shouldNot] beNil];
        [[[tc alias] should] equal:randomString];
        [[[tc text] should] equal:@"Good morning!"];
        [[[tc senderId] should] equal:@"1234"];
    });
    it(@"SenderID is null", ^{
        tc = [tc initWithMessage:@"Good morning!" alias:@"Bob" senderId:nil];
        [[tc shouldNot] beNil];
        [[[tc dateTime] shouldNot] beNil];
        [[[tc senderId] shouldNot] equal:@""];
        [[[tc text] should] equal:@"Good morning!"];
        [[[tc alias] should] equal:@"Bob"];
    });
    it(@"SenderID is empty", ^{
        tc = [tc initWithMessage:@"Good morning!" alias:@"Bob" senderId:@""];
        [[tc shouldNot] beNil];
        [[[tc dateTime] shouldNot] beNil];
        [[[tc senderId] shouldNot] equal:@""];
        [[[tc text] should] equal:@"Good morning!"];
        [[[tc alias] should] equal:@"Bob"];
    });
    it(@"SenderID is long string", ^{
        tc = [tc initWithMessage:@"Good morning!" alias:@"Bob" senderId:randomString];
        [[tc shouldNot] beNil];
        [[[tc dateTime] shouldNot] beNil];
        [[[tc senderId] should] equal:randomString];
        [[[tc text] should] equal:@"Good morning!"];
        [[[tc alias] should] equal:@"Bob"];
    });
    it(@"Message is set properly", ^{
        tc = [tc initWithMessage:@"Good morning!" alias:@"Bob" senderId:@"1234"];
        [[tc shouldNot] beNil];
        [[[tc dateTime] shouldNot] beNil];
        [[[tc text] should] equal:@"Good morning!"];
        [[[tc alias] should] equal:@"Bob"];
        [[[tc senderId] should] equal:@"1234"];
    });
    
});


describe(@"initWithJSONString", ^(){
    
    it(@"JSON is null", ^{
        tc = [tc initWithJSONString:nil];
    });
    it(@"JSON is empty", ^{
        tc = [tc initWithJSONString:@""];
    });
    it(@"JSON is not valid", ^{
        tc = [tc initWithJSONString:@""];
    });
    it(@"Message is set properly", ^{
        tc = [tc initWithJSONString:@""];
        [[[tc getTextChatSignalJSONString] should] equal:@""];
    });
    
});


SPEC_END