![logo](../tokbox-logo.png)

# OpenTok Text Chat Accelerator Pack for iOS<br/>Version 2.0.0

This document describes how to use the OpenTok Text Chat Accelerator Pack for iOS. 

## Add the library

To get up and running quickly with your development, go through the following steps using CocoaPods:

1. Add the following line to your pod file: ` pod 'OTTextChatKit'  `
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
| `OTTextChat`   | This component represents a OpenTok connection that is able to send/receive textual content. |
| `OTTextChatTableView`   | This class contains the basic configuration of the text chat layout.  |
| `OTTextChatViewController`   | This class is the backbone element to display text chat data and implement your custom UI. This is aimed to provide customization to developers.|

#### A simple way to use it

```objc
// The view controller is inherited from OTTextChatViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.textChat = [[OTTextChat alloc] init];
    self.textChat.alias = @"Tokboxer";
    self.textMessages = [[NSMutableArray alloc] init];
    
    self.textChatNavigationBar.topItem.title = self.textChat.alias;
    self.tableView.textChatTableViewDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.textChatInputView.textField.delegate = self;
    
    __weak DefaultTextChatTableViewController *weakSelf = self;
    [self.textChat connectWithHandler:^(OTTextChatViewEventSignal signal, OTTextMessage *message, NSError *error) {
        
        if (signal == OTTextChatViewEventSignalDidSendMessage || signal == OTTextChatViewEventSignalDidReceiveMessage) {
            
            if (!error) {
                [weakSelf.textMessages addObject:message];
                [weakSelf.tableView reloadData];
                weakSelf.textChatInputView.textField.text = nil;
                [weakSelf scrollTextChatTableViewToBottom];
            }
        }
    }];
}
```

#### Customization of cells
Please see `CustomTextChatTableViewController` and `OTTextChatTableViewDataSource` from the sample provided.
