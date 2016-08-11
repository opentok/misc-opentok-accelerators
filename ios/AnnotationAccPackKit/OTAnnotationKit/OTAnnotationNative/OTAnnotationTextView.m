//
//  ScreenShareTextView.m
//
//  Copyright © 2016 Tokbox. All rights reserved.
//

#import "OTAnnotationTextView.h"
#import <OTKAnalytics/OTKLogger.h>

#import "OTAnnotationTextView+Gesture.h"
#import "OTAnnotationTextView_Gesture.h"

#import "OTAnnotationKitBundle.h"
#import "Constants.h"

@interface OTAnnotationTextView() <UITextViewDelegate> {
    BOOL startTyping;
}
@property (nonatomic) UIButton *cancelButton;
@property (nonatomic) UIButton *rotateButton;
@property (nonatomic) UIButton *pinchButton;
@end

@implementation OTAnnotationTextView

NSString *const OTAnnotationTextViewDidFinishChangeNotification = @"OTAnnotationTextViewDidFinishChangeNotification";
NSString *const OTAnnotationTextViewDidCancelChangeNotification = @"OTAnnotationTextViewDidCancelChangeNotification";

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton setBackgroundColor:[UIColor clearColor]];
        [_cancelButton setImage:[UIImage imageNamed:@"delete icon" inBundle:[OTAnnotationKitBundle annotationKitBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        _cancelButton.center = CGPointMake(0, 0);
        [_cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelButton];
    }
    return _cancelButton;
}

- (void)setDraggable:(BOOL)draggable {
    _draggable = draggable;
    if (_draggable) {
        _onViewPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(handleOnViewDragGesture:)];
        [self addGestureRecognizer:_onViewPanRecognizer];
    }
    else {
        [self removeGestureRecognizer:_onViewPanRecognizer];
        _onViewPanRecognizer = nil;
    }
}

- (void)setResizable:(BOOL)resizable {
    _resizable = resizable;
    if (_resizable) {
        _onViewPinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleOnViewZoomGesture:)];
        [self addGestureRecognizer:_onViewPinchRecognizer];
        
        _pinchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_pinchButton setBackgroundColor:[UIColor clearColor]];
        [_pinchButton setImage:[UIImage imageNamed:@"resize icon" inBundle:[OTAnnotationKitBundle annotationKitBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        _pinchButton.center = CGPointMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        _pinchButton.layer.cornerRadius = CGRectGetWidth(_pinchButton.bounds) / 2;
        _pinchButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _pinchButton.layer.borderWidth = 2.0f;
        [self addSubview:_pinchButton];
        
        _onButtonZoomRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleOnButtonZoomGesture:)];
        [_pinchButton addGestureRecognizer:_onButtonZoomRecognizer];
    }
    else {
        
        [self removeGestureRecognizer:_onViewPinchRecognizer];
        _onViewPinchRecognizer = nil;
        
        // workaround: the text view will get cut off if we remove it directly
        _pinchButton.hidden = YES;
        _pinchButton = nil;
        
        [self removeGestureRecognizer:_onButtonZoomRecognizer];
        _onButtonZoomRecognizer = nil;
    }
}

- (void)setRotatable:(BOOL)rotatable {
    _rotatable = rotatable;
    if (_rotatable) {
        _onViewRotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleOnViewRotateGesture:)];
        [self addGestureRecognizer:_onViewRotationRecognizer];
        
        _rotateButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_rotateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_rotateButton setBackgroundColor:[UIColor clearColor]];
        [_rotateButton setImage:[UIImage imageNamed:@"rotate icon" inBundle:[OTAnnotationKitBundle annotationKitBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        _rotateButton.center = CGPointMake(0, CGRectGetHeight(self.bounds));
        _rotateButton.layer.cornerRadius = CGRectGetWidth(_rotateButton.bounds) / 2;
        _rotateButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _rotateButton.layer.borderWidth = 2.0f;
        [self addSubview:_rotateButton];
        
        _onButtonRotateRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleOnButtonRotateGesture:)];
        [_rotateButton addGestureRecognizer:_onButtonRotateRecognizer];
    }
    else {
        
        [self removeGestureRecognizer:_onViewRotationRecognizer];
        _onViewRotationRecognizer = nil;
        
        // workaround: the text view will get cut off if we remove it directly
        _rotateButton.hidden = YES;
        _rotateButton = nil;
        
        [self removeGestureRecognizer:_onButtonRotateRecognizer];
        _onButtonRotateRecognizer = nil;
    }
}

+ (instancetype)defaultWithTextColor:(UIColor *)textColor {
    return [[OTAnnotationTextView alloc] initWithText:nil textColor:textColor fontSize:0.0f];
}

- (instancetype)initWithText:(NSString *)text
                   textColor:(UIColor *)textColor
                    fontSize:(CGFloat)fontSize {
    
    if (self = [super init]) {
        
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        self.frame = CGRectMake(LeadingPaddingOfAnnotationTextView, 180, CGRectGetWidth(screenBounds) - LeadingPaddingOfAnnotationTextView * 2, 0);
        
        // attributes
        [self setClipsToBounds:NO];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setDelegate:self];
        [self setTextColor:textColor];
        [self setScrollEnabled:NO];
        [self setTextAlignment:NSTextAlignmentCenter];
        [self setTextContainerInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        [self setSelectable:NO];
        [self setEditable:YES];
        [self setUserInteractionEnabled:NO];
        
        // text content
        if (!text) {
            [self setText:@"Type Something"];
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
    
        _referenceTransform = CGAffineTransformIdentity;
        _currentTransform = CGAffineTransformIdentity;
        
        _referenceCenter = self.center;
        _currentCenter = self.center;
        
        [self resizeTextView];
    }
    return self;
}

- (void)setFont:(UIFont *)font {
    super.font = font;
    [self resizeTextView];
}

- (void)setFrame:(CGRect)frame {
    // -_- -_- -_- -_- -_-
    // workaround: http://stackoverflow.com/questions/16301147/why-uitextview-draws-text-in-bad-frame-after-resizing
    // by doing this, the text view won't get cut off after resizing
    [super setFrame:CGRectZero];
    [super setFrame:frame];
}

- (void)commit {
    
    self.layer.borderWidth = 0.0f;
    self.layer.borderColor = nil;
    self.backgroundColor = nil;

    self.resizable = NO;
    self.draggable = NO;
    self.rotatable = NO;
    
    // workaround: the text view will get cut off if we remove it directly
    self.cancelButton.hidden = YES;
    self.cancelButton = nil;
    
    [self setUserInteractionEnabled:NO];
    [OTKLogger logEventAction:KLogActionText variation:KLogVariationSuccess completion:nil];
}

- (void)resizeTextView {
    CGFloat fixedWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - LeadingPaddingOfAnnotationTextView * 2;
    CGSize newSize = [self sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = self.frame;
    newFrame.size = CGSizeMake(fixedWidth, newSize.height);
    self.frame = newFrame;
}

- (void)cancelButtonPressed:(UIButton *)sender {
    if (self.annotationTextViewDelegate) {
        [self.annotationTextViewDelegate annotationTextViewDidCancel:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:OTAnnotationTextViewDidCancelChangeNotification object:self];
    [self removeFromSuperview];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return YES;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    [self resizeTextView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    // for faking the place holder in UITextView
    if (!startTyping) {
        startTyping = YES;
        self.text = nil;
    }
    
    // handle done button from keyboard
    if ([text isEqualToString:@"\n"]) {
        
        if (!textView.text.length) return NO;
        
        if (self.annotationTextViewDelegate) {
            self.draggable = YES;
            self.resizable = YES;
            self.rotatable = YES;
            
            // set editable and selectable NO so it won't have the pop-up menu
            [self setEditable:NO];
            [self setSelectable:NO];
            [self.annotationTextViewDelegate annotationTextViewDidFinishChange:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:OTAnnotationTextViewDidFinishChangeNotification object:self];
            [self cancelButton];
        }
    }
    return YES;
}

@end
