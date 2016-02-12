# OpenTok TextChat

OpenTok TextChat is a component for OpenTok to provide both a library and basic web UI to implement text chat capabilities in your application.

## Installation

```
$ bower install opentok-text-chat
```

## Express chat integration

Include the OpenTok chat component after the OpenTok library:

```html
<script src="dist/opentok-text-chat.js"></script>
<link rel="stylesheet" href="css/opentok-textchat.css" />
```

To setup the chat, you need an already initialised OpenTok session:

```js
var session = OT.initSession(apiKey, sessionId);
var chat = new OTSolution.TextChat.ChatWidget({ session: session });
```

The `session` key is mandatory but the session object is not required to be connected. Althought, if session is not connected, the UI won't allow the user to enter any message until connected.

If you're wondering how the chat knows which name to pick for your client chat or maybe you want to customise the widget, take a look at [the annotated sources for the `ChatWidget` class](http://cdn.rawgit.com/opentok/opentok-text-chat/master/docs/examples/ChatWidget.html).

## The demo

Go to your OpenTok dashboard and generate a session id and a couple of tokens with different names (i.e. `Alice` and `Bob`). Edit the `index.html` and replace the session id, tokens and put your API key. Then save the file, exit the editor and run:

```
$ gulp demo
```

This will start a server allowing you to test the chat component.

Enjoy!

## Read the docs

Here you'll find the [complete documentation](https://cdn.rawgit.com/opentok/opentok-text-chat/master/docs/index.html) of the latest version of the library.

## Using the library

The chat widget uses the OpenTok Chat library provided as a part of this component. This class allow you to create a local chat client for a session. The local client always broadcast the messages message to all other participants connected to the session.

### Creating the chat

To connect chat with a session you use:

```js
var chat = new OTSolution.TextChat.Chat({ session: session });
```

The `session` parameter is mandatory and it must be a connected session. Not passing a `session` or passing a not connected session results in a runtime exception.

### Sending a message

Use the `Chat#send()` method to send a message to other participants:

```js
chat.send('Hi folks!')
```

### Receiving messages

Provide `Chat#onMessageReceived(contents, from)` to handle a message from the
chat.

```js
chat.onMessageReceived = function (contents, from) {
  var name = from.data;
  console.log(name, ' says:', contents);
});
```

### Customizing signal type

OpenTok Chat uses the signal API to send messages. The type of the signal defaults to `TextChat` but this can be customized by passing the `signalName` key to the configuration object when instantiating the chat client.

```js
var chat = new OTSolution.TextChat.Chat({
  session: session,
  signalName: 'MyCustomSignal'
});
```

## Getting the sources

Just clone this repository and make:

```
$ npm install
```

You need `gulp` globally installed. If you don't have it, use:

```
# npm install -g gulp
```

## Gulp commands

To bundle a new version use:

```
$ gulp dist
```

For documentation only, use:

```
$ gulp docs
```

And to simply pass the tests, use:

```
$ gulp tests
```

If you want to contribute, you can run:

```
$ gulp
```

Then start coding, this task will monitorize spec and source files and rerun tests if there is some change.
