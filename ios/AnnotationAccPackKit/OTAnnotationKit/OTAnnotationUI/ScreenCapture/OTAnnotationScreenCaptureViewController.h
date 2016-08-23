//
//  OTAnnotationScreenCaptureViewController.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTAnnotationScreenCaptureViewController : UIViewController

@property (nonatomic) UIImage *sharedImage;
- (instancetype)initWithSharedImage:(UIImage *)sharedImage;

@end
