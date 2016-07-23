//
//  Annotatable.h
//
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  The protocol that all drawable tools on OTAnnotationView conform.
 */
@protocol OTAnnotatable <NSObject>

@optional
- (void)commit;

@end
