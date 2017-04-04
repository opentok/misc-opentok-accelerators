![logo](../tokbox-logo.png)

# OpenTok Annotations Accelerator Pack for Android<br/>Version 1.1

## Quick start

This section shows you how to prepare and use the OpenTok Annotations Accelerator Pack as part of an application.

## Add the Annotations library

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

1. In the `build.gradle` file for your solution, add the following code to the section labeled `repositories`:

  ```
  maven { url  "http://tokbox.bintray.com/maven" }
  ```

2. Add the following code snippet to the section labeled 'dependencies’:

  ```
  compile 'com.opentok.android:opentok-annotations:1.1.0’
  ```

### Downloading and Installing the AAR File

1.  Download the [OpenTok Annotations Accelerator Pack zip file](https://s3.amazonaws.com/artifact.tokbox.com/solution/rel/annotations/android/opentok-annotations-1.1.0.zip) containing the AAR file and documentation,
1. Extract the **opentok-annotations-1.1.0.aar** file.
2.  Right-click the app name, select **Open Module Settings**, and click **+**.
3.  Select **Import .JAR/.AAR Package** and click **Next**.
4.  Browse to the **Annotations Accelerator Pack library AAR** and click **Finish**.


## Exploring the code

For detail about the APIs used to develop this accelerator pack, see the [OpenTok Android SDK Reference](https://tokbox.com/developer/sdks/android/reference/) and [Android API Reference](http://developer.android.com/reference/packages.html).

_**NOTE:** The accelerator pack contains logic used for logging. This is used to submit anonymous usage data for internal TokBox purposes only. We request that you do not modify or remove any logging code in your use of this accelerator pack._

### Class design

| Class        | Description  |
| ------------- | ------------- |
| `AnnotationsToolbar`   | Provides the initializers and methods for the annotation toolbar view, and initializes functionality such as text annotations, a screen capture button, an erase button that removes the last annotation that was added, a color selector for drawing strokes and text annotations, and controls scrolling. You can customize this toolbar. |
| `AnnotationsView`   | Provides the rectangular area on the screen which is responsible for drawing annotations and event handling. |
| `AnnotationsListener`   | Monitors state changes in the Annotations component. For example, a new event would occur when a screen capture is ready or there is an error. |
| `AnnotationsPath`   | Extends the [Android Path class](https://developer.android.com/reference/android/graphics/Path.html), and defines the various geometric paths to be drawn in the `AnnotationView` canvas. |
| `AnnotationText`   | Defines the text labels to be drawn in the `AnnotationViewCanvas`. |
| `Annotatable`   | Each `AnnotationText` or `AnnotationPath` is defined as an annotatable object. |
| `AnnotationsManager`   | Manages the set of the annotations in the annotations view. |
| `AnnotationsVideoRenderer`   | Extends the [BaseVideoRenderer](https://tokbox.com/developer/sdks/android/reference/com/opentok/android/BaseVideoRenderer.html) class in the OpenTok Android SDK, and includes screenshot functionality. |

**NOTE:** Scrolling is frozen while the user adds annotations. Scrolling is re-enabled after the user clicks **Done**, and the annotations are removed at that point.


### Using the Annotations Acc Pack


#### Add the annotation toolbar

Add the `AnnotationsToolbar` to your layout:</p>

```java
<com.tokbox.android.annotations.AnnotationsToolbar
    android:id="@+id/annotations_bar"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_gravity="bottom"/>
```

The `AnnotationsToolbar` offers the following actions:
  - _Freehand Annotation_: Handwritten annotation
  - _Text Annotation_: Text label annotations.
  - _Color Picker_: Select a color for the annotation.
  - _Erase_: Delete the most recent annotation.
  - _Screen Capture_: Take a screenshot of the annotations.
  - _Done_: Clear all annotations and re-enabling scrolling.


#### Add a custom annotation renderer

If you would like to create a new instance of the `AnnotationsVideoRenderer` class or a new custom video renderer, start with this line of code:

```java
AnnotationsVideoRenderer mRenderer = new AnnotationsVideoRenderer(this);
mScreenPublisher.setRenderer(mRenderer);
```


#### Attach the annotation canvas to a view

You can attach an annotation canvas to a publisher or subscriber view:

```java
try {
  AnnotationsView annotationsView = new AnnotationsView(this, mComm.getSession(), OpenTokConfig.API_KEY, mComm.getRemote());
  annotationsView.attachToolbar(mAnnotationsToolbar);
  previewContainer.addView(annotationsView);
          
} catch (Exception e) {
  Log.i(LOG_TAG, "Exception - add annotations view " + e);
}
```

#### Implement an annotations listener class

To listen for annotation events, implement an `AnnotationsListener`:

```java
public  interface AnnotationsListener {
  void onScreencaptureReady(Bitmap bmp);
  void onAnnotationsSelected(AnnotationsView.Mode mode);
  void onAnnotationsDone();
  void onError(String error);
}
```

```java
public class MainActivity
    extends AppCompatActivity
    implements AnnotationsView.AnnotationsListener {

    @Override
    public void onScreencaptureReady(Bitmap bmp) {
        //A new screencapture is ready
    }

    @Override
    public void onAnnotationsSelected(AnnotationsView.Mode mode) {
        //An annotations item in the toolbar is selected
    }

    @Override
    public void onAnnotationsDone() {
        //The DONE button annotations item in the toolbar is selected. Scrolling is re-enabled.
    }

    @Override
    public void onError(String error) {
       //An error happens in the annotations
    }
  ...
}
```

## Requirements

To develop an application that uses the OpenTok Annotations Accelerator Pack for Android:

  1. Install [Android Studio](http://developer.android.com/intl/es/sdk/index.html).
  2. Review the [OpenTok Android SDK Requirements](https://tokbox.com/developer/sdks/android/#developerandclientrequirements).
