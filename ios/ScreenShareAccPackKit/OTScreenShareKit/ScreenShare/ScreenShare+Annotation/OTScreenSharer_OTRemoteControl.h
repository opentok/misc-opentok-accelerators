//
//  OTScreenSharer_OTRemoteControl.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <OTScreenShareKit/OTScreenShareKit.h>

@interface OTScreenSharer ()

@property (nonatomic) OTRemoteAnnotator *remoteAnnotator;

- (void)initializeRemoteAnnotator;

@end
