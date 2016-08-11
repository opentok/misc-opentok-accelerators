//
//  ReceiveAnnotationViewController.m
//  OTAnnotationAccPackKit
//
//  Created by Xi Huang on 7/26/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "ReceiveAnnotationViewController.h"
#import <OTAnnotationKit/OTAnnotationKit.h>

@interface ReceiveAnnotationViewController () <AnnotationDelegate>
@property (nonatomic) OTAnnotator *annotator;
@end

@implementation ReceiveAnnotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.annotator = [OTAnnotator annotator];
    self.annotator.delegate = self;
    [self.annotator connectForReceivingAnnotation];
}

- (void)annotationWithSignal:(OTAnnotationSignal)signal
                       error:(NSError *)error {
    
    if (signal == OTAnnotationSessionDidConnect){
        [self.view addSubview:self.annotator.annotationView];
    }
}

@end
