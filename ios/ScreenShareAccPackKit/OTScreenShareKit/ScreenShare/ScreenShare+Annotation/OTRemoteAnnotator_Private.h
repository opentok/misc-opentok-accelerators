//
//  OTRemoteAnnotator_Private.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <OTAnnotationKit/OTAnnotationView.h>
@class OTScreenSharer;

@interface OTRemoteAnnotator ()

@property (nonatomic) OTAnnotationView *annotationView;
@property (weak, nonatomic) OTScreenSharer *screenSharer;

@end
