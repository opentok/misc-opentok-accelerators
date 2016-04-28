//
//  ScreenShareTextView.m
//  ScreenShareSample
//
//  Created by Xi Huang on 4/27/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "ScreenShareTextField.h"

@interface ScreenShareTextField()
@property (nonatomic) CGPoint referenceCenter;
@end

@implementation ScreenShareTextField

+ (instancetype)textField {
    ScreenShareTextField *textField = [[ScreenShareTextField alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [textField setTextAlignment:NSTextAlignmentCenter];
    [textField setText:@"Testing"];
    textField.center = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds), CGRectGetMidY([UIScreen mainScreen].bounds));

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:textField
                                                                          action:@selector(handlePanGesture:)];
    [textField addGestureRecognizer:pan];
    return textField;
}

- (void)handlePanGesture:(UIGestureRecognizer *)recognizer {
    
    if (![recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return;
    }
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.referenceCenter = self.center;
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint panTranslation = [(UIPanGestureRecognizer *)recognizer translationInView:self];
            self.center = CGPointMake(self.referenceCenter.x + panTranslation.x,
                                                self.referenceCenter.y + panTranslation.y);;
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            self.referenceCenter = self.center;
            break;
        }
            
        default:
            break;
    }
}

@end
