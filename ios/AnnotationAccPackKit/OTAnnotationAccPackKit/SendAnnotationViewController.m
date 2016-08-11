//
//  RemoteAnnotationViewController.m
//  OTAnnotationAccPackKit
//
//  Created by Xi Huang on 7/18/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "SendAnnotationViewController.h"
#import <OTAnnotationKit/OTAnnotationKit.h>
#import <OTScreenShareKit/OTScreenShareKit.h>

@interface SendAnnotationViewController () <AnnotationDelegate>
@property (nonatomic) OTAnnotator *annotator;
@property (nonatomic) OTScreenSharer *sharer;
@end

@implementation SendAnnotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    /**
     *  UNCOMMENT THIS TO START TESTING
     */
    self.sharer = [OTScreenSharer screenSharer];
    [self.sharer connectWithView:[UIApplication sharedApplication].keyWindow.rootViewController.view
                         handler:^(ScreenShareSignal signal, NSError *error) {
                             
                             if (!error) {
                                 NSLog(@"Start screen sharing");
                             }
                         }];
    
    self.annotator = [OTAnnotator annotator];
    self.annotator.delegate = self;
    [self.annotator connectForSendingAnnotation];
    self.annotator.annotationView.currentAnnotatable = [OTAnnotationPath pathWithStrokeColor:[UIColor yellowColor]];
}

- (void)annotationWithSignal:(OTAnnotationSignal)signal
                       error:(NSError *)error {
    
    if (signal == OTAnnotationSessionDidConnect){
        [self.view addSubview:self.annotator.annotationView];
    }
}

@end
