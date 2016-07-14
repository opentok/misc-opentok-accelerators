![logo](../tokbox-logo.png)

# OpenTok Screensharing with Annotations Accelerator Pack for iOS<br/>Version 1.0

This document describes how to use the OpenTok Screensharing with Annotations Accelerator Pack for iOS. Through the exploration of the OpenTok Screensharing with Annotations Sample App, you will learn best practices for screensharing on an iOS mobile device.

You can configure and run this sample app within just a few minutes!


This guide has the following sections:

- [Prerequisites](#prerequisites): A checklist of everything you need to get started.
- [Quick start](#quick-start): A step-by-step tutorial to help you quickly import and run the sample app.
- [Exploring the code](#exploring-the-code): This describes the sample app code design, which uses recommended best practices to create a working implementation that uses the Screensharing with Annotations Accelerator. 

## Prerequisites

To be prepared to develop your screensharing with annotations app:

1. Install Xcode version 5 or later.
2. Review the [OpenTok iOS SDK Requirements](https://tokbox.com/developer/sdks/ios/).
3. Your app will need a **Session ID**, **Token**, and **API Key**, which you can get at the [OpenTok Developer Dashboard](https://dashboard.tokbox.com/).

_You do not need the OpenTok iOS SDK to use this sample._

_**NOTE**: The OpenTok Developer Dashboard allows you to quickly run this sample program. For production deployment, you must generate the **Session ID** and **Token** values using one of the [OpenTok Server SDKs](https://tokbox.com/developer/sdks/server/)._

## Quick start

To get up and running quickly with your app, go through the following steps in the tutorial provided below:

### Using CocoaPods

1. In a terminal prompt, navigate into your project directory and type `pod install`.
2. Reopen your project using the new *.xcworkspace file.

For more information about CocoaPods, including installation instructions, visit [CocoaPods Getting Started](https://guides.cocoapods.org/using/getting-started.html#getting-started).

### Configuring the app

Now you are ready to add the configuration detail to your app. These will include the **Session ID**, **Token**, and **API Key** you retrieved earlier (see [Prerequisites](#prerequisites)).

In **AppDelegate.h**, replace the following empty strings with the required detail:


```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	  // Override point for customization after application launch.    
    [OTScreenSharer setOpenTokApiKey:@""
                           sessionId:@""
                               token:@""];
  	return YES;
}
```

_At this point you can try running the app! You can either use a simulator or an actual mobile device._


## Exploring the code

This section describes how the sample app code design uses recommended best practices to deploy the screensharing with annotations features. The sample app design extends the [OpenTok One-to-One Communication Sample App](https://github.com/opentok/one-to-one-sample-apps/tree/master/one-to-one-sample-app/) and [OpenTok Common Accelerator Session Pack](https://github.com/opentok/acc-pack-common/) by adding logic using the classes in the `OTScreenShareKit` framework.

For detail about the APIs used to develop this sample, see the [OpenTok iOS SDK Reference](https://tokbox.com/developer/sdks/ios/reference/).

  - [App design](#app-design)
  - [Screensharing and annotation features](#screensharing-and-annotation-features)

_**NOTE:** The sample app contains logic used for logging. This is used to submit anonymous usage data for internal TokBox purposes only. We request that you do not modify or remove any logging code in your use of this sample application._

### App design

The following classes, interfaces, and protocols represent the software design for this sample app, focusing primarily on the screensharing with annotations features. For details about the one-to-one communication aspects of the design, see the [OpenTok One-to-One Communication Sample App](https://github.com/opentok/one-to-one-sample-apps).

| Class        | Description  |
| ------------- | ------------- |
| `MainViewController`   | In conjunction with **Main.storyboard**, this class uses the OpenTok API to initiate the client connection to the OpenTok session, and implements the sample UI and screensharing with annotations callbacks.   |
| `OTScreenSharer`   | This component enables the publisher to share either the entire screen or a specified portion of the screen. |
| `OTAnnotationScrollView` | Provides the initializers and methods for the client annotating views. |
| `OTAnnotationToolbarView`   | A convenient annotation toolbar that is optionally available for your development. As an alternative, you can create your own toolbar using `OTAnnotationScrollView`. See the [OpenTok Annotations Accelerator Pack](https://github.com/opentok/annotation-acc-pack) for more information. |
| `OTFullScreenAnnotationViewController`   | Combines both the scroll and annotation toolbar views. See the [OpenTok Annotations Accelerator Pack](https://github.com/opentok/annotation-acc-pack) for more information. |


### Screensharing and annotation features

The `OTScreenSharer` and `OTAnnotationScrollView` classes are the backbone of the screensharing and annotation features for the app.

```objc
@interface OTScreenSharer : NSObject

@property (readonly, nonatomic) BOOL isScreenSharing;

+ (instancetype)screenSharer;
+ (void) setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token;

- (void)connectWithView:(UIView *)view;
- (void)connectWithView:(UIView *)view
                handler:(ScreenShareBlock)handler;
- (void)disconnect;
```

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



#### Initialization methods

The following `OTScreenSharer` and `OTAnnotationScrollView` methods are used to initialize the screensharing with annotations features so the client can annotate their sharing screen.

| Feature        | Methods  |
| ------------- | ------------- |
| Initialize the annotation view  | `initWithFrame:` |
| Initialize the connection for screen sharing | `connectWithView:handler:` |


```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"mvc"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    self.screenShareView = [[OTAnnotationScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds))];
    [self.screenShareView addContentView:imageView];
    [self.view addSubview:self.screenShareView];
}

- (void)shareTheWholeScreen {
	[self.screenSharer connectWithView:[UIApplication sharedApplication].keyWindow.rootViewController.view handler:^(ScreenShareSignal signal, NSError *error) {
                
        if (!error) {
            // begin sharing screen
        }
        else {
            // error with screen sharing
        }
    }];
}
```
