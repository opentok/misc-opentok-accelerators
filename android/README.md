![logo](../tokbox-logo.png)

# OpenTok Screensharing with Annotations Accelerator Pack for Android<br/>Version 1.0

This document describes how to use the OpenTok Screensharing with Annotations Accelerator Pack for Android. Through the exploration of the OpenTok Screensharing with Annotations Sample App, you will learn best practices for exchanging text messages on an Android mobile device.

You can configure and run this sample app within just a few minutes!


This guide has the following sections:

* [Prerequisites](#prerequisites): A checklist of everything you need to get started.
* [Quick start](#quick-start): A step-by-step tutorial to help you quickly import and run the sample app.
* [Exploring the code](#exploring-the-code): This describes the sample app code design, which uses recommended best practices to implement the screensharing with annotations features. 

## Prerequisites

To be prepared to develop your screensharing with annotations app:

1. Install [Android Studio](http://developer.android.com/intl/es/sdk/index.html). **Note**: the Screensharing with Annotations component requires Android Lollipop.
2. Download the TokBox Common Accelerator Session Pack provided by TokBox.
3. Download the **Screensharing with Annotations Accelerator Pack AAR** file provided by TokBox.
4. Review the [OpenTok Android SDK Requirements](https://tokbox.com/developer/sdks/android/#developerandclientrequirements).
5. Your app will need a **Session ID**, **Token**, and **API Key**, which you can get at the [OpenTok Developer Dashboard](https://dashboard.tokbox.com/).

_**NOTE**: The OpenTok Developer Dashboard allows you to quickly run this sample program. For production deployment, you must generate the **Session ID** and **Token** values using one of the [OpenTok Server SDKs](https://tokbox.com/developer/sdks/server/)._

## Quick start

To get up and running quickly with your app, go through the following steps in the tutorial provided below:

1. [Importing the Android Studio Project](#importing-the-android-studio-project)
2. [Adding the TokBox Common Accelerator Session Pack](#addaccpackcommon)
3. [Adding the OpenTok Screensharing Accelerator Pack library](#addlibrary)
4. [Configuring the app](#configuring-the-app)

To learn more about the best practices used to design this app, see [Exploring the code](#exploring-the-code).

### Importing the Android Studio project

1. Clone the OpenTok Screensharing with Annotations Sample App repository.
2. Start Android Studio. 
3. In the **Quick Start** panel, click **Open an existing Android Studio Project**.
4. Navigate to the **android** folder, select the **TextChatSample** folder, and click **Choose**.

<h3 id=addaccpackcommon>Adding the TokBox Common Accelerator Session Pack</h3>

You can add the TokBox Common Accelerator Session Pack either by using the repository or using Maven.

#### Using the repository

1. Right-click the app name and select **New > Module > Import Gradle Project**.
2. Navigate to the directory in which you cloned **TokBox Common Accelerator Session Pack**, select **android-acc-pack**, and click **Finish**.
3. Open the **build.gradle** file for the app and ensure the following lines have been added to the `dependencies` section:
```
compile project(':opentok-android-accelerator-pack-1.0')
```

#### Using Maven

<ol>

<li>Modify the **build.gradle** for your solution and add the following code snippet to the section labeled 'repositories’:

<code>
maven { url  "http://tokbox.bintray.com/maven" }
</code>

</li>

<li>Modify the **build.gradle** for your activity and add the following code snippet to the section labeled 'dependencies’: 


<code>
compile 'com.opentok.android:opentok-android-accelerator-pack:1.0’<br/>
compile project(':screensharing-acc-pack')
</code>

</li>

</ol>


<h3 id=addlibrary> Adding the OpenTok Screensharing Accelerator Pack library</h3>
1.  Right-click the app name and select **Open Module Settings** and click **+**.
2.  Select **Import .JAR/.AAR Package** and click  **Next**.
3.  Browse to the **Screensharing with Annotations Accelerator Pack library AAR** and click **Finish**.



### Configuring the app

Now you are ready to add the configuration detail to your app. These will include the **Session ID**, **Token**, and **API Key** you retrieved earlier (see [Prerequisites](#prerequisites)).

In **OpenTokConfig.java**, replace the following empty strings with the required detail:


```java
// Replace with a generated Session ID
public static final String SESSION_ID = "";

// Replace with a generated token
public static final String TOKEN = "";

// Replace with your OpenTok API key
public static final String API_KEY = "";
```


You may also set the `SUBSCRIBE_TO_SELF` constant. Its default value, `false`, means that the app subscribes automatically to the other client’s stream. This is required to establish communication between two streams using the same Session ID:

```java
public static final boolean SUBSCRIBE_TO_SELF = false;
```

_At this point you can try running the app! You can either use a simulator or an actual mobile device._


## Exploring the code

This section describes how the sample app code design uses recommended best practices to deploy the screensharing with annotations features. The sample app design extends the [OpenTok One-to-One Communication Sample App](../../one-to-one-sample-app) by adding logic using the `com.tokbox.android.accpack.screensharing` classes.

For detail about the APIs used to develop this sample, see the [OpenTok Android SDK Reference](https://tokbox.com/developer/sdks/android/reference/) and [Android API Reference](http://developer.android.com/reference/packages.html).

  - [Class design](#class-design)
  - [Screensharing Accelerator Pack](#screensharing-accelerator-pack)
  - [User interface](#user-interface)

_**NOTE:** The sample app contains logic used for logging. This is used to submit anonymous usage data for internal TokBox purposes only. We request that you do not modify or remove any logging code in your use of this sample application._

### Class design

The following classes represent the software design for this sample app, focusing primarily on the screensharing with annotations features. For details about the one-to-one communication aspects of the design, see the [OpenTok One-to-One Communication Sample App](../../one-to-one-sample-app).

| Class        | Description  |
| ------------- | ------------- |
| `MainActivity`    | Implements the sample app UI and screensharing with annotations callbacks. |
| `OpenTokConfig`   | Stores the information required to configure the session and connect to the cloud.   |
| `ScreenSharingFragment`   | Provides the initializers and methods for the client screensharing views. **Note**: this class requires Android Lollipop. |
| `ScreenSharingCapturer`   | . |
| `ChatMessage`   | A data model describing information used in individual screensharing with annotations messages. |


###  Screensharing Accelerator Pack

The `ScreenSharingFragment` class is the backbone of the screensharing features for the app. It serves as a controller for the screensharing UI widget, and initializes such functionality as stroke color and scrolling features. It uses the [`android.media.projection.MediaProjection`](http://developer.android.com/reference/android/media/projection/MediaProjection.html), supported on Android Lollipop, and provides the projection callbacks needed for screensharing.

This class, which inherits from the [`android.support.v4.app.Fragment`](http://developer.android.com/intl/es/reference/android/support/v4/app/Fragment.html) class, sets up the screensharing with annotations UI views and events, sets up session listeners, and defines a listener interface that is implemented in this example by the `MainActivity` class.

```java
public class ScreenSharingFragment extends Fragment implements AccPackSession.SessionListener {

    . . .

}
```

The `ScreenSharingListener` interface monitors state changes in the `ScreenSharingFragment`, and defines the following methods:

```java
public interface ScreenSharingListener {

    void onScreenSharingStarted();
    void onScreenSharingStopped();
    void onScreenSharingError(String error);
    void onClosed();

}
```


#### Initialization methods

The following `ScreenSharingFragment` methods are used to initialize the app and provide basic information determining the behavior of the screensharing with annotations functionality.

| Feature        | Methods  |
| ------------- | ------------- |
| Start screen capture.   | `start()`  |
| Stop screen capture.  | `stop()`  |
| Set the listener object to monitor state changes.   | `setListener()` |


For example, the following private method instantiates a `ScreenSharingFragment` object:

```java
    private void initScreenSharingFragment(){
        mScreenSharingFragment = ScreenSharingFragment.newInstance(
           mComm.getSession(), 
           OpenTokConfig.API_KEY
        );

        getSupportFragmentManager().beginTransaction().add(
           R.id.screensharing_fragment_container, 
           mScreenSharingFragment
        ).commit();
    }
```





### User interface

As described in [Class design](#class-design), the `ScreenSharingFragment` class sets up and manages the UI views, events, and rendering for the screensharing with annotations controls.

This class works with the following `MainActivity` methods, which manage the views as both clients participate in the session.

| Feature        | Methods  |
| ------------- | ------------- |
| Manage the UI containers. | `onCreate()`  |
| Reload the UI views whenever the device [configuration](http://developer.android.com/reference/android/content/res/Configuration.html), such as screen size or orientation, changes. | `onConfigurationChanged()`  |
| Opens and closes the screensharing with annotations view. | `onScreenSharing()` |
| Manage the customizable views for the action bar, screensharing, and annotation callbacks.   | `onScreenSharingStarted()`, `onScreenSharingStopped()`, `onScreenSharingError()`,  `onClosed()`, `onLineDrawn()`|







