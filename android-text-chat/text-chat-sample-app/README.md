OpenTok Android Text Chat UI sample
===================================
A basic sample app showing the use of the OpenTok Android Text Chat UI sample

## Configuring the app

1. In Android Studio, select the Import Project command, navigate to
   the build.gradle file in the textchat-sample file, and click OK.

2. Download the [OpenTok Android SDK](https://tokbox.com/opentok/libraries/client/android/).

   This application requires version 2.6.0+ of the OpenTok Android SDK.

3. Locate the opentok-android-sdk-2.x.x.jar file in the OpenTok/libs directory of the OpenTok
   Android SDK, and drag it into the app/libs directory of the project.

4. Locate the armeabi and x86 directories in the OpenTok/libs directory of the OpenTok
   Android SDK, and drag them into the app/jniLibs directory of the project.

5. Add the opentok-android-sdk-ui.aar file to the app/libs directory of the project.

   The opentok-android-sdk-ui.aar file os available an the [opentok-android-sdk-ui
   Releases](https://github.com/opentok/opentok-android-sdk-ui/releases) page.

6. In the com.opentok.android.ui.textchat.sample.TextChatActivity.java class, set the following
   properties to a test OpenTok session ID, token, and API key:

   ```
   private static final String SESSION_ID = "";
   private static final String TOKEN = "";
   private static final String APIKEY = "";
   ```

   For this sample app, you must set the connection data of the token to be the name of
   (or identifier for) the user. This is used to identify the user's text messages
   in the text chat user interface. For more information, see
   [Connection data](https://tokbox.com/developer/guides/create-token/#connection-data).

   You can get a test OpenTok session ID, a test token, and your OpenTok API key at the
   [OpenTok dashboard](https://dashboard.tokbox.com/). However, in a final application,
   you must use the OpenTok server SDKs to generate a unique token for each user. See
   the [Token creation overview](https://tokbox.com/developer/guides/create-token/).

7. Debug the project on a supported device.

   For a list of supported devices, see the "Developer and client requirements"
   on [this page](https://tokbox.com/developer/sdks/android/).

The app connects to an OpenTok session and uses the OpenTok signaling API to send and
receive text messages to the session. Tap the text field at the bottom of the app,
enter a text message, and then tap the Send button.

## Understanding the code

The Java code for the application is in the com.opentok.android.ui.textchat.sample package.

Upon startup (`onCreate()`), the TextChatActivity class connects to the OpenTok session.
Upon connecting to the session, it calls the `loadTextChatFragment()` method, which
instantiates a TextChatFragment instance and adds it to the UI:

```java
if (mTextChatFragment == null)
{
    mTextChatFragment = new TextChatFragment();
    mTextChatFragment.setMaxTextLength(1050);
    mTextChatFragment.setTextChatListener(this);
    mTextChatFragment.setSenderInfo(mSession.getConnection().getConnectionId(),
      mSession.getConnection().getData());
}
```

The TextChatFragment class is defined in the OpenTok Android Text Chat UI API. It is an
Android Fragment that defines user interface that lets the user enter a text chat message to send.

The code sets the TextChatActivity object as the listener for TextChatFragment events.
Note that the TextChatActivity class implements the TextChatFragment.TextChatListener
interface.

The code calls the `setMaxTextLength(length)` method of the TextChatFragment object to
set the maximum length of the message.

The code calls the `setSenderInfo(id, alias)` method of the TextChatFragment object to
set the sender ID and alias for the local client. The ID is set to the local client's
OpenTok connection ID (a unique identifier), and the alias is set to the connection data
added when you created a token for the user.

The TextChatActivity class implements the `onMessageReadyToSend(msgStr)` method of the
TextChatFragment.TextChatListener interface. This method is called when the user clicks the
Send button:

```java
@Override
public boolean onMessageReadyToSend(ChatMessage msg) {
    if (mSession != null) {
        mSession.sendSignal(SIGNAL_TYPE, msg.getText());
    }
    //to indicate to the text-chat component if the message is valid and it is ready to be sent
    return msgError;
}
```

The app uses the `Session.sendSignal(type, data)` method (defined by the OpenTok
Android SDK) to send a message to the session. The signal `type` indicates that it is
a text message. The signal's `data` is set to the text of the message to send.

When the session is received, the implementation of the
`SignalListener.onSignalReceived(session, type, data, connection)` method (defined by the OpenTok
Android SDK) is called:

```java
@Override
public void onSignalReceived(Session session, String type, String data, Connection connection) {
    Log.d(LOGTAG, "onSignalReceived. Type: "+ type + " data: "+data);
    ChatMessage msg;
    if (!connection.getConnectionId().equals(mSession.getConnection().getConnectionId())) {
        msg = new ChatMessage(connection.getConnectionId(), connection.getData(), data);
        mTextChatFragment.addMessage(msg);
    }
}
```

The code creates a new ChatMessage instance. The ChatMessage class is defined by the
OpenTok Android Text Chat UI API. It defines a message to be displayed by a
TextChatFragement instance. A ChatMessage instance has a sender (a string that identifies
the sender of the message) and the text of the message.

The code checks to see if the signal was sent by another client
(`(!connection.getConnectionId().equals(mSession.getConnection().getConnectionId()))`). (Signals
sent by the local client are automatically displayed by when the user clicks the Send button in the
TextChatFragment.)

The code sets the `senderId` parameter of the ChatMessage constructor to the connection ID
(a unique idendifier for the sender). The TextChatFragment uses the sender ID to group messages
sent by the same sender together.

The second parameter of the constructor is the sender alais, which the TextChatFragment uses as
the name of the sender in the message list. In this app, the alias is set as the connection data
when you create a token for each user (see [Token
creation](https://tokbox.com/developer/guides/create-token/) ).

The third parameter of the constructor is the chat message text:

```java
msg = new ChatMessage(connection.getConnectionId(), connection.getData(), data);
```

Note that you could use something other than the connection data to identify the sender
of a received message. For example, you could embed the user's identification in the
signal data (perhaps formatting the data as JSON).

Finally, the code calls the `addMessage(msg)` method of the TextChatFragment instance,
which causes the message to be displayed in the message list of the TextChatFragment view:

```java
//Add the new ChatMessage to the text-chat component
mTextChatFragment.addMessage(msg);
```
