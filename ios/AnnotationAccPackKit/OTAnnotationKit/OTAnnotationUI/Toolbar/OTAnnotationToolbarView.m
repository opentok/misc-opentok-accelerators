//
//  OTAnnotationToolbarView.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotationToolbarView.h"
#import "OTAnnotationToolbarView_UserInterfaces.h"
#import "OTAnnotationToolbarView+Animation.h"
#import "OTAnnotationColorPickerView.h"
#import "OTAnnotationToolbarButton.h"
#import "OTAnnotationKitBundle.h"

#import <LHToolbar/LHToolbar.h>
#import <OTKAnalytics/OTKLogger.h>

#import "OTAnnotationScreenCaptureViewController.h"
#import "OTAnnotationEditTextViewController.h"
#import "UIViewController+Helper.h"
#import "Constants.h"

#import "OTAnnotationToolbarView_Private.h"

@interface OTAnnotationToolbarView() <OTAnnotationColorPickerViewProtocol, OTAnnotationEditTextViewProtocol>
@property (nonatomic) LHToolbar *toolbar;
@property (weak, nonatomic) OTAnnotationScrollView *annotationScrollView;

@property (nonatomic) UIButton *doneButton;
@property (nonatomic) OTAnnotationToolbarButton *annotateButton;
@property (nonatomic) OTAnnotationColorPickerViewButton *colorButton;
@property (nonatomic) OTAnnotationToolbarButton *textButton;
@property (nonatomic) OTAnnotationToolbarButton *screenshotButton;
@property (nonatomic) OTAnnotationToolbarButton *eraseButton;

@property (nonatomic) OTAnnotationScreenCaptureViewController *captureViewController;
@end

@implementation OTAnnotationToolbarView

- (void)setAnnotationScrollView:(OTAnnotationScrollView *)annotationScrollView {
    _annotationScrollView = annotationScrollView;
    if (!annotationScrollView) {
        [[NSNotificationCenter defaultCenter] removeObserver:OTAnnotationTextViewDidCancelChangeNotification];
    }
}

- (OTAnnotationColorPickerView *)colorPickerView {
    if (!_colorPickerView) {
        _colorPickerView = [[OTAnnotationColorPickerView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, CGRectGetWidth([UIScreen mainScreen].bounds), HeightOfColorPicker)];
        _colorPickerView.delegate = self;
    }
    return _colorPickerView;
}

- (UIView *)selectionShadowView {
    if (!_selectionShadowView) {
        _selectionShadowView = [[UIView alloc] init];
        _selectionShadowView.backgroundColor = [UIColor blackColor];
        _selectionShadowView.alpha = 0.8;
    }
    return _selectionShadowView;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        
        _doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds) / 6, CGRectGetHeight(self.bounds))];
        [_doneButton.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [_doneButton setImage:[UIImage imageNamed:@"checkmark" inBundle:[OTAnnotationKitBundle annotationKitBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        _doneButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneButton setBackgroundColor:[UIColor colorWithRed:118.0/255.0f green:206.0/255.0f blue:31.0/255.0f alpha:1.0]];
        [_doneButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _doneButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    }
    return _doneButton;
}

- (OTAnnotationScreenCaptureViewController *)captureViewController {
    if (!_captureViewController) {
        _captureViewController = [[OTAnnotationScreenCaptureViewController alloc] initWithSharedImage:nil];
    }
    return _captureViewController;
}

- (instancetype)initWithFrame:(CGRect)frame
         annotationScrollView:(OTAnnotationScrollView *)annotationScrollView {
    
    if (!annotationScrollView) return nil;
    
    if (self = [super initWithFrame:frame]) {
        _toolbar = [[LHToolbar alloc] initWithNumberOfItems:5];
        _toolbar.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        [self configureToolbarButtons];
        [self addSubview:_toolbar];
        self.backgroundColor = [UIColor lightGrayColor];
        _annotationScrollView = annotationScrollView;
        
        [[NSNotificationCenter defaultCenter] addObserverForName:OTAnnotationTextViewDidCancelChangeNotification
                                                          object:nil queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *notification) {
                                                          
                                                          [self toolbarButtonPressed:self.doneButton];
                                                      }];
    }
    return self;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:OTAnnotationTextViewDidCancelChangeNotification];
}

+ (instancetype)toolbar {
    CGRect mainBounds = [UIScreen mainScreen].bounds;
    return [[OTAnnotationToolbarView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(mainBounds), DefaultToolbarHeight)];
}

- (void)setFrame:(CGRect)frame {
    CGRect mainBounds = [UIScreen mainScreen].bounds;
    super.frame = CGRectMake(frame.origin.x, frame.origin.y, CGRectGetWidth(mainBounds), DefaultToolbarHeight);
}

- (void)didMoveToSuperview {
    if (!self.superview) {
        self.annotationScrollView.annotatable = NO;
        [self.colorPickerView removeFromSuperview];
    }
}

- (void)configureToolbarButtons {

    NSBundle *frameworkBundle = [OTAnnotationKitBundle annotationKitBundle];
    
    _annotateButton = [[OTAnnotationToolbarButton alloc] init];
    [_annotateButton setImage:[UIImage imageNamed:@"annotate" inBundle:frameworkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_annotateButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _colorButton = [[OTAnnotationColorPickerViewButton alloc] init];
    [_colorButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    _textButton = [[OTAnnotationToolbarButton alloc] init];
    [_textButton setImage:[UIImage imageNamed:@"text" inBundle:frameworkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_textButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _screenshotButton = [[OTAnnotationToolbarButton alloc] init];
    [_screenshotButton setImage:[UIImage imageNamed:@"screenshot" inBundle:frameworkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    _screenshotButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_screenshotButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _eraseButton = [[OTAnnotationToolbarButton alloc] init];
    [_eraseButton setImage:[UIImage imageNamed:@"erase" inBundle:frameworkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_eraseButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [_toolbar setContentView:_annotateButton atIndex:0];
    [_toolbar setContentView:_colorButton atIndex:1];
    [_toolbar setContentView:_textButton atIndex:2];
    [_toolbar setContentView:_screenshotButton atIndex:3];
    [_toolbar setContentView:_eraseButton atIndex:4];
    
    [_toolbar reloadToolbar];
}

- (void)toolbarButtonPressed:(UIButton *)sender {
    
    if (sender == self.doneButton) {
        self.annotationScrollView.annotatable = NO;
        [self dismissColorPickerView];
        [self.toolbar removeContentViewAtIndex:0];
        [self moveSelectionShadowViewTo:nil];
        [self resetToolbarButtons];
        [OTKLogger logEventAction:KLogActionDone variation:KLogVariationSuccess completion:nil];
    }
    else if (sender == self.annotateButton) {
        self.annotationScrollView.annotatable = YES;
        [self dismissColorPickerView];
        [self.toolbar insertContentView:self.doneButton atIndex:0];
        [self.annotationScrollView.annotationView setCurrentAnnotatable:[OTAnnotationPath pathWithStrokeColor:self.colorPickerView.selectedColor]];
        [self disableButtons:@[self.annotateButton ,self.textButton, self.eraseButton]];
    }
    else if (sender == self.textButton) {
        self.annotationScrollView.annotatable = YES;
        [self dismissColorPickerView];
        [self.toolbar insertContentView:self.doneButton atIndex:0];
        OTAnnotationEditTextViewController *editTextViewController = [OTAnnotationEditTextViewController defaultWithTextColor:self.colorButton.backgroundColor];
        editTextViewController.delegate = self;
        UIViewController *topViewController = [UIViewController topViewControllerWithRootViewController];
        [topViewController presentViewController:editTextViewController animated:YES completion:nil];
        [self disableButtons:@[self.annotateButton, self.textButton, self.screenshotButton, self.eraseButton]];
    }
    else if (sender == self.colorButton) {
        [self showColorPickerView];
    }
    else if (sender == self.eraseButton) {
        [self.annotationScrollView.annotationView undoAnnotatable];
    }
    else if (sender == self.screenshotButton) {
        self.captureViewController.sharedImage = [self.annotationScrollView.annotationView captureScreen];
        UIViewController *topViewController = [UIViewController topViewControllerWithRootViewController];
        [topViewController presentViewController:self.captureViewController animated:YES completion:nil];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (sender != self.screenshotButton && sender != self.eraseButton) {
            [self moveSelectionShadowViewTo:sender];
        }
    });
}

- (void)resetToolbarButtons {
    
    [self.annotateButton setEnabled:YES];
    [self.colorButton setEnabled:YES];
    [self.textButton setEnabled:YES];
    [self.screenshotButton setEnabled:YES];
    [self.eraseButton setEnabled:YES];
}

- (void)disableButtons:(NSArray<UIButton *> *)array {
    
    for (UIButton *button in array) {
        [button setEnabled:NO];
    }
}

#pragma mark - ScreenShareEditTextViewProtocol

- (void)annotationEditTextViewController:(OTAnnotationEditTextViewController *)editTextViewController
                        didFinishEditing:(OTAnnotationTextView *)annotationTextView {
    
    if (annotationTextView) {
        [annotationTextView setEditable:NO];
        [self.annotationScrollView addContentView:annotationTextView];
        [self.annotationScrollView addTextAnnotation:annotationTextView];
    }
    else {
        [self toolbarButtonPressed:self.doneButton];
    }
}

#pragma mark - ScreenShareColorPickerViewProtocol

- (void)colorPickerView:(OTAnnotationColorPickerView *)colorPickerView
   didSelectColorButton:(OTAnnotationColorPickerViewButton *)button
          selectedColor:(UIColor *)selectedColor {
    
    [OTKLogger logEventAction:KLogActionPickerColor variation:KLogVariationSuccess completion:nil];
    [self.colorButton setBackgroundColor:selectedColor];
    if (self.annotationScrollView.isAnnotatable) {
        if ([self.annotationScrollView.annotationView.currentAnnotatable isKindOfClass:[OTAnnotationTextView class]]) {
            
            OTAnnotationTextView *textView = (OTAnnotationTextView *)self.annotationScrollView.annotationView.currentAnnotatable;
            textView.textColor = selectedColor;
        }
        else {
            
            [self.annotationScrollView.annotationView setCurrentAnnotatable:[OTAnnotationPath pathWithStrokeColor:selectedColor]];
        }
    }
}

@end
