//
//  ScreenCapture.h
//  ScreenCapture
//
//  Created by Esteban Cordero on 3/7/16.
//  Copyright © 2016 Esteban Cordero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 * Periodically sends video frames to an OpenTok Publisher by rendering the
 * CALayer for a UIView.
 */
@interface ScreenCapture : NSObject

/**
 * Initializes a video capturer that will grab rendered stills of the view.
 */
- (instancetype)initWithView:(UIView*)view;

/**
 * Create - Use shared session from Accelerator pack.
 */
+ (void)setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token;

/**
 * returns the publisher to be able to add it to the subview that correspond
 */

- (id)connectPublisher;

/**
 * Allocate capture resources; in this case we're just setting up a timer and
 * block to execute periodically to send video frames.
 */
- (void)startCapture;

/**
 * stops screenshare and release the resouces 
 */
- (void)stopCapture;

@end
