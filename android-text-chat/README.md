# OpenTok Instant Messaging Component <br/>Android<br/> Version 0.1

## User Stories
1. As a Developer, I want to be able to send text chat messages, so the other participants, who are connected to the OpenTok session, can receive the messages.
2. As a Developer, I want to be able to receive text chat messages, so the other participants, who are connected to the OpenTok session, can send to me.

## API

package com.opentok.im.android

## Classes
Class  | Description
:------ | :------
[IntantMessaging](#instantmessaging) | Represents the instant messaging communication between 2 or more participants connected to an OpenTok session.
[ChatMessage](#chatmessage) | Represents the sent or received messages in the Instant Messaging communication.


## InstantMessaging

## Nested classes

Class  | Description
:------ | :------
[IMListener](#events) | Monitors the events in the InstantMessaging communication.


## Fields

Modifier and Type| Field  
:------ | :------
protected Session| session
protected InstantMessaging.IMListener | listener


## Constructor

Method| Description  
:------ | :------
InstantMessaging(com.opentok.android.Session session)| Create a new Instant Messaging instance

```java

	InstantMessaging mIM = new InstantMessaging(mSession);

```


## Methods

Method| Description  
:------ | :------
(boolean) sendMessage(ChatMessage message)| Send a new message to all the participants connected to the OpenTok session.
(boolean) sendMessage(ChatMessage message, java.lang.String destination)| Send a new message to the destination. This string has to be the connectionId of the other participant.
setIMListener(InstantMessaging.IMListener listener) | Set the IM listener


```java
	
	InstantMessaging mIM = new InstantMessaging(mSession);
	ChatMessage myMessage = new ChatMessage(.....);
	mIm.sendMessage(myMessage);

```

## Events

Method| Description  
:------ | :------
onIncomingMessage(ChatMessage message)| Invoked when a new message is received
onError(OpenTokError error)| Invoked when the IM communication fails


## ChatMessage

## Nested classes

Class  | Description
:------ | :------
[MessageBuilder](#messagebuilder) | Represents the ChatMessage parameters


## Constructor

Method| Description  
:------ | :------
ChatMessage(Builder builder)| Create a new ChatMessage instance with the pameters defined in the 'builder'

## Methods
Method| Description  
:------ | :------
getSenderId() | Returng the senderId (java.lang.String ) of the message
getSenderAlias() | Return the senderAlias (java.lang.String) of the message
getMessageString() | Return the text of the message
getTimestamp() | Return the timestamp of the message
setSenderId(java.lang.String senderId) | Set the desired id of the sender
setSenderAlias(java.lang.String senderId) | Set the desired alias of the sender
setMessageString(java.lang.String messageString) | Set the desired text string of the message
setTimestamp(java.lang.Long timestamp) | Set the timestamp of the message


```java
	
	
	Date date = new Date();

	ChatMessage mChatMessage = new ChatMessage.MessageBuilder(mSession.connectionId) //senderId
                       .senderAlias("Bob")
                       .messageString("Good morning!")
                       .timestamp(date.getTime())
                       .build();

```

## MessageBuilder

## Fields

Modifier and Type| Field
:------ | :------
protected java.lang.String | senderId 
protected java.lang.String | senderAlias 
protected java.lang.String | messageString
protected java.lang.Long | timestamp 


## Example


```java

	public class MyTextChatActivity extends Activity implements IM.IMListener {

		@Override
    	protected void onCreate(Bundle savedInstanceState) {
        
        	Log.i(LOGTAG, "ONCREATE");
        	super.onCreate(savedInstanceState);	
			
			Session mSession = new Session(MyTextChatActivity.this,
                    API_KEY, SESSION_ID);
        	mSession.connect(TOKEN);

			Date date = new Date();

        	InstantMessaging mIM = new InstantMessaging(mSession);
        
        	mIm.setIMListener(this);

			ChatMessage mChatMessage = new ChatMessage.MessageBuilder(mSession.connectionId) //senderId
                       .senderAlias("Bob")
                       .messageString("Good morning!")
                       .timestamp(date.getTime())
                       .build();

			mIm.sendMessage(mChatMessage);

		}

		@Override
    	public void onIncomingMessage(ChatMessage message) {
    		Log.i("IM", "Message from " + message.getSenderAlias() + " has been received:" + message.getMessageString());
    	}

    	@Override
    	public void onError(error) {
    		Log.i("IM", "Error sending a message. " + error.getMessage());
    	}
   		
	}
}

}
```