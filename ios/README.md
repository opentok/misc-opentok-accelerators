![logo](../tokbox-logo.png)

# OpenTok Text Chat Accelerator Pack for iOS<br/>Version 1.0.0

This document describes how to use the OpenTok Text Chat Accelerator Pack for iOS. Through the exploration of the One to One Text Chat Sample Application, you will learn best practices for exchanging text messages on an iOS mobile device.

You can configure and run this sample app within just a few minutes!


This guide has the following sections:

* [Prerequisites](#prerequisites): A checklist of everything you need to get started.
* [Quick start](#quick-start): A step-by-step tutorial to help you quickly import and run the sample app.
* [Exploring the code](#exploring-the-code): This describes the sample app code design, which uses recommended best practices to implement the text chat features. 

## Prerequisites

To be prepared to develop your text chat app:

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
    [OTTextChatView setOpenTokApiKey:@""
                           sessionId:@""
                               token:@""];
    return YES;
}
   ```

_At this point you can try running the app! You can either use a simulator or an actual mobile device._


## Exploring the code

This section describes how the sample app code design uses recommended best practices to deploy the text chat communication features. The sample app design extends the [OpenTok One-to-One Communication Sample App](https://github.com/opentok/one-to-one-sample-apps/tree/master/one-to-one-sample-app/) and [OpenTok Common Accelerator Session Pack](https://github.com/opentok/acc-pack-common/) by adding logic using the classes in the `TextChatKit` framework.

For detail about the APIs used to develop this sample, see the [OpenTok iOS SDK Reference](https://tokbox.com/developer/sdks/ios/reference/).

  - [App design](#app-design)
  - [Text Chat view](#text-chat-view)

_**NOTE:** The sample app contains logic used for logging. This is used to submit anonymous usage data for internal TokBox purposes only. We request that you do not modify or remove any logging code in your use of this sample application._

### App design

The following classes, interfaces, and protocols represent the software design for this sample app, focusing primarily on the text chat features. For details about the one-to-one communication aspects of the design, see the [OpenTok One-to-One Communication Sample App](https://github.com/opentok/one-to-one-sample-apps/tree/master/one-to-one-sample-app/iOS).

| Class        | Description  |
| ------------- | ------------- |
| `MainViewController`   | In conjunction with **Main.storyboard**, this class uses the OpenTok API to initiate the client connection to the OpenTok session, and implements the sample UI and text chat callbacks.   |
| `TextChatView`   | Provides the initializers and methods for the client text chat UI views. |
| `TextChatViewDelegate`   | Delegate that monitors both receiving and sending activity. For example, a message is successfully sent, or a message is sent with a code in the event of an error. |


### Text Chat view

The `TextChatView` class is the backbone of the text chat features for the app. It serves as a controller for the text chat UI widget, and defines delegates for exchanging messages that are implemented in this example by the `MainViewController` class:

```objc
@interface OTTextChatView : UIView

+ (void)setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token;

@property (weak, nonatomic) id<TextChatViewDelegate> delegate;

@property (readonly, nonatomic, getter=isShown) BOOL show;

@property (readonly, nonatomic) OTTextChatUICustomizator *customizator;

+ (instancetype)textChatView;

+ (instancetype)textChatViewWithBottomView:(UIView *)bottomView;

- (void)connect;

- (void)connectWithHandler:(TextChatViewEventBlock)handler;

- (void)disconnect;

- (void)show;

- (void)dismiss;

- (void)setAlias:(NSString *)alias;

- (void)setMaximumTextMessageLength:(NSUInteger)length;

@end
```


#### Initialization methods

The following `TextChatView` methods are used to initialize the text chat features so the client can send and receive text messages.

| Feature        | Methods  |
| ------------- | ------------- |
| Initialize the text chat view. | `textChatView()`, `textChatViewWithBottomView()` |
| Set the maximum chat text length.   | `setMaximumTextMessageLength()`  |
| Set the sender alias and the sender ID of the outgoing messages.  | `setAlias()`  |


For example, the following method in `MainViewController` instantiates and initializes a `TextChatView` object, setting the maximum message length to 200 characters.

```objc
- (void)viewDidLoad {
    [super viewDidLoad];

    self.textChatView = [OTTextChatView textChatView];
    [self.textChatView setMaximumTextMessageLength:200];
    [self.textChatView setAlias:@“Tokboxer”];
}
```

#### Sending and receiving messages

By conforming to the `TextChatViewDelegate`, the `MainVewController` class defines methods that determine the UI responses to chat events. When a user clicks the send button, a `didAddMessageWithError` event is received.

In order to signal sending a message, you must first call the `connect` method. This allows you to begin using the `TextChatViewDelegate` protocol to receive notifications about messages being sent and received.

```objc
[self.textChatView connect];
```

Once you no longer need to exchange messages, call the `disconnect` method to leave the session.

The method implementations use the [OpenTok signaling API](https://tokbox.com/developer/sdks/ios/reference/Protocols/OTSessionDelegate.html#//api/name/session:receivedSignalType:fromConnection:withString:), which monitors the session connections to determine when individual chat messages are sent and received. 


```objc
@protocol TextChatViewDelegate <NSObject>
- (void)textChatViewDidSendMessage:(TextChatView *)textChatView
                             error:(NSError *)error;
- (void)textChatViewDidReceiveMessage:(TextChatView *)textChatView;

@optional
- (void)didConnectWithError:(NSError *)error;
- (void)didDisConnectWithError:(NSError *)error;
@end
```



