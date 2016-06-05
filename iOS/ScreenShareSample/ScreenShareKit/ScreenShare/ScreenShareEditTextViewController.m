//
//  ScreenShareEditTextViewController.m
//  ScreenShareSample
//
//  Created by Xi Huang on 6/2/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "ScreenShareEditTextViewController.h"
#import "AnnotationTextView.h"

@interface ScreenShareEditTextViewController()
@property (nonatomic) AnnotationTextView *annotationTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomLayoutConstraint;
@end

@implementation ScreenShareEditTextViewController

+ (instancetype)defaultWithTextColor:(UIColor *)textColor {
    
    return [[ScreenShareEditTextViewController alloc] initWithText:nil textColor:textColor fontSize:0.0f];
}

- (instancetype)initWithText:(NSString *)text
                   textColor:(UIColor *)textColor
                    fontSize:(CGFloat)fontSize {
    
    if (self = [super initWithNibName:@"ScreenShareEditTextViewController"
                               bundle:[NSBundle bundleForClass:[ScreenShareEditTextViewController class]]]) {
        self.providesPresentationContextTransitionStyle = YES;
        self.definesPresentationContext = YES;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
        CGRect mainBounds = [UIScreen mainScreen].bounds;
        blurView.frame = CGRectMake(0, 0, CGRectGetWidth(mainBounds), CGRectGetHeight(mainBounds));
        [self.view insertSubview:blurView atIndex:0];
        
        _annotationTextView  = [AnnotationTextView defaultWithTextColor:textColor];
        [_annotationTextView setUserInteractionEnabled:NO];
        [self.view addSubview:_annotationTextView];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.annotationTextView becomeFirstResponder];
    __weak ScreenShareEditTextViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillChangeFrameNotification
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification *notification){
                                                      
                                                      CGFloat keyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
                                                      weakSelf.toolbarBottomLayoutConstraint.constant = keyboardHeight;
                                                  }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.annotationTextView resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)removeButtonPressed:(id)sender {
    if (self.delegate) {
        [self.delegate screenShareEditTextViewController:self didFinishEditing:nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButtonPressed:(id)sender {
    if (self.delegate) {
        [self.delegate screenShareEditTextViewController:self didFinishEditing:self.annotationTextView];
    }
    [self.annotationTextView setUserInteractionEnabled:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
