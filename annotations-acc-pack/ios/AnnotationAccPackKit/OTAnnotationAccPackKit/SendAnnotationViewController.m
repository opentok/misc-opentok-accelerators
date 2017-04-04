//
//  RemoteAnnotationViewController.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "SendAnnotationViewController.h"
#import <OTAnnotationKit/OTAnnotationKit.h>

@interface SendAnnotationViewController () <AnnotationDelegate>
@property (nonatomic) OTAnnotator *annotator;
@end

@implementation SendAnnotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.annotator = [[OTAnnotator alloc] init];
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
