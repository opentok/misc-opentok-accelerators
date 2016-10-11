//
//  ReceiveAnnotationViewController.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "ReceiveAnnotationViewController.h"
#import <OTAnnotationKit/OTAnnotationKit.h>
#import <OTScreenShareKit/OTScreenShareKit.h>

@interface ReceiveAnnotationViewController ()
@property (nonatomic) OTAnnotator *annotator;
@property (nonatomic) OTScreenSharer *sharer;
@end

@implementation ReceiveAnnotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Receive Annotation";
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.sharer = [OTScreenSharer sharedInstance];
    [self.sharer connectWithView:self.view
                         handler:^(OTScreenShareSignal signal, NSError *error) {
                             
                             if (!error) {
                                 
                                 if (signal == OTScreenShareSignalSessionDidConnect) {
                                     self.sharer.publishAudio = NO;
                                     self.sharer.subscribeToAudio = NO;
                                     
                                     self.annotator = [[OTAnnotator alloc] init];
                                     [self.annotator connectForReceivingAnnotationWithSize:self.view.bounds.size
                                                                         completionHandler:^(OTAnnotationSignal signal, NSError *error) {
                                                                             if (signal == OTAnnotationSessionDidConnect){
                                                                                 self.annotator.annotationScrollView.frame = self.view.bounds;
                                                                                 [self.view addSubview:self.annotator.annotationScrollView];
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


@end
