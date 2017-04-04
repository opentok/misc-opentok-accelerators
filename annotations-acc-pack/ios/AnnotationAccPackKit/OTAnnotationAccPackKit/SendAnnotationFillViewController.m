//
//  SendAnnotationFillViewController.m
//  OTAnnotationAccPackKit
//
//  Created by Xi Huang on 9/13/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "SendAnnotationFillViewController.h"

#import "OTAnnotator.h"
#import "OTOneToOneCommunicator.h"

#import "AppDelegate.h"

@interface SendAnnotationFillViewController () <OTOneToOneCommunicatorDataSource, OTAnnotatorDataSource>
@property (nonatomic) OTAnnotator *annotator;
@property (nonatomic) OTOneToOneCommunicator *sharer;
@end

@implementation SendAnnotationFillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Send Annotation(FILL MODE)";
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self setupScollingAssistance];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.sharer = [[OTOneToOneCommunicator alloc] init];
    self.sharer.dataSource = self;
    self.sharer.subscriberVideoContentMode = OTVideoViewFit;
    [self.sharer connectWithHandler:^(OTCommunicationSignal signal, NSError *error) {
                             
        if (!error) {

            if (signal == OTPublisherCreated) {
                self.sharer.publishAudio = NO;
                self.sharer.subscribeToAudio = NO;
            }
            else if (signal == OTSubscriberReady) {

                [self.sharer.subscriberView removeFromSuperview];
#warning - TODO
//                self.sharer.subscriberView.frame = CGRectMake(0, 0, self.sharer.subscriberVideoDimension.width, self.sharer.subscriberVideoDimension.height);

                // connect for annotation
                self.annotator = [[OTAnnotator alloc] init];
                self.annotator.dataSource = self;
                [self.annotator connectWithCompletionHandler:^(OTAnnotationSignal signal, NSError *error) {
           
                    if (signal == OTAnnotationSessionDidConnect){

                        // configure annotation view
                        self.annotator.annotationScrollView.frame = self.view.bounds;
                        self.annotator.annotationScrollView.scrollView.contentSize = self.sharer.subscriberView.frame.size;
                        [self.view addSubview:self.annotator.annotationScrollView];

                        // self.sharer.subscriberView is the screen shared from a remote client.
                        // It does not make sense to `connectForSendingAnnotationWithSize` if you don't receive a screen sharing.
                        [self.annotator.annotationScrollView addContentView:self.sharer.subscriberView];

                        // configure annotation feature
                        self.annotator.annotationScrollView.annotatable = YES;
                        self.annotator.annotationScrollView.annotationView.currentAnnotatable = [[OTAnnotationPath alloc] initWithStrokeColor:[UIColor yellowColor]];
                    }
                }];

                self.annotator.dataSendingHandler = ^(NSArray *data, NSError *error) {
                    NSLog(@"%@", data);
                };
            }
        }
    }];
}

- (void)setupScollingAssistance {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Switch" style:UIBarButtonItemStylePlain target:self action:@selector(switchScrollingAndAnnotation)];
}

- (void)switchScrollingAndAnnotation {
    
    NSString *title;
    if (self.annotator.annotationScrollView.annotatable) {
        title = @"Want to switch to annotation?";
    }
    else {
        title = @"Want to switch to scrolling?";
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        self.annotator.annotationScrollView.annotatable = !self.annotator.annotationScrollView.annotatable;
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    alert.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.annotator disconnect];
    self.annotator = nil;
    [self.sharer disconnect];
    self.sharer = nil;
}

- (OTAcceleratorSession *)sessionOfOTAnnotator:(OTAnnotator *)annotator {
    return [(AppDelegate*)[[UIApplication sharedApplication] delegate] getSharedAcceleratorSession];
}

- (OTAcceleratorSession *)sessionOfOTOneToOneCommunicator:(OTOneToOneCommunicator *)oneToOneCommunicator {
    return [(AppDelegate*)[[UIApplication sharedApplication] delegate] getSharedAcceleratorSession];
}

@end
