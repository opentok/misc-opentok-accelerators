![logo](../tokbox-logo.png)

# OpenTok Annotations Accelerator Pack for iOS<br/>Version 1.1

This document describes how to use the OpenTok Annotations Accelerator Pack for iOS.

## Add the library

To get up and running quickly with your development, go through the following steps using CocoaPods:

1. Add the following line to your pod file: ` pod 'OTAnnotationKit'  `
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

The following classes represent the software design for the OpenTok Annotations Accelerator Pack.

| Class        | Description  |
| ------------- | ------------- |
| `OTAnnotator` | The core component for enabling remote annotation across devices and platforms. |  
| `OTAnnotationScrollView` | Provides essentials components for annotating on either the entire screen or a specified portion of the screen. |
| `OTAnnotationToolbarView`   | A convenient annotation toolbar that is optionally available for your development. As an alternative, you can create your own toolbar using `OTAnnotationScrollView`. |
| `OTFullScreenAnnotationViewController`   | A convenient view controller enables you to annotate the whole screen immediately. |


### Annotation features

The `OTAnnotationScrollView` class is the backbone of the annotation features in this Sample.


```objc
self.annotationView = [[OTAnnotationScrollView alloc] init];
self.annotationView.frame = <# desired frame #>;
[self.annotationView initializeToolbarView];
self.annotationView.toolbarView.frame = <# desired frame #>;
```

If you would like to be annotated on either the entire screen or a specified portion of the screen:
```objc
self.annotator = [[OTAnnotator alloc] init];
[self.annotator connectForReceivingAnnotationWithSize:<# desired size #>
                                    completionHandler:^(OTAnnotationSignal signal, NSError *error) {
                                        if (signal == OTAnnotationSessionDidConnect){
                                            self.annotator.annotationScrollView.frame = self.view.bounds;
                                            [self.view addSubview:self.annotator.annotationScrollView];
                                        }
                                    }];

self.annotator.dataReceivingHandler = ^(NSArray *data) {
    NSLog(@"%@", data);
};
```

If you would like to annotate on a remote client's screen:
```objc
self.annotator = [[OTAnnotator alloc] init];
[self.annotator connectForSendingAnnotationWithSize:self.sharer.subscriberView.frame.size
                                completionHandler:^(OTAnnotationSignal signal, NSError *error) {
    
                                    if (signal == OTAnnotationSessionDidConnect){
        
                                        // configure annotation view
                                        self.annotator.annotationScrollView.frame = self.view.bounds;
                                        [self.view addSubview:self.annotator.annotationScrollView];

                                        // self.sharer.subscriberView is the screen shared from a remote client.
                                        // It does not make sense to `connectForSendingAnnotationWithSize` if you don't receive a screen sharing.
                                        [self.annotator.annotationScrollView addContentView:self.sharer.subscriberView];
        
                                        // configure annotation feature
                                        self.annotator.annotationScrollView.annotatable = YES;
                                        self.annotator.annotationScrollView.annotationView.currentAnnotatable = [OTAnnotationPath pathWithStrokeColor:[UIColor yellowColor]];
                                    }
                                }];

self.annotator.dataSendingHandler = ^(NSArray *data, NSError *error) {
    NSLog(@"%@", data);
};
```

## Requirements

To be prepared to develop with the Annotations Accelerator Pack for iOS:

1. Install Xcode version 5 or later, with ARC enabled.
2. Your device must be running iOS 8 or later.
