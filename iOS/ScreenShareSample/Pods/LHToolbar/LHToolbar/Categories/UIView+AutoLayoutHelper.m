//
//  UIView+AutoLayoutHelper.m
//  Pods
//
//  Created by Xi Huang on 5/15/16.
//
//

#import "UIView+AutoLayoutHelper.h"

@implementation UIView (AutoLayoutHelper)

- (void)addAttachedLayoutConstraintsToSuperview {
    
    if (!self.superview) {
        NSLog(@"Could not addAttachedLayoutConstantsToSuperview, superview is nil");
        return;
    }
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.superview
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:0.0];
    top.identifier = [NSString stringWithFormat:@"%@-top", NSStringFromClass([self class])];
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:self
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.superview
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1.0
                                                                constant:0.0];
    leading.identifier = [NSString stringWithFormat:@"%@-leading", NSStringFromClass([self class])];
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:self
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.superview
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1.0
                                                                 constant:0.0];
    trailing.identifier = [NSString stringWithFormat:@"%@-trailing", NSStringFromClass([self class])];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.superview
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0.0];
    bottom.identifier = [NSString stringWithFormat:@"%@-bottom", NSStringFromClass([self class])];
    [NSLayoutConstraint activateConstraints:@[top, leading, trailing, bottom]];
}


@end
