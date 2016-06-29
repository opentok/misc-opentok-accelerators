# Accelerator Pack for Android 1.0.0

## Requirements

## Installation

There are 2 options for installing the OpenTok Android Accelerator Pack:


#### Using the repository

1. Clone the [OpenTok Accelerator Pack repo](https://github.com/opentok/acc-pack-common).
2. From your app project, right-click the app name and select **New > Module > Import Gradle Project**.
3. Navigate to the directory in which you cloned **OpenTok Accelerator Pack**, select **android-accelerator-pack**, and click **Finish**.
4. Open the **build.gradle** file for the app and ensure the following lines have been added to the `dependencies` section:

```
compile project(':android-accelerator-pack')

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
compile 'com.opentok.android:accelerator-pack:1.0.0'
</code>

</li>

</ol>

