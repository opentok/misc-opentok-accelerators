//
//  ScreenShareTextView.m
//  ScreenShareSample
//
//  Created by Xi Huang on 4/27/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "AnnotationTextField.h"

@interface AnnotationTextField() <UITextFieldDelegate>
@property (nonatomic) CGPoint referenceCenter;
@property (nonatomic) CGAffineTransform referenceRotateTransform;
@property (nonatomic) CGAffineTransform currentRotateTransform;
@property (nonatomic) UIPinchGestureRecognizer *activePinchRecognizer;
@property (nonatomic) UIRotationGestureRecognizer *activeRotationRecognizer;
@property (nonatomic) CGFloat scale;
@end

@implementation AnnotationTextField

+ (instancetype)textFieldWithTextColor:(UIColor *)textColor {
    AnnotationTextField *textField = [[AnnotationTextField alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    textField.delegate = textField;
    [textField setTextAlignment:NSTextAlignmentCenter];
    [textField setTextColor:textColor];
    [textField setText:@"Testing"];
    textField.center = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds), CGRectGetMidY([UIScreen mainScreen].bounds));

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:textField
                                                                          action:@selector(handlePanGesture:)];
    [textField addGestureRecognizer:pan];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:textField action:@selector(handlePinchOrRotateGesture:)];
    [textField addGestureRecognizer:pinch];
    textField.activePinchRecognizer = pinch;
    
    UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:textField action:@selector(handlePinchOrRotateGesture:)];
    [textField addGestureRecognizer:rotate];
    textField.activeRotationRecognizer = rotate;
    textField.scale = 1.f;
    textField.referenceRotateTransform = CGAffineTransformIdentity;
    textField.currentRotateTransform = CGAffineTransformIdentity;
    
    textField.layer.borderWidth = 2.0f;
    textField.layer.borderColor = [UIColor blackColor].CGColor;
    
    
    return textField;
}

//- (void)setScale:(CGFloat)scale
//{
//    if (_scale != scale) {
//        _scale = scale;
//        self.transform = CGAffineTransformIdentity;
//        CGPoint labelCenter = self.center;
//        CGRect scaledLabelFrame = CGRectMake(0.f,
//                                             0.f,
//                                             CGRectGetWidth(self.bounds) * _scale * 1.05f,
//                                             CGRectGetHeight(self.bounds) * _scale * 1.05f);
//        CGFloat currentFontSize = self.font.pointSize * _scale;
//        self.font = [self.font fontWithSize:currentFontSize];
//        self.frame = scaledLabelFrame;
//        self.center = labelCenter;
//        self.transform = self.currentRotateTransform;
//    }
//}

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
                                      self.referenceCenter.y + panTranslation.y);
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

- (void)handlePinchOrRotateGesture:(UIGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            if ([recognizer isKindOfClass:[UIRotationGestureRecognizer class]]) {
                self.currentRotateTransform = self.referenceRotateTransform;
                self.activeRotationRecognizer = (UIRotationGestureRecognizer *)recognizer;
            } else {
                self.activePinchRecognizer = (UIPinchGestureRecognizer *)recognizer;
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            
            CGAffineTransform currentTransform = self.referenceRotateTransform;
            
            if ([recognizer isKindOfClass:[UIRotationGestureRecognizer class]]) {
                self.currentRotateTransform = [self applyRecognizer:recognizer toTransform:self.referenceRotateTransform];
            }
            
            currentTransform = [self applyRecognizer:self.activePinchRecognizer toTransform:currentTransform];
            currentTransform = [self applyRecognizer:self.activeRotationRecognizer toTransform:currentTransform];
            
            self.transform = currentTransform;
            
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            if ([recognizer isKindOfClass:[UIRotationGestureRecognizer class]]) {
                
                self.referenceRotateTransform = [self applyRecognizer:recognizer toTransform:self.referenceRotateTransform];
                self.currentRotateTransform = self.referenceRotateTransform;
                self.activeRotationRecognizer = nil;
                
            } else if ([recognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
                
                self.scale *= [(UIPinchGestureRecognizer *)recognizer scale];
                self.activePinchRecognizer = nil;
            }
            
            break;
        }
            
        default:
            break;
    }
}

- (CGAffineTransform)applyRecognizer:(UIGestureRecognizer *)recognizer toTransform:(CGAffineTransform)transform
{
    if (!recognizer
        || !([recognizer isKindOfClass:[UIRotationGestureRecognizer class]]
             || [recognizer isKindOfClass:[UIPinchGestureRecognizer class]])) {
            return transform;
        }
    
    if ([recognizer isKindOfClass:[UIRotationGestureRecognizer class]]) {
        
        return CGAffineTransformRotate(transform, [(UIRotationGestureRecognizer *)recognizer rotation]);
    }
    
    CGFloat scale = [(UIPinchGestureRecognizer *)recognizer scale];
    return CGAffineTransformScale(transform, scale, scale);
}

@end
