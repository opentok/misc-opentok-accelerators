![logo](../tokbox-logo.png)

# OpenTok Annotations Accelerator Pack for iOS<br/>Version 1.0

This document describes how to use the OpenTok Annotations Accelerator Pack for iOS. Through the exploration of this Accelerator Pack, you will learn best practices for development and customization with annotations on an iOS mobile device.

**Note**: The OpenTok Annotations Accelerator Pack does not include a standalone sample app such as [screensharing-annotation-acc-pack](https://github.com/opentok/screensharing-annotation-acc-pack), though you can easily build your own apps with it. It is also used as a component for more comprehensive Accelerator Packs that offer such features as screensharing and video along with annotations. 


This guide has the following sections:

* [Prerequisites](#prerequisites): A checklist of everything you need to get started.
* [Quick start](#quick-start): A step-by-step tutorial to help you quickly import and use the OpenTok Annotations Accelerator Pack for iOS.
* [Exploring the code](#exploring-the-code): This describes the Accelerator Pack code design, which uses recommended best practices to implement the annotation and frame grab capabilities available in the OpenTok client SDK.  


## Prerequisites

To be prepared to develop with the Annotations Accelerator Pack for Android:

1. Install Xcode version 5 or later.
2. Review the [OpenTok iOS SDK Requirements](https://tokbox.com/developer/sdks/ios/).
3. Your app will need a **Session ID**, **Token**, and **API Key**, which you can get at the [OpenTok Developer Dashboard](https://dashboard.tokbox.com/).


## Quick start

To get up and running quickly with your development, go through the following steps using CocoaPods:

1.  Add the following line to your pod file: ` pod ‘OTAnnotationKit’  `
2. In a terminal prompt, navigate into your project directory and type `pod install`.
3. Reopen your project using the new *.xcworkspace file.

For more information about CocoaPods, including installation instructions, visit [CocoaPods Getting Started](https://guides.cocoapods.org/using/getting-started.html#getting-started).


## Exploring the code

This section describes how the sample app code design uses recommended best practices to deploy the annotations features. 

For detail about the APIs used to develop this sample, see the [OpenTok iOS SDK Reference](https://tokbox.com/developer/sdks/ios/reference/).


### Class design

The following classes represent the software design for the OpenTok Annotations Accelerator Pack.

| Class        | Description  |
| ------------- | ------------- |
| `OTAnnotationScrollView` | Provides the initializers and methods for the client annotating views. |
| `OTAnnotationToolbarView`   | A convenient annotation toolbar that is optionally available for your development. As an alternative, you can create your own toolbar using `OTAnnotationScrollView`. |
| `OTFullScreenAnnotationViewController`   | Combines both the scroll and annotation toolbar views. |


### Annotation features

The `OTAnnotationScrollView` class is the backbone of the annotation features in this accelerator pack.


```objc
@interface OTAnnotationScrollView : UIView

@property (nonatomic, getter = isAnnotating) BOOL annotating;
@property (nonatomic, getter = isZoomEnabled) BOOL zoomEnabled;

- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
- (void)addContentView:(UIView *)view;  // this will enable scrolling if image is larger than actual device screen

@property (readonly, nonatomic) OTAnnotationToolbarView *toolbarView;
- (void)initializeToolbarView;

#pragma mark - annotation
- (void)startDrawing;
@property (nonatomic) UIColor *annotationColor;
- (void)addTextAnnotation:(OTAnnotationTextView *)annotationTextView;
- (UIImage *)captureScreen;
- (void)erase;
- (void)eraseAll;

@end
```


