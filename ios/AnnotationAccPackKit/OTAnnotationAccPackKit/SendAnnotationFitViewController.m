//
//  RemoteAnnotationViewController.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "SendAnnotationFitViewController.h"
#import "OTAnnotator.h"
#import "OTOneToOneCommunicator.h"

#import "AppDelegate.h"

@interface SendAnnotationFitViewController () <OTOneToOneCommunicatorDataSource, OTAnnotatorDataSource, OTAnnotationToolbarViewDataSource>
@property (nonatomic) OTAnnotator *annotator;
@property (nonatomic) OTOneToOneCommunicator *sharer;

@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet UIView *toolbarContainerView;

@end

@implementation SendAnnotationFitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Send Annotation(FIT MODE)";
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.sharer = [[OTOneToOneCommunicator alloc] init];
    self.sharer.dataSource = self;
    [self.sharer connectWithHandler:^(OTCommunicationSignal signal, NSError *error) {
                             
        if (!error) {

            if (signal == OTPublisherCreated) {
                self.sharer.publishAudio = NO;
                self.sharer.subscribeToAudio = NO;
            }
            else if (signal == OTSubscriberReady) {

                self.sharer.subscriberVideoContentMode = OTVideoViewFit;
                self.sharer.subscriberView.frame = self.shareView.bounds;

                // connect for annotation
                self.annotator = [[OTAnnotator alloc] init];
                self.annotator.dataSource = self;
                [self.annotator connectWithCompletionHandler:^(OTAnnotationSignal signal, NSError *error) {

                    if (signal == OTAnnotationSessionDidConnect){

                        // configure annotation view
                        self.annotator.annotationScrollView.frame = self.shareView.bounds;
                        self.annotator.annotationScrollView.scrollView.contentSize = self.shareView.bounds.size;
                        self.sharer.subscriberView.frame = self.annotator.annotationScrollView.bounds;
                        [self.annotator.annotationScrollView addContentView:self.sharer.subscriberView];
                        [self.shareView addSubview:self.annotator.annotationScrollView];

                        [self.annotator.annotationScrollView initializeUniversalToolbarView];
                        self.annotator.annotationScrollView.toolbarView.toolbarViewDataSource = self;

                        // using frame and self.view to contain toolbarView is for having more space to interact with color picker
                        self.annotator.annotationScrollView.toolbarView.frame = self.toolbarContainerView.frame;
                        [self.view addSubview:self.annotator.annotationScrollView.toolbarView];
                    }
                }];

                self.annotator.dataSendingHandler = ^(NSArray *data, NSError *error) {
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
    return self.shareView;
}

- (OTAcceleratorSession *)sessionOfOTAnnotator:(OTAnnotator *)annotator {
    return [(AppDelegate*)[[UIApplication sharedApplication] delegate] getSharedAcceleratorSession];
}

- (OTAcceleratorSession *)sessionOfOTOneToOneCommunicator:(OTOneToOneCommunicator *)oneToOneCommunicator {
    return [(AppDelegate*)[[UIApplication sharedApplication] delegate] getSharedAcceleratorSession];
}

@end
