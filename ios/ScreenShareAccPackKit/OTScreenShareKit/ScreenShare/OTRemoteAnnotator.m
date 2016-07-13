//
//  OTRemoteAnnotator.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTRemoteAnnotator.h"
#import "OTRemoteAnnotator_Private.h"
#import "OTScreenSharer_Private.h"

@implementation OTRemoteAnnotator

- (void)setRemoteAnnotationEnabled:(BOOL)remoteAnnotationEnabled {
    if (_remoteAnnotationEnabled == remoteAnnotationEnabled) return;
    _remoteAnnotationEnabled = remoteAnnotationEnabled;
    if (_remoteAnnotationEnabled) {
        self.annotationView.frame = self.screenSharer.screenCapture.view.bounds;
        [self.screenSharer.screenCapture.view addSubview:self.annotationView];
    }
    else {
        [self.annotationView removeFromSuperview];
    }
}

@end
