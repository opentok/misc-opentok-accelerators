//
//  OTRemoteAnnotator.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTRemoteAnnotator.h"
#import "OTRemoteAnnotator_Private.h"
#import "OTScreenSharer_Private.h"

@implementation OTRemoteAnnotator

- (void)setReceiveEnabled:(BOOL)receiveEnabled{
    if (_receiveEnabled == receiveEnabled) return;
    _receiveEnabled = receiveEnabled;
    if (_receiveEnabled) {
        self.annotationView.frame = self.screenSharer.screenCapture.view.bounds;
        [self.screenSharer.screenCapture.view addSubview:self.annotationView];
    }
    else {
        [self.annotationView removeFromSuperview];
    }
}

@end
