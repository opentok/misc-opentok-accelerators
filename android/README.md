![logo](../tokbox-logo.png)

# OpenTok Annotations Accelerator Pack for Android<br/>Version 1.0.0

This document describes how to use the OpenTok Annotations Accelerator Pack for Android. Through the exploration of this Accelerator Pack, you will learn best practices for development and customization with annotations on an Android mobile device.

**Note**: The OpenTok Annotations Accelerator Pack does not include a standalone sample app such as [screensharing-annotation-acc-pack](https://github.com/opentok/screensharing-annotation-acc-pack), though you can easily build your own apps with it. It is also used as a component for more comprehensive Accelerator Packs that offer such features as screensharing and video along with annotations. 

This guide has the following sections:

* [Prerequisites](#prerequisites): A checklist of everything you need to get started.
* [Quick start](#quick-start): A step-by-step tutorial to help you quickly import and use the OpenTok Annotations Accelerator Pack for Android.
* [Exploring the code](#exploring-the-code): This describes the Accelerator Pack code design, which uses recommended best practices to implement the annotation and frame grab capabilities available in the OpenTok client SDK. 


## Prerequisites

To be prepared to develop with the Annotations Accelerator Pack for Android:

1. Install [Android Studio](http://developer.android.com/intl/es/sdk/index.html).
2. Review the [OpenTok Android SDK Requirements](https://tokbox.com/developer/sdks/android/#developerandclientrequirements).
3. Your app will need a **Session ID**, **Token**, and **API Key**, which you can get at the [OpenTok Developer Dashboard](https://dashboard.tokbox.com/).

_**NOTE**: The OpenTok Developer Dashboard allows you to quickly run this sample program. For production deployment, you must generate the **Session ID** and **Token** values using the [OpenTok Server SDK](https://tokbox.com/developer/sdks/server/)._


## Quick start

There are 3 options for installing the OpenTok Annotations Accelerator Pack library:

  - [Using the repository](#using-the-repository)
  - [Using Maven](#using-maven)
  - [Downloading and Installing the AAR File](#downloading-and-installing-the-aar-file)


### Using the repository

1. Clone the [OpenTok Annotations Accelerator Pack repo](https://github.com/opentok/annotation-acc-pack).
2. Start Android Studio and create a project. 
3. Navigate to the **android** folder, select the **AnnotationsKit** folder, and click **Choose**.
4. From the project view, right-click the app name and select **New > Module > Import Gradle Project**.
5. Navigate to the directory in which you cloned **OpenTok Annotations Accelerator Pack**, select **annotations-kit**, and click **Finish**.
6. Open the **build.gradle** file for the app and ensure the following lines have been added to the `dependencies` section:
```
   compile project(‘:annotations-kit')
```

### Using Maven

<ol>

<li>Modify the <b>build.gradle</b> for your solution and add the following code snippet to the section labeled 'repositories’:

<code>
maven { url  "http://tokbox.bintray.com/maven" }
</code>

</li>

<li>Modify the <b>build.gradle</b> for your activity and add the following code snippet to the section labeled 'dependencies’: 


<code>
compile 'com.opentok.android:opentok-annotations:1.0.0'
</code>

</li>

</ol>



### Downloading and Installing the AAR File

1.  Download the [OpenTok Annotations Accelerator Pack zip file](https://s3.amazonaws.com/artifact.tokbox.com/solution/rel/annotations/android/opentok-annotations-1.0.0.zip) containing the AAR file and documentation, and extract the **opentok-annotations-1.0.0.aar** file.
2.  Right-click the app name and select **Open Module Settings** and click **+**.
3.  Select **Import .JAR/.AAR Package** and click **Next**.
4.  Browse to the **Annotations Accelerator Pack library AAR** and click **Finish**.


## Exploring the code

This section describes how the sample app code design uses recommended best practices to deploy the annotations features. 

For detail about the APIs used to develop this sample, see the [OpenTok Android SDK Reference](https://tokbox.com/developer/sdks/android/reference/) and [Android API Reference](http://developer.android.com/reference/packages.html).

### Class design

The following classes represent the software design for the OpenTok Annotations Accelerator Pack.

| Class        | Description  |
| ------------- | ------------- |
| `AnnotationsToolbar`   | Provides the initializers and methods for the annotation toolbar view, and initializes such functionality as text annotations, screen capture button, erase button that removes the last annotation that was added, color selector for drawing stroke and text annotations, and controls scrolling. You can customize this toolbar. |
| `AnnotationsView`   | Provides the rectangular area on the screen which is responsible for drawing annotations and event handling. |
| `AnnotationsListener`   | Monitors state changes in the Annotations component. For example, a new event would occur when a screen capture is ready or there is an error. |
| `AnnotationsPath`   | Extends the [Android Path class](https://developer.android.com/reference/android/graphics/Path.html), and defines the various geometric paths to be drawn in the `AnnotationView` canvas. |
| `AnnotationText`   | Defines the text labels to be drawn in the `AnnotationViewCanvas`. |
| `Annotatable`   | Each `AnnotationText` or `AnnotationPath` is defined as an annotatable object. |
| `AnnotationsManager`   | Manages the set of the annotations in the annotations view. |
| `AnnotationsVideoRenderer`   | Extends the [BaseVideoRenderer](https://tokbox.com/developer/sdks/android/reference/com/opentok/android/BaseVideoRenderer.html) class in the OpenTok Android SDK, and includes screenshot functionality. |

**NOTE:** Scrolling is frozen while the user adds annotations. Scrolling is re-enabled after the user clicks **Done**, and the annotations are removed at that point. 


### Using the AnnotationsKit


#### Add the annotation toolbar

Add the `AnnotationsToolbar` to your layout:</p>

```
<com.tokbox.android.annotations.AnnotationsToolbar
    android:id="@+id/annotations_bar"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_gravity="bottom"/>
```


#### Add a custom annotation renderer

If you would like to create a new instance of the `AnnotationsVideoRenderer` class or a new custom video renderer, start with this line of code:

```java
AnnotationsVideoRenderer mRenderer = new AnnotationsVideoRenderer(this);
```


The following code illustrates how to set the `AnnotationsVideoRenderer` to the publisher or subscriber. For example, if the publisher is screensharing, set the `AnnotationsVideoRenderer` to the publisher screen. This could be used to get a screenshot of the screen:

```java
mRenderer = new AnnotationsVideoRenderer(getContext());
mScreenPublisher.setRenderer(mRenderer);
```

#### Attach the annotation canvas to a view

You can attach an annotation canvas to a publisher or subscriber view:

The following code initializes the `AnnotationsView`, attaches the `AnnotationsToolbar` to the `AnnotationsView`, sets the `VideoRenderer`, and adds the `AnnotationsView` to the publisher or subscriber view:


```java
if ( mAnnotationsView == null ){
    mAnnotationsView = new AnnotationsView(getContext(), mSession, mApiKey)
    mAnnotationsView.attachToolbar(mAnnotationsToolbar);
    mAnnotationsView.setVideoRenderer(mRenderer); //to use screen capture
    mScreenView.addView(mAnnotationsView);
}
```

#### Implement an annotations listener class

To listen for annotation events, implement an `AnnotationsListener`:

In the following example, the `onScreencaptureReady()` event is fired when a new screen capture is ready. 

```java
public class MainActivity 
    extends AppCompatActivity 
    implements AnnotationsView.AnnotationsListener {

	@Override
	public void onScreencaptureReady(Bitmap bmp) {
    		saveScreencapture(bmp);
	}
}
```


You can create handlers for the following types of annotations:
  - _Freehand Annotation_: Handwritten annotation 
  - _Text Annotation_: Text label annotations.
  - _Color Picker_: Select a color for the annotation.
  - _Erase_: Delete the most recent annotation.
  - _Screen Capture_: Take a screenshot of the annotations.
  - _Done_: Clear all annotations.
