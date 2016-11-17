//
//  OTAnnotationToolbarView.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotationToolbarView.h"
#import "UIView+Helper.h"
#import "UIButton+AutoLayoutHelper.h"

NSString * const kOTAnnotationToolbarDidPressDoneButton = @"kOTAnnotationToolbarDidPressDoneButton";
NSString * const kOTAnnotationToolbarDidPressDrawButton = @"kOTAnnotationToolbarDidPressDrawButton";
NSString * const kOTAnnotationToolbarDidPressTextButton = @"kOTAnnotationToolbarDidPressTextButton";
NSString * const kOTAnnotationToolbarDidPressEraseButton = @"kOTAnnotationToolbarDidPressEraseButton";
NSString * const kOTAnnotationToolbarDidPressCleanButton = @"kOTAnnotationToolbarDidPressCleanButton";
NSString * const kOTAnnotationToolbarDidAddTextAnnotation = @"kOTAnnotationToolbarDidAddTextAnnotation";

@interface OTAnnotationToolbarButton : UIButton
@end

@implementation OTAnnotationToolbarButton

- (instancetype)init {
    if (self = [super init]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    super.enabled = enabled;
    
    if (enabled) {
        [self setAlpha:1.0];
    }
    else {
        [self setAlpha:0.6];
    }
}

- (void)didMoveToSuperview {
    if (!self.superview) return;
    [self addCenterConstraints];
}

@end

@interface OTAnnotationToolbarDoneButton : UIButton
@end

@implementation OTAnnotationToolbarDoneButton

- (instancetype)init {
    if (self = [super init]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12);
    }
    return self;
}

- (void)didMoveToSuperview {
    if (!self.superview) return;
    [self addAttachedLayoutConstantsToSuperview];
}

@end

#import "OTAnnotationToolbarView_UserInterfaces.h"
#import "OTAnnotationToolbarView+Animation.h"
#import "OTAnnotationColorPickerView.h"
#import "OTAnnotationKitBundle.h"

#import <LHToolbar/LHToolbar.h>
#import "AnnLoggingWrapper.h"

#import "OTAnnotationScreenCaptureViewController.h"
#import "OTAnnotationEditTextViewController.h"
#import "UIViewController+Helper.h"
#import "Constants.h"

#import "OTAnnotationToolbarView_Private.h"

@interface OTAnnotationToolbarView() <OTAnnotationColorPickerViewProtocol, OTAnnotationEditTextViewProtocol> {
    
    BOOL isUniversal;
}
@property (nonatomic) LHToolbar *toolbar;
@property (weak, nonatomic) OTAnnotationScrollView *annotationScrollView;

@property (nonatomic) OTAnnotationToolbarDoneButton *doneButton;
@property (nonatomic) OTAnnotationToolbarButton *annotateButton;
@property (nonatomic) OTAnnotationColorPickerViewButton *colorButton;
@property (nonatomic) OTAnnotationToolbarButton *textButton;
@property (nonatomic) OTAnnotationToolbarButton *screenshotButton;
@property (nonatomic) OTAnnotationToolbarButton *eraseButton;
@property (nonatomic) OTAnnotationToolbarButton *eraseAllButton;

@property (nonatomic) OTAnnotationScreenCaptureViewController *captureViewController;
@end

@implementation OTAnnotationToolbarView

- (void)setAnnotationScrollView:(OTAnnotationScrollView *)annotationScrollView {
    _annotationScrollView = annotationScrollView;
    if (!annotationScrollView) {
        [[NSNotificationCenter defaultCenter] removeObserver:OTAnnotationTextViewDidCancelChangeNotification];
    }
}

- (void)setToolbarViewOrientation:(OTAnnotationToolbarViewOrientation)toolbarViewOrientation {
    _toolbarViewOrientation = toolbarViewOrientation;
    
    if (toolbarViewOrientation == OTAnnotationToolbarViewOrientationPortraitlBottom) {
        self.toolbar.orientation = LHToolbarOrientationHorizontal;
        self.colorPickerView.annotationColorPickerViewOrientation = OTAnnotationColorPickerViewOrientationPortrait;
    }
    else if (toolbarViewOrientation == OTAnnotationToolbarViewOrientationLandscapeLeft ||
             toolbarViewOrientation == OTAnnotationToolbarViewOrientationLandscapeRight) {
        self.toolbar.orientation = LHToolbarOrientationVertical;
        self.colorPickerView.annotationColorPickerViewOrientation = OTAnnotationColorPickerViewOrientationLandscape;
    }
    [self.toolbar reloadToolbar];
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
        
        _doneButton = [[OTAnnotationToolbarDoneButton alloc] init];
        [_doneButton setImage:[UIImage imageNamed:@"checkmark"
                                         inBundle:[OTAnnotationKitBundle annotationKitBundle]
                    compatibleWithTraitCollection:nil]
                     forState:UIControlStateNormal];
        [_doneButton setBackgroundColor:[UIColor colorWithRed:118.0/255.0f green:206.0/255.0f blue:31.0/255.0f alpha:1.0]];
        [_doneButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
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
        _toolbar = [[LHToolbar alloc] initWithNumberOfItems:6];
        _toolbar.translatesAutoresizingMaskIntoConstraints = NO;
        [self configureToolbarButtons];
        [self addSubview:_toolbar];
        [_toolbar addAttachedLayoutConstantsToSuperview];
        
        self.backgroundColor = [UIColor lightGrayColor];
        _annotationScrollView = annotationScrollView;
        
        [[NSNotificationCenter defaultCenter] addObserverForName:OTAnnotationTextViewDidCancelChangeNotification
                                                          object:nil queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *notification) {
                                                          
                                                          self.annotationScrollView.annotatable = NO;
                                                          [self dismissColorPickerViewWithAniamtion:NO];
                                                          [self.toolbar removeContentViewAtIndex:0];
                                                          [self moveSelectionShadowViewTo:nil];
                                                          [self resetToolbarButtons];
                                                      }];
    }
    return self;
}

- (instancetype)initUniversalWithFrame:(CGRect)frame
                  annotationScrollView:(OTAnnotationScrollView *)annotationScrollView{
    
    OTAnnotationToolbarView *toolbarView = [self initWithFrame:frame annotationScrollView:annotationScrollView];
    if (!toolbarView) return  nil;
    isUniversal = YES;
    return toolbarView;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:OTAnnotationTextViewDidCancelChangeNotification];
}

- (void)didMoveToSuperview {
    if (!self.superview) {
        self.annotationScrollView.annotatable = NO;
        [self.colorPickerView removeFromSuperview];
    }
}

- (void)done {
    if ([self.annotationScrollView.annotationView.currentAnnotatable isMemberOfClass:[OTAnnotationTextView class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kOTAnnotationToolbarDidAddTextAnnotation
                                                            object:nil
                                                          userInfo:@{@"self":self, @"annotation":self.annotationScrollView.annotationView.currentAnnotatable}];
    }
    self.annotationScrollView.annotatable = NO;
    [self dismissColorPickerViewWithAniamtion:YES];
    [self.toolbar removeContentViewAtIndex:0];
    [self moveSelectionShadowViewTo:nil];
    [self resetToolbarButtons];
    [[NSNotificationCenter defaultCenter] postNotificationName:kOTAnnotationToolbarDidPressDoneButton
                                                        object:nil
                                                      userInfo:@{@"self":self}];
    [[AnnLoggingWrapper sharedInstance].logger logEventAction:KLogActionDone variation:KLogVariationSuccess completion:nil];
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
    [_screenshotButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _eraseButton = [[OTAnnotationToolbarButton alloc] init];
    [_eraseButton setImage:[UIImage imageNamed:@"erase" inBundle:frameworkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_eraseButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _eraseAllButton = [[OTAnnotationToolbarButton alloc] init];
    [_eraseAllButton setImage:[UIImage imageNamed:@"trashcan" inBundle:frameworkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_eraseAllButton addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [_toolbar setContentView:_annotateButton atIndex:0];
    [_toolbar setContentView:_colorButton atIndex:1];
    [_toolbar setContentView:_textButton atIndex:2];
    [_toolbar setContentView:_screenshotButton atIndex:3];
    [_toolbar setContentView:_eraseButton atIndex:4];
    [_toolbar setContentView:_eraseAllButton atIndex:5];
    
    [_toolbar reloadToolbar];
}

- (void)toolbarButtonPressed:(UIButton *)sender {
    
    if (sender == self.doneButton) {
        [self done];
    }
    else if (sender == self.annotateButton) {
        self.annotationScrollView.annotatable = YES;
        [self dismissColorPickerViewWithAniamtion:YES];
        [self.toolbar insertContentView:self.doneButton atIndex:0];
        OTAnnotationPath *path = [[OTAnnotationPath alloc] initWithStrokeColor:self.colorPickerView.selectedColor];
        [self.annotationScrollView.annotationView setCurrentAnnotatable:path];
        [self disableButtons:@[self.annotateButton ,self.textButton, self.eraseButton, self.eraseAllButton]];
        [[NSNotificationCenter defaultCenter] postNotificationName:kOTAnnotationToolbarDidPressDrawButton
                                                            object:nil
                                                          userInfo:@{@"self":self, @"annotation":path}];
    }
    else if (sender == self.textButton) {
    
        self.annotationScrollView.annotatable = YES;
        [self dismissColorPickerViewWithAniamtion:NO];
        [self.toolbar insertContentView:self.doneButton atIndex:0];
        
        OTAnnotationEditTextViewController *editTextViewController;
        if (!isUniversal) {
            editTextViewController = [[OTAnnotationEditTextViewController alloc] initWithTextColor:self.colorButton.backgroundColor];
        }
        else {
            editTextViewController = [[OTAnnotationEditTextViewController alloc] initRemoteWithTextColor:self.colorButton.backgroundColor];
        }
        editTextViewController.delegate = self;
        UIViewController *topViewController = [UIViewController topViewControllerWithRootViewController];
        [topViewController presentViewController:editTextViewController animated:YES completion:nil];
        [self disableButtons:@[self.annotateButton, self.textButton, self.screenshotButton, self.eraseButton, self.eraseAllButton]];
        [[NSNotificationCenter defaultCenter] postNotificationName:kOTAnnotationToolbarDidPressTextButton
                                                            object:nil
                                                          userInfo:@{@"self":self}];
    }
    else if (sender == self.colorButton) {
        [self showColorPickerView];
    }
    else if (sender == self.eraseButton) {
        id<OTAnnotatable> anotatableToRemove = [self.annotationScrollView.annotationView undoAnnotatable];
        [[NSNotificationCenter defaultCenter] postNotificationName:kOTAnnotationToolbarDidPressEraseButton
                                                            object:nil
                                                          userInfo:@{@"self":self, @"annotation":anotatableToRemove}];
    }
    else if (sender == self.eraseAllButton) {
        [self.annotationScrollView.annotationView removeAllAnnotatables];
        [[NSNotificationCenter defaultCenter] postNotificationName:kOTAnnotationToolbarDidPressCleanButton
                                                            object:nil
                                                          userInfo:@{@"self":self}];
    }
    else if (sender == self.screenshotButton) {
        
        [self dismissColorPickerViewWithAniamtion:NO];
        [self moveSelectionShadowViewTo:nil];
        
        if (self.toolbarViewDataSource) {
            self.captureViewController.sharedImage = [self.annotationScrollView.annotationView captureScreenWithView:[self.toolbarViewDataSource annotationToolbarViewForRootViewForScreenShot:self]];
        }
        else {
            self.captureViewController.sharedImage = [self.annotationScrollView.annotationView captureScreenWithView:_annotationScrollView];
        }
        UIViewController *topViewController = [UIViewController topViewControllerWithRootViewController];
        [topViewController presentViewController:self.captureViewController animated:YES completion:nil];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (sender != self.textButton && sender != self.screenshotButton && sender != self.eraseButton && sender != self.eraseAllButton) {
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
    [self.eraseAllButton setEnabled:YES];
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
        [self done];
    }
}

#pragma mark - ScreenShareColorPickerViewProtocol

- (void)colorPickerView:(OTAnnotationColorPickerView *)colorPickerView
   didSelectColorButton:(OTAnnotationColorPickerViewButton *)button
          selectedColor:(UIColor *)selectedColor {
    
    [[AnnLoggingWrapper sharedInstance].logger logEventAction:KLogActionPickerColor variation:KLogVariationSuccess completion:nil];
    [self.colorButton setBackgroundColor:selectedColor];
    if (self.annotationScrollView.isAnnotatable) {
        if ([self.annotationScrollView.annotationView.currentAnnotatable isKindOfClass:[OTAnnotationTextView class]]) {
            
            OTAnnotationTextView *textView = (OTAnnotationTextView *)self.annotationScrollView.annotationView.currentAnnotatable;
            textView.textColor = selectedColor;
        }
        else {
            
            OTAnnotationPath *path = [[OTAnnotationPath alloc] initWithStrokeColor:selectedColor];
            [self.annotationScrollView.annotationView setCurrentAnnotatable:path];
        }
    }
}

@end
