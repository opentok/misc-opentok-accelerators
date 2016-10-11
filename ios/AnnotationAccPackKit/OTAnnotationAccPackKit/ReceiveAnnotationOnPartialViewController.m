//
//  ReceiveAnnotationOnPartialViewController.m
//  OTAnnotationAccPackKit
//
//  Created by Xi Huang on 9/21/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "ReceiveAnnotationOnPartialViewController.h"
#import <OTAnnotationKit/OTAnnotationKit.h>
#import <OTScreenShareKit/OTScreenShareKit.h>

@interface ReceiveAnnotationOnPartialViewController()
@property (weak, nonatomic) IBOutlet UIView *yellowView;
@property (nonatomic) OTAnnotator *annotator;
@property (nonatomic) OTScreenSharer *sharer;
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
                                     [self.annotator connectForReceivingAnnotationWithSize:self.yellowView.bounds.size completionHandler:^(OTAnnotationSignal signal, NSError *error) {
                                         if (signal == OTAnnotationSessionDidConnect){
                                             self.annotator.annotationScrollView.frame = self.yellowView.bounds;
                                             [self.yellowView addSubview:self.annotator.annotationScrollView];
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
