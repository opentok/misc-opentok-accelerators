![logo](../tokbox-logo.png)

# OpenTok Screensharing with Annotations Accelerator Pack for Android<br/>Version 1.0.0

This document describes how to use the OpenTok Screensharing with Annotations Accelerator Pack for Android. Through the exploration of the OpenTok Screensharing with Annotations Sample App, you will learn best practices for screensharing on an Android mobile device.

You can configure and run this sample app within just a few minutes!

**Note**: OpenTok Screensharing with Annotations requires Android Lollipop or later.


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

1. [Importing the Android Studio Project](#importing-the-android-studio-project)
2. [Adding the OpenTok Screensharing with Annotations Accelerator Pack library](#addlibrary)
3. [Configuring the app](#configuring-the-app)

To learn more about the best practices used to design this app, see [Exploring the code](#exploring-the-code).


### Importing the Android Studio project

1. Clone the OpenTok Screensharing with Annotations Sample App repository.
2. Start Android Studio. 
3. In the **Quick Start** panel, click **Open an existing Android Studio Project**.
4. Navigate to the **android** folder, select the **SampleApp** folder, and click **Choose**.


<h3 id=addlibrary> Adding the OpenTok Screensharing with Annotations Accelerator Pack library</h3>

There are 3 options for installing the OpenTok Screensharing with Annotations Accelerator Pack library:

  - [Using the repository](#using-the-repository)
  - [Using Maven](#using-maven)
  - [Downloading and Installing the AAR File](#downloading-and-installing-the-aar-file)

**NOTE**: 
  - The OpenTok Screensharing Sample App includes the [TokBox Common Accelerator Session Pack](https://github.com/opentok/acc-pack-common).
  - The OpenTok Screensharing with Annotations Acc Pack includes the [OpenTok Annotations Kit] (https://github.com/opentok/annotation-acc-pack).

#### Using the repository

1. Clone the [OpenTok Screensharing with Annotations Accelerator Pack repo](https://github.com/opentok/screensharing-annotation-acc-pack).
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
compile 'com.opentok.android:opentok-screensharing-annotations:1.0.0'
</code>

</li>

</ol>

  _**NOTE**: Since dependencies are transitive with Maven, it is not necessary to explicitly reference the TokBox Common Accelerator Session Pack and the Annotations Kit with this option._


#### Downloading and Installing the AAR File

1.  Download the [Screensharing with Annotations Accelerator Pack zip file](https://s3.amazonaws.com/artifact.tokbox.com/solution/rel/screensharing-annotations-acc-pack/android/opentok-screensharing-annotations-1.0.0.zip) containing the AAR file and documentation, and extract the **opentok-screensharing-annotations-1.0.0.aar** file.
2.  Right-click the app name and select **Open Module Settings** and click **+**.
3.  Select **Import .JAR/.AAR Package** and click  **Next**.
4.  Browse to the **Screensharing with Annotations Accelerator Pack library AAR** and click **Finish**.



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

You can enable or disable the `SUBSCRIBE_TO_SELF` feature by invoking the `OneToOneCommunication.setSubscribeToSelf()` method:

```java
OneToOneCommunication comm = new OneToOneCommunication(
  MainActivity.this, 
  OpenTokConfig.SESSION_ID, 
  OpenTokConfig.TOKEN, 
  OpenTokConfig.API_KEY
);

comm.setSubscribeToSelf(OpenTokConfig.SUBSCRIBE_TO_SELF);

```
_At this point you can try running the app! You can either use a simulator or an actual mobile device._

## Exploring the code

This section describes how the sample app code design uses recommended best practices to deploy the screensharing with annotations features. The sample app design extends the [OpenTok One-to-One Communication Sample App](https://github.com/opentok/one-to-one-sample-apps/tree/master/one-to-one-sample-app/) and [OpenTok Common Accelerator Session Pack](https://github.com/opentok/acc-pack-common/) by adding logic using the `com.tokbox.android.accpack.screensharing` classes.

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
| `ScreenSharingFragment`   | Provides the initializers and methods for the client screensharing views. |
| `ScreenSharingCapturer`   | Provides TokBox custom support for sharing content displayed in the screensharing area, overriding the mobile device OS default to share content captured by the camera. |
| `ScreenSharingBar`   | Initializes the screensharing toolbar and its UI controls. |


From [AnnotationsKit](https://github.com/opentok/annotation-acc-pack).

| Class        | Description  |
| ------------- | ------------- |
| `AnnotationsToolbar`   | Provides the initializers and methods for the annotation toolbar view, and initializes such functionality as text annotations, screen capture button, erase button that removes the last annotation that was added, color selector for drawing stroke and text annotations, and scrolling features. You can customize this toolbar. |
| `AnnotationsView`   | Provides the rectangular area on the screen which is responsible for drawing annotations and event handling |


###  Screensharing Accelerator Pack

The `ScreenSharingFragment` class is the backbone of the screensharing features for the app. It serves as a controller for the screensharing UI widget, and initializes such functionality as stroke color and scrolling features. It uses the [`android.media.projection.MediaProjection`](http://developer.android.com/reference/android/media/projection/MediaProjection.html), supported on Android Lollipop, and provides the projection callbacks needed for screensharing.

This class, which inherits from the [`android.support.v4.app.Fragment`](http://developer.android.com/intl/es/reference/android/support/v4/app/Fragment.html) class, sets up the screensharing with annotations UI views and events, sets up session listeners, and defines a listener interface that is implemented in this example by the `MainActivity` class.

```java
public class ScreenSharingFragment 
        extends    Fragment 
        implements AccPackSession.SessionListener,
                   PublisherKit.PublisherListener, 
                   AccPackSession.SignalListener, 
                   ScreenSharingBar.ScreenSharingBarListener {

    . . .

}
```

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


#### Initialization methods

The following `ScreenSharingFragment` methods are used to initialize the app and provide basic information determining the behavior of the screensharing with annotations functionality.

| Feature        | Methods  |
| ------------- | ------------- |
| Start screen capture.   | `start()`  |
| Stop screen capture.  | `stop()`  |
| Set the listener object to monitor state changes.   | `setListener()` |
| Sets whether annotations are enabled on the specified toolbar.  | `enableAnnotations()`  |


#### Setting the Annotation Toolbar

To set up your annotation toolbar, instantiate a `ScreenSharingFragment` object and call the `setAnnotationsEnabled(boolean annotationsEnabled, AnnotationsToolbar toolbar)` method, setting the `annotationsEnabled` parameter to `true`.

For example, the following private method instantiates a `ScreenSharingFragment` object and enables the annotation toolbar:

```java
    private void initScreenSharingFragment(){

        mScreenSharingFragment = ScreenSharingFragment.newInstance(
          mComm.getSession(), 
          OpenTokConfig.API_KEY
        );

        mScreenSharingFragment.enableAnnotations(true, mAnnotationsToolbar);

        mScreenSharingFragment.setListener(this);

        getSupportFragmentManager().beginTransaction()
                .add(
                      R.id.screensharing_fragment_container, 
                      mScreenSharingFragment
                ).commit();
    }
```


#### Capturing and Saving a Screenshot 

The annotation toolbar provides a camera icon that the user can click to capture a screenshot of the shared screen containing previously rendered annotations. 

To take a screenshot of the screensharing area, implement the `AnnotationsView.AnnotationsListener` interface and override the `onScreencaptureReady()` listener. 

For example, the `MainActivity` class implements the interface and provides the following implementation of the listener, passing the bitmap to a private method that compresses and saves the image to an external storage location:


```java
public class MainActivity extends AppCompatActivity implements 
    OneToOneCommunication.Listener, 
    PreviewControlFragment.PreviewControlCallbacks,
    RemoteControlFragment.RemoteControlCallbacks, 
    PreviewCameraFragment.PreviewCameraCallbacks, 
    ScreenSharingFragment.ScreenSharingListener, 
    AnnotationsView.AnnotationsListener {

    . . .

    @Override
    public void onScreencaptureReady(Bitmap bmp) {
        saveScreencapture(bmp);
    }


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
| Manage the customizable views for the action bar, screensharing, and annotation callbacks.   | `onScreenSharingStarted()`, `onScreenSharingStopped()`, `onScreenSharingError()`,  `onClosed()`|







