//
//  ScreenShareTextView.m
//  ScreenShareSample
//
//  Created by Xi Huang on 4/27/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "AnnotationTextView.h"

@interface AnnotationTextView() <UITextViewDelegate>
@property (nonatomic) CGPoint referenceCenter;
@property (nonatomic) CGAffineTransform referenceRotateTransform;
@property (nonatomic) CGAffineTransform currentRotateTransform;
@property (nonatomic) UIPinchGestureRecognizer *activePinchRecognizer;
@property (nonatomic) UIRotationGestureRecognizer *activeRotationRecognizer;
@property (nonatomic) CAShapeLayer *dotborder;


@property (nonatomic) UIButton *rotateButton;
@property (nonatomic) UIButton *pinchButton;
@end

@implementation AnnotationTextView

+ (instancetype)defaultWithTextColor:(UIColor *)textColor {
    return [[AnnotationTextView alloc] initWithText:nil textColor:textColor fontSize:0.0f];
}

- (instancetype)initWithText:(NSString *)text
                   textColor:(UIColor *)textColor
                    fontSize:(CGFloat)fontSize {
    
    if (self = [super init]) {
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        self.frame = CGRectMake(0, 100, CGRectGetWidth(screenBounds), 0);
        [self setTextAlignment:NSTextAlignmentCenter];
        [self setTextContainerInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        // text content
        if (!text) {
            [self setText:@"Content"];
        }
        else {
            [self setText:text];
        }
        
        if (fontSize == 0.0f) {
            [self setFont:[UIFont systemFontOfSize:32.0f]];
        }
        else {
            [self setFont:[UIFont systemFontOfSize:fontSize]];
        }
        [self resizeTextView:self];
        
        // attributes
        [self setBackgroundColor:[UIColor clearColor]];
        [self setDelegate:self];
        [self setTextColor:textColor];
        [self setScrollEnabled:NO];
        [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(handlePanGesture:)]];
        
        _activePinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchOrRotateGesture:)];
        [self addGestureRecognizer:_activePinchRecognizer];
        
        _activeRotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchOrRotateGesture:)];
        [self addGestureRecognizer:_activeRotationRecognizer];
        _referenceRotateTransform = CGAffineTransformIdentity;
        _currentRotateTransform = CGAffineTransformIdentity;
        
        // dash border
        _dotborder = [CAShapeLayer layer];
        _dotborder.strokeColor = [UIColor whiteColor].CGColor;
        _dotborder.fillColor = nil;
        _dotborder.lineWidth = 3.0f;
        _dotborder.lineDashPattern = @[@4, @4];
        [self.layer addSublayer:_dotborder];
        _dotborder.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        _dotborder.frame = self.bounds;
    }
    return self;
}

- (void)setFont:(UIFont *)font {
    super.font = font;
    [self resizeTextView:self];
}

- (void)commit {
    self.dotborder.strokeColor = [UIColor clearColor].CGColor;
    [self setUserInteractionEnabled:NO];
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
            CGPoint panTranslation = [(UIPanGestureRecognizer *)recognizer translationInView:self.superview];
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
            self.currentRotateTransform = self.referenceRotateTransform;
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            
            if (recognizer == self.activeRotationRecognizer) {
                
                self.currentRotateTransform = CGAffineTransformRotate(self.referenceRotateTransform, self.activeRotationRecognizer.rotation);
            }
            
            if (recognizer == self.activePinchRecognizer) {
                
                self.currentRotateTransform = CGAffineTransformScale(self.referenceRotateTransform, self.activePinchRecognizer.scale, self.activePinchRecognizer.scale);
            }
            self.transform = self.currentRotateTransform;
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            self.referenceRotateTransform = self.currentRotateTransform;
            break;
        }
            
        default:
            break;
    }
}

- (void)resizeTextView:(UITextView *)textView {
    CGFloat fixedWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fixedWidth, newSize.height);
    textView.frame = newFrame;
    
    self.dotborder.path = [UIBezierPath bezierPathWithRect:textView.bounds].CGPath;
    self.dotborder.frame = textView.bounds;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    [self resizeTextView:textView];
}

@end
