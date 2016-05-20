//
//  ShareView.h
//  ScreenShareSample
//
//  Created by Xi Huang on 5/20/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareModel : NSObject
@property (readonly, nonatomic) UIImage *sharedImage;
- (instancetype)initWithSharedImage:(UIImage *)sharedImage
                         sharedDate:(NSDate *)sharedDate;
@end

@interface ShareView : UIView
- (void)updateWithShareModel:(ShareModel *)shareModel;
@end
