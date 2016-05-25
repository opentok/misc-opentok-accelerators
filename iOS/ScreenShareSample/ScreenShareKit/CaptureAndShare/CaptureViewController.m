//
//  ShareViewController.m
//  ScreenShareSample
//
//  Created by Xi Huang on 5/19/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "CaptureViewController.h"
#import "CaptureView.h"

@interface CaptureViewController ()
@property (nonatomic) CaptureModel *captureModel;
@property (strong, nonatomic) CaptureView *captureView;
@property (nonatomic) UIActivityViewController *activityViewController;
@end

@implementation CaptureViewController

- (UIActivityViewController *)activityViewController {
    if (!_activityViewController) {
        _activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.captureModel.sharedImage] applicationActivities:nil];
    }
    return _activityViewController;
}

- (instancetype)initWithSharedImage:(UIImage *)sharedImage {
    
    if (!sharedImage) return nil;
    if (self = [super initWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:self.class]]) {
    
        _captureModel = [[CaptureModel alloc] initWithSharedImage:sharedImage sharedDate:[NSDate date]];
        
        self.providesPresentationContextTransitionStyle = YES;
        self.definesPresentationContext = YES;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.captureView = (CaptureView *)self.view;
    [self.captureView updateWithShareModel: self.captureModel];
}

- (IBAction)shareButtonPressed:(id)sender {
    [self presentViewController:self.activityViewController animated:YES completion:nil];
}

- (IBAction)saveButtonPressed:(id)sender {
    UIImageWriteToSavedPhotosAlbum(self.captureModel.sharedImage,
                                   self,
                                   @selector(finishSavingImage:error:contextInfo:),
                                   nil);
}

- (void)finishSavingImage:(UIImage *)savedImage
                    error:(NSError *)error
              contextInfo:(void *)contextInfo {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
