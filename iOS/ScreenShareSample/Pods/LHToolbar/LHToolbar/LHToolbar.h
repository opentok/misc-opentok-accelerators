//
//  LHToolbar.h
//  Pods
//
//  Created by Xi Huang on 5/15/16.
//
//

#import <UIKit/UIKit.h>

@interface LHToolbar : UIView

@property (readonly, nonatomic) NSInteger numberOfItems;

- (instancetype)initWithNumberOfItems:(NSInteger)numberOfItems;

- (void)reloadToolbar;

- (void)reloadToolbarAtIndex:(NSInteger)index;

- (void)setContentView:(UIView *)contentView
               atIndex:(NSInteger)index;

- (UIView *)contentViewAtIndex:(NSInteger)index;

- (NSInteger)indexOfContentView:(UIView *)contentView;

- (BOOL)containedContentView:(UIView *)contentView;

- (void)addContentView:(UIView *)contentView;

- (void)insertContentView:(UIView *)contentView
                  atIndex:(NSInteger)index;

- (void)removeLastContentView;

- (void)removeContentViewAtIndex:(NSInteger)index;

@end
