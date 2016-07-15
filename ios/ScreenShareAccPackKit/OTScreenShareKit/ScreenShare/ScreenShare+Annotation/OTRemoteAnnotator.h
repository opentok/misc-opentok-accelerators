//
//  OTRemoteAnnotator.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTRemoteAnnotator : NSObject

@property (nonatomic,getter=isReceiveEnabled) BOOL receiveEnabled;

@property (nonatomic,getter=isSignalEnabled) BOOL signalEnabled;

@end
