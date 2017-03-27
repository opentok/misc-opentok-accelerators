![logo](../tokbox-logo.png)

# OpenTok Screensharing Accelerator Pack for Android<br/>Version 1.1

This document describes how to use the OpenTok Screensharing Accelerator Pack for Android. Through the exploration of the OpenTok Screensharing with Annotations Sample App, you will learn best practices for screensharing on an Android mobile device.


This guide has the following sections:

* [Prerequisites](#prerequisites): A checklist of everything you need to get started.
* [Quick start](#quick-start): A step-by-step tutorial to help you quickly import and run the sample app.
* [Exploring the code](#exploring-the-code): This describes the sample app code design, which uses recommended best practices to implement the screensharing with annotations features. 

## Prerequisites

To be prepared to develop your screensharing with annotations app:

1. Install [Android Studio](http://developer.android.com/intl/es/sdk/index.html).
2. Review the [OpenTok Android SDK Requirements](https://tokbox.com/developer/sdks/android/#developerandclientrequirements).
3. Your app will need a **Session ID**, **Token**, and **API Key**, which you can get at the [OpenTok Developer Dashboard](https://dashboard.tokbox.com/).

_**NOTE**: The OpenTok Developer Dashboard allows you to quickly run this sample program. For production deployment, you must generate the **Session ID** and **Token** values using one of the [OpenTok Server SDKs](https://tokbox.com/developer/sdks/server/)._


## Quick start

To get up and running quickly with your app, go through the following steps in the tutorial provided below:

### Importing the Sample App project

1. Clone the [OpenTok Screensharing with Annotations Sample App repository](https://github.com/opentok/one-to-one-screen-annotations-sample-apps)
2. Start Android Studio. 
3. In the **Quick Start** panel, click **Open an existing Android Studio Project**.
4. Navigate to the **android** folder, select the **SampleApp** folder, and click **Choose**.


<h3 id=addlibrary> Adding the OpenTok Screensharing Accelerator Pack library</h3>

There are 3 options for installing the OpenTok Screensharing with Annotations Accelerator Pack library:

  - [Using the repository](#using-the-repository)
  - [Using Maven](#using-maven)
  - [Downloading and Installing the AAR File](#downloading-and-installing-the-aar-file)

**NOTE**: 
  - The OpenTok Screensharing Sample App includes the [TokBox Common Accelerator Session Pack](https://github.com/opentok/acc-pack-common).
  - The OpenTok Screensharing Acc Pack includes the [OpenTok Annotations Kit] (https://github.com/opentok/annotation-acc-pack).

#### Using the repository

1. Clone the [OpenTok Screensharing Accelerator Pack repo](https://github.com/opentok/screen-sharing-acc-pack).
2. From the OpenTok Screensharing with Annotations Sample app project, right-click the app name and select **New > Module > Import Gradle Project**.
3. Navigate to the directory in which you cloned **OpenTok Screensharing with Annotations Accelerator Pack**, select **screensharing-acc-pack-kit**, and click **Finish**.
4. Open the **build.gradle** file for the app and ensure the following lines have been added to the `dependencies` section:
```
compile project(':screensharing-acc-pack-kit')
```

#### Using Maven

<ol>

<li>Modify the <b>build.gradle</b> for your solution and add the following code snippet to the section labeled 'repositories’:

<code>
maven { url  "http://tokbox.bintray.com/maven" }
</code>

</li>

<li>Modify the <b>build.gradle</b> for your activity and add the following code snippet to the section labeled 'dependencies’: 


<code>
compile 'com.opentok.android:opentok-screensharing-annotations:1.1.0'
</code>

</li>

</ol>

  _**NOTE**: Since dependencies are transitive with Maven, it is not necessary to explicitly reference the TokBox Common Accelerator Session Pack and the Annotations Kit with this option._


#### Downloading and Installing the AAR File

1.  Download the [Screensharing with Annotations Accelerator Pack zip file](https://s3.amazonaws.com/artifact.tokbox.com/solution/rel/screensharing-annotations-acc-pack/android/opentok-screensharing-annotations-1.1.0.zip) containing the AAR file and documentation, and extract the **opentok-screensharing-annotations-1.1.0.aar** file.
2.  Right-click the app name and select **Open Module Settings** and click **+**.
3.  Select **Import .JAR/.AAR Package** and click  **Next**.
4.  Browse to the **Screensharing with Annotations Accelerator Pack library AAR** and click **Finish**.


## Exploring the code

For detail about the APIs used to develop this accelerator pack, see the [OpenTok Android SDK Reference](https://tokbox.com/developer/sdks/android/reference/) and [Android API Reference](http://developer.android.com/reference/packages.html).

_**NOTE:** The accelerator pack contains logic used for logging. This is used to submit anonymous usage data for internal TokBox purposes only. We request that you do not modify or remove any logging code in your use of this accelerator pack._

### Class design

| Class        | Description  |
| ------------- | ------------- |
| `ScreenSharingFragment`   | Provides the initializers and methods to enable the publisher to share the screen |
| `ScreenSharingCapturer`   | Provides a custom VideoCapturer for sharing content displayed in the screensharing area, overriding the mobile device OS default to share content captured by the camera. |
| `ScreenPublisher`   | Defines a Publisher of PublisherKitVideoTypeScreen type to be used by the ScreenSharingFragment |
| `ScreenSharingBar`   | Initializes the screensharing bar and its UI controls. |

The `ScreenSharingFragment` class is the backbone of the screensharing features for the app. It uses the [`android.media.projection.MediaProjection`](http://developer.android.com/reference/android/media/projection/MediaProjection.html), supported on Android Lollipop, and provides the projection callbacks needed for screensharing.

This class, which inherits from the [`android.support.v4.app.Fragment`](http://developer.android.com/intl/es/reference/android/support/v4/app/Fragment.html) class, sets up the screensharing with annotations UI views and events, sets up session listeners, and defines a listener interface that is implemented in this example by the `MainActivity` class.

The `ScreenSharingListener` interface monitors state changes in the `ScreenSharingFragment`, and defines the following methods:

```java
public interface ScreenSharingListener {

    void onScreenSharingStarted();
    void onScreenSharingStopped();
    void onScreenSharingError(String error);
    void onAnnotationsViewReady(AnnotationsView view);
    void onClosed();

}
```

The following `ScreenSharingFragment` methods are used to manage the screensharing feature.

| Feature        | Methods  |
| ------------- | ------------- |
| Start screen capture.   | `start()`  |
| Stop screen capture.  | `stop()`  |
| Set the listener object to monitor state changes.   | `setListener()` |
| Sets whether annotations are enabled for the screensharing.  | `enableAnnotations()`  |


```java
ScreenSharingFragment mScreenSharingFragment = ScreenSharingFragment.newInstance(mComm.getSession(), OpenTokConfig.API_KEY);
mScreenSharingFragment.enableAnnotations(true, mAnnotationsToolbar);
mScreenSharingFragment.setListener(this);

mScreenSharingFragment.start();
      ...
mScreenSharingFragment.stop();
}
```

## Requirements

1. Install [Android Studio](http://developer.android.com/intl/es/sdk/index.html)
1. Review the [OpenTok Android SDK Requirements](https://tokbox.com/developer/sdks/android/#developerandclientrequirements)
1. OpenTok Screensharing Accelerator Pack requires Android Lollipop or later.







