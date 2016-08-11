//
//  OTFullScreenAnnotationViewController.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTFullScreenAnnotationViewController.h"
#import "OTAnnotationScrollView.h"
#import "OTAnnotationScrollView_Private.h"

@interface OTFullScreenAnnotationViewController ()
@property (nonatomic) OTAnnotationScrollView *annotationView;
@end

@implementation OTFullScreenAnnotationViewController

- (instancetype)init {
    
    if (self = [super init]) {
        
        _annotationView = [[OTAnnotationScrollView alloc] initWithFrame:CGRectZero];
        [_annotationView initializeToolbarView];
        CGFloat height = _annotationView.toolbarView.bounds.size.height;
        
        _annotationView.frame = CGRectMake(0,
                                           0,
                                           CGRectGetWidth([UIScreen mainScreen].bounds),
                                           CGRectGetHeight([UIScreen mainScreen].bounds) - height);
        _annotationView.toolbarView.frame =  CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) - height, _annotationView.toolbarView.bounds.size.width, height);
        
        [self.view addSubview:_annotationView];
        [self.view addSubview:_annotationView.toolbarView];
        
        self.providesPresentationContextTransitionStyle = YES;
        self.definesPresentationContext = YES;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}

@end
