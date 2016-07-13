//
//  RemoteAnnotationViewController.m
//  OTScreenShareAccPackKit
//
//  Created by Xi Huang on 7/12/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "RemoteAnnotationViewController.h"
#import <OTScreenShareKit/OTScreenShareKit.h>

@interface RemoteAnnotationViewController ()
@property (nonatomic) OTScreenSharer *screenSharer;
@end

@implementation RemoteAnnotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - 64)];
    redView.backgroundColor = [UIColor redColor];
    [self.view addSubview:redView];
    
    self.screenSharer = [OTScreenSharer screenSharer];
    [self.screenSharer connectWithView:redView handler:^(ScreenShareSignal signal, NSError *error) {
        
        if (signal == ScreenShareSignalSessionDidConnect) {
            [self.screenSharer initializeRemoteAnnotator];
            self.screenSharer.remoteAnnotator.remoteAnnotationEnabled = YES;
        }
    }];
}

@end
