//
//  Annotatable.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OTAnnotatable <NSObject>

@optional
- (void)commit;
@end
