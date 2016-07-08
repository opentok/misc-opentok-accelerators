![logo](../tokbox-logo.png)

# OpenTok Annotations Accelerator Pack for Android<br/>Version 1.0

This document describes how to use the OpenTok Annotations Accelerator Pack for Android. Through the exploration of this Accelerator Pack, you will learn best practices for development and customization with annotations on an Android mobile device.

**Note**: The OpenTok Annotations Accelerator Pack is not a standalone Accelerator Pack such as [screensharing-annotation-acc-pack](https://github.com/opentok/screensharing-annotation-acc-pack). Rather, it is used as a component for more comprehensive Accelerator Packs that offer such features as screensharing and video along with annotations. 

This guide has the following sections:

* [Prerequisites](#prerequisites): A checklist of everything you need to get started.
* [Quick start](#quick-start): A step-by-step tutorial to help you quickly import and use the OpenTok Annotations Accelerator Pack for Android.
* [Exploring the code](#exploring-the-code): This describes the Accelerator Pack code design, which uses recommended best practices to implement the annotation and frame grab capabilities available in the OpenTok client SDK. 


## Prerequisites

To be prepared to develop with the Annotations Accelerator Pack for Android:

1. Install [Android Studio](http://developer.android.com/intl/es/sdk/index.html).
2. Review the [OpenTok Android SDK Requirements](https://tokbox.com/developer/sdks/android/#developerandclientrequirements).
3. Your app will need a **Session ID**, **Token**, and **API Key**, which you can get at the [OpenTok Developer Dashboard](https://dashboard.tokbox.com/).


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

This section describes how the sample app code design uses recommended best practices to deploy the screensharing with annotations features. The sample app design extends the [OpenTok One-to-One Communication Sample App](https://github.com/opentok/one-to-one-sample-apps/tree/master/one-to-one-sample-app/) and [OpenTok Common Accelerator Session Pack](https://github.com/opentok/acc-pack-common/) by adding logic using the `com.tokbox.android.accpack.screensharing` classes.

For detail about the APIs used to develop this sample, see the [OpenTok Android SDK Reference](https://tokbox.com/developer/sdks/android/reference/) and [Android API Reference](http://developer.android.com/reference/packages.html).

3. Main classes:

- AnnotationsToolbar: Provides the initializers and methods for the annotation toolbar view, and initializes such functionality as text annotations, screen capture button, erase button that removes the last annotation that was added, color selector for drawing stroke and text annotations, and scrolling features. You can customize this toolbar.

-AnnotationsView:Provides the rectangular area on the screen which is responsible for drawing annotations and event handling
- AnnotationsListener:Monitors state changes in the Annotations component. Eg: Run a new event when a screenCapture is ready or there is an error.
AnnotationsPath: Extends the Android Path class( https://developer.android.com/reference/android/graphics/Path.html ) Defines the different geometric paths to be drawn in the AnnotationView canvas.

- AnnotationText: Defines the Text labels to be drawn in the AnnotationViewCanvas

- Annotatable: Each AnnotationText or AnnotationPath will be defined as an annotatable object.

- AnnotationsManager: Manages the set of the annotations in the annotationsView.

- AnnotationsVideoRenderer: Extends the BaseVideoRenderer class in the OpenTok Android SDK. It includes the screenshot functionality.

4. Using the AnnotationsKit:

4.1 Add the annotationToolbar in your layout. EG:
<com.tokbox.android.annotations.AnnotationsToolbar
    android:id="@+id/annotations_bar"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_gravity="bottom"/>



4.2 Adding a custom annotation renderer
Create a new instance of the AnnotationsVideoRenderer class or creates a new custom video renderer.

AnnotationsVideoRenderer renderer = new AnnotationsVideoRenderer(this);

Set the AnnotationsVideoRenderer to the publisher/subscriber. Eg: in the Screensharing case, we are going to set the AnnotationsVideoRenderer to the publisher screen, just to allow to get a screenshot of this screen.

mRenderer = new AnnotationsVideoRenderer(getContext());
mScreenPublisher.setRenderer(mRenderer);


4.3 Attaching an Annotations canvas to a publisher/subscriber view:

	- Init the annotationsView: public AnnotationsView(Context context, AccPackSession session, String partnerId)

	- Attach the AnnotationsToolbar to the AnnotationView:  public void attachToolbar(AnnotationsToolbar toolbar);
   
	- Set VideoRenderer: public void setVideoRenderer(AnnotationsVideoRenderer videoRenderer);

	- Add the AnnotationsView to the publisher/subscriber view:
	
Eg:

if ( mAnnotationsView == null ){
    mAnnotationsView = new AnnotationsView(getContext(), mSession, mApiKey)
    mAnnotationsView.attachToolbar(mAnnotationsToolbar);
    mAnnotationsView.setVideoRenderer(mRenderer); //to use screen capture
    mScreenView.addView(mAnnotationsView);
}

4.4 Implements AnnotationsListener:
Events:
- public void onScreencaptureReady(Bitmap bmp): Fired when a new screencapture is ready
- void onError(String error): Fired when there is an error adding an annotations.
Eg:
public class MainActivity extends AppCompatActivity implements AnnotationsView.AnnotationsListener {

	@Override
	public void onScreencaptureReady(Bitmap bmp) {
    		saveScreencapture(bmp);
	}
	
}
4.5 Actions in the Annotations:
- Freehand Annotation: Handwritten annotation 
- Text Annotation: text label annotations
- Picker color: select a color for the annotation.
- Erase: Remove the last annotation.
- Screencapture: Screenshot of the annotations.
- Done: To unfrozen the screen. Clear all the annotations.

