![logo](../tokbox-logo.png)

# OpenTok Screensharing with Annotations Accelerator Pack for iOS<br/>Version 1.0

This document describes how to use the OpenTok Screensharing with Annotations Accelerator Pack for iOS. Through the exploration of the OpenTok Screensharing with Annotations Sample App, you will learn best practices for screensharing on an iOS mobile device.

You can configure and run this sample app within just a few minutes!


This guide has the following sections:

- [Prerequisites](#prerequisites): A checklist of everything you need to get started.
- Download the accelerator pack: Download and use the OpenTok Screensharing with Annotations Accelerator Pack provided to you by TokBox for use in your own development.
- [Quick start](#quick-start): A step-by-step tutorial to help you quickly import and run the sample app.
- [Exploring the code](#exploring-the-code): This describes the sample app code design, which uses recommended best practices to create a working implementation that uses the Screensharing with Annotations Accelerator. 

## Prerequisites

To be prepared to develop your screensharing with annotations app:

1. Install Xcode version 5 or later.
2. Download the [TokBox Common Accelerator Session Pack](https://github.com/opentok/acc-pack-common).
3. Download the **Screensharing with Annotations Accelerator Pack framework** provided by TokBox.
4. Review the [OpenTok iOS SDK Requirements](https://tokbox.com/developer/sdks/ios/).
5. Your app will need a **Session ID**, **Token**, and **API Key**, which you can get at the [OpenTok Developer Dashboard](https://dashboard.tokbox.com/).

_You do not need the OpenTok iOS SDK to use this sample._

_**NOTE**: The OpenTok Developer Dashboard allows you to quickly run this sample program. For production deployment, you must generate the **Session ID** and **Token** values using one of the [OpenTok Server SDKs](https://tokbox.com/developer/sdks/server/)._

## Quick start

To get up and running quickly with your app, go through the following steps in the tutorial provided below:

1. [Importing the Xcode Project](#importing-the-xcode-project)
2. [Adding the required frameworks](#adding-the-required-frameworks)
3. [Configuring the app](#configuring-the-app)

To learn more about the best practices used to design this app, see [Exploring the code](#exploring-the-code).

### Importing the Xcode project

1. Clone the OpenTok Screensharing with Annotations Accelerator Pack repository.
2. Start Xcode. 
3. Click **File > Open**.
4. Navigate to the **iOS** folder, select **ScreenShareSample.xcodeproj**, and click **Open**.


### Adding the required frameworks

1. Copy the **ScreenShareKit.framework** into your project folder. 
2. From the **Project Navigator** view, select each and ensure **Target Membership** is checked in the **File Inspector**.
3. From the **Project Navigator** view, click **General**. Ensure that ** ScreenShareKit.framework** has been added to **Embedded Binaries**.



### Configuring the app

Now you are ready to add the configuration detail to your app. These will include the **Session ID**, **Token**, and **API Key** you retrieved earlier (see [Prerequisites](#prerequisites)).

In **AppDelegate.h**, replace the following empty strings with the required detail:


```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	// Override point for customization after application launch.    
    [OneToOneCommunicator setOpenTokApiKey:@""
                                 sessionId:@""
                                     token:@""
                            selfSubscribed:NO];
  	return YES;
}
```


You may also set the `selfSubscribed` constant. Its default value, `NO`, means that the app subscribes automatically to the other client’s stream. This is required to establish communication between two streams using the same Session ID.

_At this point you can try running the app! You can either use a simulator or an actual mobile device._


## Exploring the code

This section describes how the sample app code design uses recommended best practices to deploy the screensharing with annotations features. The sample app design extends the [OpenTok One-to-One Communication Sample App](https://github.com/opentok/one-to-one-sample-apps) by adding logic using the classes in the `ScreenShareKit` framework.

For detail about the APIs used to develop this sample, see the [OpenTok iOS SDK Reference](https://tokbox.com/developer/sdks/ios/reference/).

  - [App design](#app-design)
  - [Screenshare view](#screenshare-view)
  - [User interface](#user-interface)

_**NOTE:** The sample app contains logic used for logging. This is used to submit anonymous usage data for internal TokBox purposes only. We request that you do not modify or remove any logging code in your use of this sample application._

### App design

The following classes, interfaces, and protocols represent the software design for this sample app, focusing primarily on the screensharing with annotations features. For details about the one-to-one communication aspects of the design, see the [OpenTok One-to-One Communication Sample App](https://github.com/opentok/one-to-one-sample-apps).

| Class        | Description  |
| ------------- | ------------- |
| `MainViewController`   | In conjunction with **Main.storyboard**, this class uses the OpenTok API to initiate the client connection to the OpenTok session, and implements the sample UI and screensharing with annotations callbacks.   |
| `ScreenSharer`   | Provides support for OpenTok event signaling that notifies the main controller of all session, publisher, and subscriber events, as well as a `connectWithView()` method that passes the portion of the screen to be shared between the publisher and subscriber. |
| `ScreenShareView`   | Provides the initializers and methods for the client screensharing views. |
| `ScreenShareToolbarView`   | Provides the initializers and methods for the annotation toolbar view. |
| `ScreenShareTextField`   | Provides the initializers and methods for the client screensharing text field annotation views. |
| `ScreenShareColorPickerView`   | Provides the initializers and methods for the client screensharing color picker annotation views. |
| `Annotatable`   | Protocol to which all annotation elements must conform. This is a required protocol when developing custom annotations.|



### Screenshare view

The `ScreenShareView` class is the backbone of the screensharing features for the app. It serves as a controller for the screensharing UI widget, and initializes such functionality as text annotations, screen capture button, erase button that removes the last annotation that was added, color selector for drawing stroke and text annotations, and scrolling features. Its `addContentView()` method allows the user to share content such as images and files:

```objc
@interface ScreenShareView : UIView

+ (instancetype)view;

- (void)addContentView:(UIView *)view;

@property (nonatomic, getter = isAnnotating) BOOL annotating;

- (void)addTextAnnotation:(AnnotationTextView *)annotationTextView;

- (void)selectColor:(UIColor *)selectedColor;

- (UIImage *)captureScreen;

- (void)erase;

@end
```


#### Initialization methods

The following `ScreenShareView` methods are used to initialize the screensharing with annotations features so the client can share their screen.

| Feature        | Methods  |
| ------------- | ------------- |
| Initialize the stroke color for the screensharing view. | `viewWithStrokeColor()` |


For example, the following method in `ViewController` instantiates and initializes a `ScreenShareView` object, setting its image subview.

```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // ScreenShareView example
    UIImage *image = [UIImage imageNamed:@"mvc"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    [self.shareView addSubview:imageView];
}
```



### User interface

As described in [App design](#app-design), the `ScreenShareView` class sets up and manages the UI views and rendering for the client sharing views, and the `ScreenShareTextField` and `ScreenShareColorPickerView` classes set up the views for the text field and color picker annotation features.


These properties of the `ViewController` class manage the views as the publisher and subscriber participate in the session.

| Property        | Description  |
| ------------- | ------------- |
| `viewDidLoad` | UI view for the screenshare view  |


It is recommended that you use a toolbar height of 44 points, and a width identical to the screen width. Refer to the `ScreenShareToolbarView` class for more information.








