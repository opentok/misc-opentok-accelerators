//
//  Annotatable.h
//
//  Copyright © 2016 Lucas Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OTAnnotatable <NSObject>
@optional
- (void)commit;
@end
