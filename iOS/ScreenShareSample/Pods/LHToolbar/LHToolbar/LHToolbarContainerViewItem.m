//
//  LHToolbarContainerViewItem.m
//  Pods
//
//  Created by Xi Huang on 5/15/16.
//
//

#import "LHToolbarContainerViewItem.h"

@interface LHToolbarContainerViewItem()
@property (nonatomic) NSLayoutConstraint *top;
@property (nonatomic) NSLayoutConstraint *bottom;
@property (nonatomic) NSLayoutConstraint *widthConstraint;
@property (nonatomic) NSLayoutConstraint *leading;
@property (nonatomic) CGFloat percentageOfScreenWidth;
@end

@implementation LHToolbarContainerViewItem

- (NSLayoutConstraint *)top {
    if (!_top) {
        _top = [NSLayoutConstraint constraintWithItem:self
                                            attribute:NSLayoutAttributeTop
                                            relatedBy:NSLayoutRelationEqual
                                               toItem:self.superview
                                            attribute:NSLayoutAttributeTop
                                           multiplier:1.0
                                             constant:0.0];
    }
    return _top;
}

- (NSLayoutConstraint *)bottom {
    if (!_bottom) {
        _bottom = [NSLayoutConstraint constraintWithItem:self
                                               attribute:NSLayoutAttributeBottom
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:self.superview
                                               attribute:NSLayoutAttributeBottom
                                              multiplier:1.0
                                                constant:0.0];
    }
    return _bottom;
}

- (NSLayoutConstraint *)widthConstraint {
    if (!_widthConstraint) {
        if (self.percentageOfScreenWidth <= 0) return nil;
        _widthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.superview
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:self.percentageOfScreenWidth
                                                         constant:0.0];
    }
    return _widthConstraint;
}

- (instancetype)initWithPercentageOfScreenWidth:(CGFloat)percentageOfScreenWidth {
    if (percentageOfScreenWidth <= 0) return nil;
    
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        _percentageOfScreenWidth = percentageOfScreenWidth;
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if (!self.superview) return;
    
    self.top.active = YES;
    self.bottom.active = YES;
    self.widthConstraint.active = YES;
    [self setLeadingPadding:0.0f];
}

- (void)setTopPadding:(CGFloat)padding {
    if (padding < 0 || 1 < padding) return;
    self.top.constant = padding;
}

- (void)setBottomPadding:(CGFloat)padding {
    if (padding < 0 || 1 < padding) return;
    self.bottom.constant = padding;
}

- (void)setLeadingPadding:(CGFloat)padding {
    if (!self.superview) return;
    if (padding < 0 || 1 < padding) return;
    
    if (self.leading.active) {
        self.leading.active = NO;
    }
    self.leading = nil;
    
    if (self.superview.subviews.count == 1) {
        self.leading = [NSLayoutConstraint constraintWithItem:self
                                                    attribute:NSLayoutAttributeLeading
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.superview
                                                    attribute:NSLayoutAttributeLeading
                                                   multiplier:1.0
                                                     constant:padding];
    }
    else {
        NSInteger count = self.superview.subviews.count;
        self.leading = [NSLayoutConstraint constraintWithItem:self
                                                    attribute:NSLayoutAttributeLeading
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.superview.subviews[count - 2]
                                                    attribute:NSLayoutAttributeTrailing
                                                   multiplier:1.0
                                                     constant:padding];
    }
    self.leading.active = YES;
}

@end
