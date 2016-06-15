# LHToolbar

[![Build Status](https://travis-ci.org/Lucashuang0802/LHToolbar.svg?branch=master)](https://travis-ci.org/Lucashuang0802/LHToolbar)
[![Version](https://img.shields.io/cocoapods/v/LHToolbar.svg?style=flat)](http://cocoapods.org/pods/LHToolbar)
[![License](https://img.shields.io/cocoapods/l/LHToolbar.svg?style=flat)](http://cocoapods.org/pods/LHToolbar)
[![codecov](https://codecov.io/gh/Lucashuang0802/LHToolbar/branch/master/graph/badge.svg)](https://codecov.io/gh/Lucashuang0802/LHToolbar)
[![Platform](https://img.shields.io/cocoapods/p/LHToolbar.svg?style=flat)](http://cocoapods.org/pods/LHToolbar)

## Description

LHToolbar is an alternative way to create a toolbar in iOS applications. Tool bars are widely used in iOS applications, however, UIToolbar class lacks of updates and flexibility, uncustomizable to some extent. It motivated me to create a container like toolbar so developers have more control and flexibility on layout and UIs. LHToolbar concentrates in providing fully functioning toolbar container, manipulation of container items and many more in the future.

## Features
* AutoLayout based toolbar container

## Upcoming Feature
* Vertical AutoLayout based toolbar container
* Support of scrollable content
* Support different size of content view item

## An example to use
````objc
// initialize tool bar
LHToolbar *toolbar = [[LHToolbar alloc] initWithNumberOfItems:9];
toolbar.backgroundColor = [UIColor lightGrayColor];
CGRect mainScreenBounds = [UIScreen mainScreen].bounds;
CGFloat offset = 50.0f;
toolbar.frame = CGRectMake(offset / 2, CGRectGetHeight(mainScreenBounds) - toolbarHeight - colorToolbarHeight, CGRectGetWidth(mainScreenBounds) - offset, colorToolbarHeight);
[self.view addSubview:toolbar];

// add color picker buttons
NSDictionary *colorDict = @{
    @1: [UIColor colorWithRed:68.0/255.0f green:140.0/255.0f blue:230.0/255.0f alpha:1.0],
	@2: [UIColor colorWithRed:179.0/255.0f green:0/255.0f blue:223.0/255.0f alpha:1.0],
	@3: [UIColor redColor],
	@4: [UIColor colorWithRed:245.0/255.0f green:152.0/255.0f blue:0/255.0f alpha:1.0],
	@5: [UIColor colorWithRed:247.0/255.0f green:234.0/255.0f blue:0/255.0f alpha:1.0],
	@6: [UIColor colorWithRed:101.0/255.0f green:210.0/255.0f blue:0.0/255.0f alpha:1.0],
    @7: [UIColor blackColor],
    @8: [UIColor grayColor],
    @9: [UIColor whiteColor]
};
for (NSInteger i = 1; i < 10; i++) {
    UIButton *button = [[UIButton alloc] init];
    [button setBackgroundColor:colorDict[@(i)]];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(gap, gap, (CGRectGetWidth(mainScreenBounds) - offset) / 9.0 - gap * 2, colorToolbarHeight - gap * 2)];
    [button.layer setCornerRadius:colorToolbarHeight / 2.0f];
    [toolbar setContentView:button atIndex:i -  1];
}

// reload tool bar
[toolbar reloadToolbar];
````

## Requirements
* iOS 8.0+
* ARC

## Installation

LHToolbar is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "LHToolbar"
```

## Author

Lucas Huang, xhuang0802@gmail.com

## Contributing

Please follow these sweet [contribution guidelines](https://github.com/Lucashuang0802/LHToolbar/blob/master/.github/CONTRIBUTING.md).

## License

LHToolbar is available under the MIT license. See the LICENSE file for more info.
