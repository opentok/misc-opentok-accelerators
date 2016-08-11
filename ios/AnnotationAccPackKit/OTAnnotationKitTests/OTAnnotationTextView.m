//
//  OTAnnotationTextView.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "OTAnnotationTextView.h"

SPEC_BEGIN(OTAnnotationTextViewTest)

describe(@"Initialization of OTAnnotationTextView", ^(){
    
    context(@"An instance of OTAnnotationTextView", ^(){
        
        it(@"default initializer should not be nil", ^{
            [[[OTAnnotationTextView defaultWithTextColor:[UIColor yellowColor]] shouldNot] beNil];
        });
        
        it(@"should not be nil", ^{
            [[[[OTAnnotationTextView alloc] initWithText:@"" textColor:[UIColor greenColor] fontSize:0.0f] shouldNot] beNil];
        });
    });
    
    context(@"A new instance of OTAnnotationTextView", ^{
        
        it(@"should set the gesture variables after initialize", ^{
            
            OTAnnotationTextView *annotationsText = [[OTAnnotationTextView alloc] initWithText:@"" textColor:[UIColor greenColor] fontSize:0.0f];
            
            [[theValue(annotationsText.isResizable) should] equal:theValue(YES)];
            [[theValue(annotationsText.isDraggable) should] equal:theValue(YES)];
            [[theValue(annotationsText.isRotatable) should] equal:theValue(YES)];
        }); 
    });
});

SPEC_END
