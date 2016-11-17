//
//  ReceiveAnnotationOnPartialViewController.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "ReceiveAnnotationOnPartialViewController.h"
#import <OTAnnotationKit/OTAnnotationKit.h>
#import <OTScreenShareKit/OTScreenShareKit.h>

@interface ReceiveAnnotationOnPartialViewController() <OTAnnotationToolbarViewDataSource>
@property (nonatomic) OTAnnotator *annotator;
@property (nonatomic) OTScreenSharer *sharer;

@property (weak, nonatomic) IBOutlet UIView *yellowView;
@property (weak, nonatomic) IBOutlet UIView *toolbarContainerView;
@end

@implementation ReceiveAnnotationOnPartialViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Receive annotation on partial canvas";
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.sharer = [OTScreenSharer sharedInstance];
    [self.sharer connectWithView:self.yellowView
                         handler:^(OTScreenShareSignal signal, NSError *error) {
                             
                             if (!error) {
                                 
                                 if (signal == OTScreenShareSignalSessionDidConnect) {
                                     self.sharer.publishAudio = NO;
                                     self.sharer.subscribeToAudio = NO;
                                     self.annotator = [[OTAnnotator alloc] init];
                                     [self.annotator connectWithCompletionHandler:^(OTAnnotationSignal signal, NSError *error) {
                                         if (signal == OTAnnotationSessionDidConnect){
                                             self.annotator.annotationScrollView.frame = self.yellowView.bounds;
                                             self.annotator.annotationScrollView.scrollView.contentSize = self.view.bounds.size;
                                             [self.yellowView addSubview:self.annotator.annotationScrollView];
                                             
                                             [self.annotator.annotationScrollView initializeToolbarView];
                                             self.annotator.annotationScrollView.toolbarView.toolbarViewDataSource = self;
                                             
                                             // using frame and self.view to contain toolbarView is for having more space to interact with color picker
                                             self.annotator.annotationScrollView.toolbarView.frame = self.toolbarContainerView.frame;
                                             [self.view addSubview:self.annotator.annotationScrollView.toolbarView];
                                         }
                                     }];
                                     
                                     self.annotator.dataReceivingHandler = ^(NSArray *data) {
                                         NSLog(@"%@", data);
                                     };
                                 }
                             }
                         }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.annotator disconnect];
    self.annotator = nil;
    [self.sharer disconnect];
    self.sharer = nil;
}

- (UIView *)annotationToolbarViewForRootViewForScreenShot:(OTAnnotationToolbarView *)toolbarView {
    return self.yellowView;
}

@end
