![logo](../tokbox-logo.png)

# OpenTok Text Chat Accelerator Pack for Android<br/>Version 2.0.0

## Quick start

This section shows you how to use the accelerator pack.

## Quick start

To get up and running quickly with your app, go through the following steps in the tutorial provided below:

1. [Importing the Android Studio Project](#importing-the-android-studio-project)
2. [Adding the OpenTok Text Chat Accelerator Pack library](#addlibrary)
3. [Configuring the app](#configuring-the-app)

To learn more about the best practices used to design this app, see [Exploring the code](#exploring-the-code).

### Importing the Android Studio project

1. Clone the [OpenTok Text Chat Accelerator Pack repo](https://github.com/opentok/textchat-acc-pack).
2. Start Android Studio.
3. In the **Quick Start** panel, click **Open an existing Android Studio Project**.
4. Navigate to the **android** folder, select the **OneToOneTextChatSample** folder, and click **Choose**.

<h3 id=addlibrary> Adding the OpenTok Text Chat Accelerator Pack library</h3>

There are three options for installing the OpenTok Text Chat Accelerator Pack library:

  - [Using the repository](using-the-repository)
  - [Using Maven](#using-maven)
  - [Downloading and Installing the AAR File](#downloading-and-installing-the-aar-file)

**NOTE**: The OpenTok Text Chat Sample App includes the [TokBox Common Accelerator Session Pack](https://github.com/opentok/acc-pack-common).

#### Using the repository

1. Clone the [OpenTok Text Chat Accelerator Pack repo](https://github.com/opentok/textchat-acc-pack).
2. From the OpenTok Text Chat Sample app project, right-click the app name and select **New > Module > Import Gradle Project**.
3. Navigate to the directory in which you cloned **OpenTok Text Chat Accelerator Pack**, select **text-chat-acc-pack-kit**, and click **Finish**.
4. Open the **build.gradle** file for the app and ensure the following line has been added to the `dependencies` section:
```
compile project(':text-chat-acc-pack-kit')
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
compile 'com.opentok.android:opentok-text-chat-acc-pack:2.0.0'
</code>

</li>

</ol>


  _**NOTE**: Since dependencies are transitive with Maven, it is not necessary to explicitly reference the TokBox Common Accelerator Session Pack with this option._


#### Downloading and Installing the AAR File

1.  Download the [Text Chat Accelerator Pack zip file](https://s3.amazonaws.com/artifact.tokbox.com/solution/rel/textchat-acc-pack/android/opentok-text-chat-acc-pack-2.0.0.zip) containing the AAR file and documentation, and extract the **opentok-text-chat-acc-pack-2.0.0.aar** file.
2.  Right-click the app name and select **Open Module Settings** and click **+**.
3.  Select **Import .JAR/.AAR Package** and click  **Next**.
4.  Browse to the **Text Chat Accelerator Pack library AAR** and click **Finish**.



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

This section describes how the sample app code design uses recommended best practices to deploy the text chat communication features. The sample app design extends the [OpenTok One-to-One Communication Sample App](https://github.com/opentok/one-to-one-sample-apps/tree/master/one-to-one-sample-app/) and [OpenTok Common Accelerator Session Pack](https://github.com/opentok/acc-pack-common/) by adding logic using the `com.tokbox.android.textchat` classes.

For detail about the APIs used to develop this sample, see the [OpenTok Android SDK Reference](https://tokbox.com/developer/sdks/android/reference/) and [Android API Reference](http://developer.android.com/reference/packages.html).

  - [Class design](#class-design)
  - [Text Chat Accelerator Pack](#text-chat-accelerator-pack)
  - [User interface](#user-interface)

_**NOTE:** The sample app contains logic used for logging. This is used to submit anonymous usage data for internal TokBox purposes only. We request that you do not modify or remove any logging code in your use of this sample application._

### Class design

The following classes represent the software design for the accelerator pack and the sample app, focusing primarily on the text chat features. For details about the one-to-one communication aspects of the design, see the [OpenTok One-to-One Communication Sample App](https://github.com/opentok/one-to-one-sample-apps/tree/master/one-to-one-sample-app/android).

| Class        | Description  |
| ------------- | ------------- |
| `MainActivity`    | Implements the sample app UI and text chat callbacks. |
| `OpenTokConfig`   | Stores the information required to configure the session and connect to the cloud.   |
| `TextChatFragment`   | Provides the initializers and methods for the client text chat UI views. |
| `TextChatFragment.TextChatListener`   | Monitors both receiving and sending activity. For example, a message is successfully sent, or a message is sent with a code in the event of an error. |
| `ChatMessage`   | A data model describing information used in individual text chat messages. |


###  Text Chat Accelerator Pack

The `TextChatFragment` class is the backbone of the text chat communication features for the app.

This class, which inherits from the [`android.support.v4.app.Fragment`](http://developer.android.com/intl/es/reference/android/support/v4/app/Fragment.html) class, sets up the text chat UI views and events, sets up session listeners, and defines a listener interface that is implemented in this example by the `MainActivity` class.

```java
public class TextChatFragment extends Fragment implements AccPackSession.SignalListener, AccPackSession.SessionListener {

    . . .

}
```

The `TextChatListener` interface monitors state changes in the `TextChatFragment`, and defines the following methods:

```java
public interface TextChatListener {

        void onNewSentMessage(ChatMessage message);
        void onNewReceivedMessage(ChatMessage message);
        void onTextChatError(String error);
        void onClose();
}
```




#### Initialization methods

The following `TextChatFragment` methods are used to initialize the app and provide basic information determining the behavior of the text chat functionality.

| Feature        | Methods  |
| ------------- | ------------- |
| Set the maximum chat text length.   | `setMaxTextLength()`  |
| Set the sender alias of the outgoing messages.  | `setSenderAlias()`  |
| Set the listener object to monitor state changes.   | `setListener()` |


For example, the following private method instantiates a `TextChatFragment` object:

```java
    private void initTextChatFragment(){
        mTextChatFragment = TextChatFragment.newInstance(mComm.getSession(), OpenTokConfig.API_KEY);

        getSupportFragmentManager().beginTransaction()
                .add(R.id.textchat_fragment_container, mTextChatFragment).commit();
    }
```


This line of code illustrates how to set the maximum message length to 1050 characters and set a new sender alias:

```java
mTextChatFragment.setMaxTextLength(1050);
            mTextChatFragment.setSenderAlias("Tokboxer");
            mTextChatFragment.setListener(this);
```


#### Sending and receiving messages

By implementing the `TextChatFragment.TextChatListener` interface, the `MainActivity` class defines methods that monitor both receiving and sending activity. For example, a message is successfully sent, or a message is sent with a code in the event of an error.

The method implementations shown below use the `ChatMessage` object to send and receive messages.

The `onNewSentMessage()` event is fired when a new individual `ChatMessage` is sent to other client connected to the OpenTok session. To send a `ChatMessage`, the `TextChatFragment` uses the [OpenTok signaling API](https://tokbox.com/developer/sdks/android/reference/com/opentok/android/Session.html#sendSignal(java.lang.String,%20java.lang.String)).

The `onNewReceivedMessage()` event is fired when a new `ChatMessage` is received from the other client.

```java
    @Override
    public void onNewSentMessage(ChatMessage message) {
        Log.i(LOG_TAG, "New sent message");
    }

    @Override
    public void onNewReceivedMessage(ChatMessage message) {
        Log.i(LOG_TAG, "New received message");
    }
```



### User interface

As described in [Class design](#class-design), the `TextChatFragment` class sets up and manages the UI views, events, and rendering for the chat text controls:

   - `TextChatFragment`


This class works with the following `MainActivity` methods, which manage the views as both clients participate in the session.

| Feature        | Methods  |
| ------------- | ------------- |
| Manage the UI containers. | `onCreate()`  |
| Reload the UI views whenever the device [configuration](http://developer.android.com/reference/android/content/res/Configuration.html), such as screen size or orientation, changes. | `onConfigurationChanged()`  |
| Opens and closes the text chat view. | `onTextChat()` |
| Manage the customizable views for the action bar and messages.   | `getSendMessageView()`, `setSendMessageView()`, `getActionBar()`,  `setActionBar()`|


## Requirements

To develop your text chat app:

1. Install [Android Studio](http://developer.android.com/intl/es/sdk/index.html).
2. Review the [OpenTok Android SDK Requirements](https://tokbox.com/developer/sdks/android/#developerandclientrequirements).
