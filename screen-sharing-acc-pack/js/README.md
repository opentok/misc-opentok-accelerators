![logo](../tokbox-logo.png)

# OpenTok Screensharing Accelerator Pack for JavaScript<br/>Version 1.1

## Quick start

This section shows you how to use the accelerator pack.

This section shows you how to:
* Review the sample app to see how it uses this accelerator pack.
* Import the accelerator pack into a project you are developing.

### Review how the sample app uses the acc pack

To learn how to use the acc pack, download and review the sample app:

1. Visit the [OpenTok Screensharing with Annotations Sample App](https://github.com/opentok/one-to-one-screen-annotations-sample-apps).
1. Follow the instructions downloading and deploying the sample app.
1. Look at the sample app code in the `*./one-to-one-screen-annotations-sample-apps/JS/sample-app' subfolder.


### Install the acc pack files

Install with npm:

```bash
$ npm install --save opentok-screen-sharing
```

If you are using browserify or webpack:

```javascript
const screenSharing = require('opentok-screen-sharing');
```

Otherwise, you'll need to include the accelerator pack in your html:

```html
<script src="../your/path/to/opentok-screen-sharing.js"></script>
```
 . . . and it will be available in global scope as `ScreenSharingAccPack`

-----------------

Click [here](https://www.npmjs.com/search?q=opentok-acc-pack) for a list of all npm OpenTok accelerator packs.


### Deploying and running

The web page that loads the sample app for JavaScript must be served over HTTP/HTTPS. Browser security limitations prevent you from publishing video using a `file://` path, as discussed in the OpenTok.js [Release Notes](https://www.tokbox.com/developer/sdks/js/release-notes.html#knownIssues). To support clients running [Chrome 47 or later](https://groups.google.com/forum/#!topic/discuss-webrtc/sq5CVmY69sc), HTTPS is required. A [Node](https://nodejs.org/en/) server will work, as will [MAMP](https://www.mamp.info/) or [XAMPP](https://www.apachefriends.org/index.html).  You can use a cloud service such as [Heroku](https://www.heroku.com/) to host the application.

## Exploring the code

This section describes how the sample app code design uses recommended best practices to deploy the screen sharing features.

For detail about the APIs used to develop this sample, see the [OpenTok.js Reference](https://tokbox.com/developer/sdks/js/reference/).

  - [Web page design](#web-page-design)
  - [Screen Share Accelerator Pack](#screen-share-accelerator-pack)

_**NOTE:** The sample app contains logic used for logging. This is used to submit anonymous usage data for internal TokBox purposes only. We request that you do not modify or remove any logging code in your use of this sample application._

### Web page design

While TokBox hosts [OpenTok.js](https://tokbox.com/developer/sdks/js/), you must host the sample app yourself. This allows you to customize the app as desired. The sample app has the following design, focusing primarily on the screen share features. For details about the one-to-one audio-video communication, see the [OpenTok One-to-One Communication Sample App](https://github.com/opentok/one-to-one-sample-apps/tree/master/one-to-one-sample-app/js).

* **[accelerator-pack.js](./sample-app/public/js/components/accelerator-pack.js)**: A common layer used to manage multiple accelerator packs.  This layer also provides an API which allows communication between the client and individual accelerator packs via methods and events.

* **[app.js](./sample-app/public/js/app.js)**: Stores the information required to configure the session and authorize the app to make requests to the backend server, manages the client connection to the OpenTok session, and handles UI changes in response to events.

* **[screen-share.css](./opentok.js-screen-sharing/css/screen-share.css)**: Defines the client UI style.

* **[index.html](./sample-app/public/index.html)**: This web page provides you with a quick start if you don't already have a web page making calls against OpenTok.js (via accelerator-pack.js) and screen-share-acc-pack.js. Its `<head>` element loads the OpenTok.js library, Screen Share library, and other dependencies, and its `<body>` element implements the UI container for the controls on your own page. It contains the tag script to load the otkanalytics.js file.

```javascript

    <!-- CSS -->
    <link rel="stylesheet" href="css/theme.css">

    <!--JS-->
    <script src="https://assets.tokbox.com/otkanalytics.js" type="text/javascript" defer></script>
    <script src="js/components/screen-share-acc-pack.js" type="text/javascript" defer></script>
    <script src="js/components/accelerator-pack.js" type="text/javascript" defer></script>

```

### Screen Share Accelerator Pack

The `ScreenShareAccPack` class in opentok-screen-sharing.js is the backbone of the screen share feature for the app.

This class sets up the screen share UI views and events, and provides functions for sending, receiving, and rendering shared screens.

#### Initialization

The following `options` fields are used in the `ScreenShareAccPack` constructor:<br/>

 Feature        | Field  | Required
 ------------- | ------------- | ------------
 Set the OpenTok session  (object).| `session` |`true`
 Set the screen container (string). | `screenSharingContainer`  |`false`
 Set the Common layer API (object). | `accPack` |`false`
 Set the ID of the Chrome extension (string). | `extensionID` |`false`
 Set the download path for the FireFox extension (string). | `extentionPathFF` |`false`
 Set the container to append the start/stop button (string).| `controlsContainer` |`false`
Set custom properties for the publisher (object)| `screenProperties`|`false`
Allow screen sharing over `http` in development (boolean)| `dev`|`false`


Once you define the options, you simply create a new instance of the  `ScreenShareAccPack`:

```javascript
      var screenShareOptions = {
       accPack: _this,
       session: _session,
       extensionID: _options.screenShare.extensionID,
       extentionPathFF: _options.screenShare.extentionPathFF,
       screensharingParent: _options.screenShare.screensharingParent,
     };

     var screenSharing = new ScreenShareAccPack(screenShareOptions);
```


#### ScreenShareAccPack Methods

The `ScreenShareAccPack` component has the following methods:

| Method        | Description  |
| ------------- | ------------- |
| `extensionAvailable()` | 	Test whether an extension is available.  |
| `start()` | Start sharing screen.  |
| `end()` | Stop sharing screen.  |


#### Events

The `ScreenSharingAccPack` component emits the following events:

 Event        | Description
 ------------- | -------------
 `startScreenSharing ` | We've started publishing/sharing the screen.
 `endScreenSharing ` | We've stopped publishing/sharing the screen.
 `screenSharingError ` | A screen sharing error occurred.


If using the common layer, you can subscribe to these events by calling `registerEventListener` on  `_accPack` and providing a callback function:

```javascript
_accPack.registerEventListener('eventName', callback)
```

### Requirements

To develop a web-based application that uses the OpenTok Screensharing Accelerator Pack for JavaScript:

1. Review the basic requirements for [OpenTok](https://tokbox.com/developer/requirements/) and [OpenTok.js](https://tokbox.com/developer/sdks/js/#browsers).
1. Include [jQuery](https://jquery.com/) and [Underscore](http://underscorejs.org/) in your project.
1. Configure your web page to load `OpenTok.js` first, before loading `opentok-screen-sharing.js` and any other `*.js` files.