//
//  ShareViewController.m
//  ScreenShareSample
//
//  Created by Xi Huang on 5/19/16.
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import "ShareViewController.h"
#import "ShareView.h"

@interface ShareViewController ()
@property (nonatomic) ShareModel *shareModel;
@property (strong, nonatomic) IBOutlet ShareView *shareView;
@property (nonatomic) UIActivityViewController *activityViewController;
@end

@implementation ShareViewController

- (UIActivityViewController *)activityViewController {
    if (!_activityViewController) {
        _activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.shareModel.sharedImage] applicationActivities:nil];
    }
    return _activityViewController;
}

- (instancetype)initWithSharedImage:(UIImage *)sharedImage {
    
    if (!sharedImage) return nil;
    if (self = [super initWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:self.class]]) {
    
        _shareModel = [[ShareModel alloc] initWithSharedImage:sharedImage sharedDate:[NSDate date]];
        
        self.providesPresentationContextTransitionStyle = YES;
        self.definesPresentationContext = YES;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.shareView = (ShareView *)self.view;
    [self.shareView updateWithShareModel: self.shareModel];
}

- (IBAction)shareButtonPressed:(id)sender {
    [self presentViewController:self.activityViewController animated:YES completion:nil];
}

- (IBAction)saveButtonPressed:(id)sender {
    UIImageWriteToSavedPhotosAlbum(self.shareModel.sharedImage,
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
