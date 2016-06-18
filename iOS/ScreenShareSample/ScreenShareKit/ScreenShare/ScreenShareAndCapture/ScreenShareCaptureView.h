//
//  ShareView.h
//  ScreenShareSample
//
//  Created by Xi Huang on 5/20/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CaptureModel : NSObject
@property (readonly, nonatomic) UIImage *sharedImage;
- (instancetype)initWithSharedImage:(UIImage *)sharedImage
                         sharedDate:(NSDate *)sharedDate;
@end

@interface ScreenShareCaptureView : UIView
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
- (void)updateWithShareModel:(CaptureModel *)shareModel;
- (void)enableSaveImageButton:(BOOL)enable;
@end
