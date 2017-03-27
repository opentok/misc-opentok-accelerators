![logo](../tokbox-logo.png)

# OpenTok Screensharing Accelerator Pack for iOS<br/>Version 1.1

This document describes how to use the OpenTok Screensharing Accelerator Pack for iOS.

## Add the library

To get up and running quickly with your development, go through the following steps using CocoaPods:

1. Add the following line to your pod file: ` pod 'OTScreenShareKit'  `
2. In a terminal prompt, navigate into your project directory and type `pod install`.
3. Reopen your project using the new `*.xcworkspace` file.

For more information about CocoaPods, including installation instructions, visit [CocoaPods Getting Started](https://guides.cocoapods.org/using/getting-started.html#getting-started).

### Configure and build the app

Configure the sample app code. Then, build and run the app.

1. Get values for **API Key**, **Session ID**, and **Token**. See [OpenTok One-to-One Communication Sample App home page](../README.md) for important information.

1. In XCode, open **AppDelegate.h** and add [OTAcceleratorPackUtil](https://cocoapods.org/pods/OTAcceleratorPackUtil) by `#import <OTAcceleratorPackUtil/OTAcceleratorPackUtil.h>`

1. Replace the following empty strings with the corresponding **API Key**, **Session ID**, and **Token** values:

    ```objc
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

        // Override point for customization after application launch.    
        [OTAcceleratorSession setOpenTokApiKey:@""
                                     sessionId:@""
                                         token:@""];
        return YES;
    }
    ```

1. Use Xcode to build and run the app on an iOS simulator or a device.

## Exploring the code

For detail about the APIs used to develop this accelerator pack, see the [OpenTok iOS SDK Reference](https://tokbox.com/developer/sdks/ios/reference/).

_**NOTE:** This accelerator pack collects anonymous usage data for internal TokBox purposes only. Please do not modify or remove any logging code from this sample application._

### Class design

| Class        | Description  |
| ------------- | ------------- |
| `OTScreenSharer`   | This component enables the publisher to share either the entire screen or a specified portion of the screen. |
| `OTScreenCapture` | The core component to publish from a UIView, instead of a camera, as the video source. |

### Screensharing feature

```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenSharer = [OTScreenSharer sharedInstance];
    [self.screenSharer connectWithView:[UIApplication sharedApplication].keyWindow.rootViewController.view
                               handler:^(OTScreenShareSignal signal, NSError *error) {
        
                               }];
}
```

If you only want to receive screen sharing, you can do the following:
```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenSharer = [OTScreenSharer sharedInstance];
    [self.screenSharer connectWithView:nil
                         handler:^(OTScreenShareSignal signal, NSError *error) {
                             
                         }];
}
```

## Requirements

To develop your one-to-one communication app:

1. Install Xcode version 5 or later.
2. Review the [OpenTok iOS SDK Requirements](https://tokbox.com/developer/sdks/ios/).
