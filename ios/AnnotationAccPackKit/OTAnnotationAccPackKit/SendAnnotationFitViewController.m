//
//  RemoteAnnotationViewController.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "SendAnnotationFitViewController.h"
#import <OTAnnotationKit/OTAnnotationKit.h>
#import <OTScreenShareKit/OTScreenShareKit.h>

@interface SendAnnotationFitViewController ()
@property (nonatomic) OTAnnotator *annotator;
@property (nonatomic) OTScreenSharer *sharer;
@end

@implementation SendAnnotationFitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Send Annotation(FIT MODE)";
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.sharer = [OTScreenSharer sharedInstance];
    self.sharer.subscriberVideoContentMode = OTScreenShareVideoViewFit;
    [self.sharer connectWithView:nil
                         handler:^(OTScreenShareSignal signal, NSError *error) {
                             
                             if (!error) {
                                 
                                 if (signal == OTScreenShareSignalSessionDidConnect) {
                                     self.sharer.publishAudio = NO;
                                     self.sharer.subscribeToAudio = NO;
                                 }
                                 else if (signal == OTScreenShareSignalSubscriberDidConnect) {
                                     
                                     [self.sharer.subscriberView removeFromSuperview];
                                     self.sharer.subscriberView.frame = self.view.bounds;
                                     
                                     // connect for annotation
                                     self.annotator = [[OTAnnotator alloc] init];
                                     [self.annotator connectForSendingAnnotationWithSize:self.sharer.subscriberView.frame.size completionHandler:^(OTAnnotationSignal signal, NSError *error) {
                                         
                                         if (signal == OTAnnotationSessionDidConnect){
                                             
                                             // configure annotation view
                                             self.annotator.annotationScrollView.frame = self.view.bounds;
                                             [self.annotator.annotationScrollView addContentView:self.sharer.subscriberView];
                                             [self.view addSubview:self.annotator.annotationScrollView];
                                             
                                             // configure annotation feature
                                             self.annotator.annotationScrollView.annotatable = YES;
                                             self.annotator.annotationScrollView.annotationView.currentAnnotatable = [OTAnnotationPath pathWithStrokeColor:[UIColor yellowColor]];
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

@end
