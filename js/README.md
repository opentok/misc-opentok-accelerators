![logo](../tokbox-logo.png)

# OpenTok Annotation Accelerator Pack for JavaScript<br/>Version 1.1

## Quick start

This section shows you how to prepare and use the OpenTok Annotations Accelerator Pack as part of an application.

### Deploying and running

The web page that loads the sample app for JavaScript must be served over HTTP/HTTPS. Browser security limitations prevent you from publishing video using a `file://` path, as discussed in the OpenTok.js [Release Notes](https://www.tokbox.com/developer/sdks/js/release-notes.html#knownIssues). To support clients running [Chrome 47 or later](https://groups.google.com/forum/#!topic/discuss-webrtc/sq5CVmY69sc), HTTPS is required. A [Node](https://nodejs.org/en/)web server will work, as will [MAMP](https://www.mamp.info/) or [XAMPP](https://www.apachefriends.org/index.html). You can use a cloud service such as [Heroku](https://www.heroku.com/) to host the application.

## Explore the code

For an example of how to use this accelerator pack in an application, see the [Screen Sharing Annotation Sample App](https://github.com/opentok/one-to-one-screen-annotations-sample-apps/tree/master/JS)

For more information, see [Initialize, Connect, and Publish to a Session](https://tokbox.com/developer/concepts/connect-and-publish/).

### Initializing the Accelerator Pack

You can get the accelerator pack via [npm](https://www.npmjs.com/package/opentok-annotation) or [Github](https://github.com/opentok/annotation-acc-pack/blob/master/js/opentok.js-annotations/dist/opentok-annotation.js). If using npm and a bundler like webpack or browserify , you can require the annotation accelerator pack:

```javascript
var annotationAccPack = require(‘opentok-annotation’);
```
Otherwise, you'll need to include the file in your html to make the constructor available in global scope.

The following `options` fields are used in the `AnnotationAccPack` constructor:<br/>

| Feature        | Field  | Required |
| ------------- | ------------- | -----|
| Set the OpenTok session  (object).| `session` |`true`|
| Set the Common layer API (object). | `accPack` |`false`|
| Set the callback to receive the image data on screen capture (function). | `onScreenCapture` |`false`|

To initialize the accelerator pack:

```javascript
var annotation = new annotationAccPack(options);
```

Once initialized, the following methods are available:

### `start`
*Creates an external window (if required) and links the annotation toolbar to the session.  An external window is ONLY required if sharing the current browser window. *
```javascript
@param {Object} session
@param {Object} [options]
@param {Boolean} [options.screensharing] - Using an external window
@param {Array} [options.items] - Custom set of tools
@param {Array} [options.colors] - Custom color palette
@returns {Promise} < Resolve: undefined | {Object} Reference to external annotation window >
```

### `linkCanvas`
*Create and link a canvas to the toolbar and session.  See notes about [resizing the canvas](#resizing-canvas) below*
```javascript
@param {Object} pubSub - Either the publisher(sharing) or subscriber(viewing)
@param {Object} container - The parent container for the canvas element
@param {Object} options
@param {Object} [options.externalWindow] - Reference to the an external annotation window (publisher only)
@param {Object} [options.absoluteParent] - Reference element for resize if other than container
```

### `resizeCanvas`
*Trigger a manual resize of the canvas.*

### `addSubscriberToExternalWindow`
*Add a subscriber's video to the external annotation window.*
```javascript
@param {Object} stream - The subscriber stream object
```

### `end`
*End annotation, clean up the toolbar and canvas(es)*

***
The `AnnotationAccPack`  triggers the following events via the common layer:

| Event        | Description  |
| ------------- | ------------- |
| `startAnnotation` | Annotation linked to session and toolbar created.|
| `linkAnnotation ` | Annotation canvas has been linked to the toolbar. |
| `resizeCanvas` | The annotation canvas has been resized. |
| `annotationWindowClosed` (screen sharing only)  | The external annotation window has been closed.|
| `endAnnotation` | Annotation has ended.  Toolbar and canvases have been cleaned up. |


If using the common layer, you can subscribe to these events by calling `registerEventListener` on  `_accPack` and providing a callback function:

```javascript
_accPack.registerEventListener('eventName', callback)
```


### Best Practices for Resizing the Canvas
<a name="resizing-canvas"></a>

The `linkCanvas` method refers to a parent DOM element called the `absoluteParent`.  When resizing the canvas, the annotation accelerator pack also resizes the canvas container element using inline properties.  Because of this, we need another element to reference for dimensions.  For this, we use the `absoluteParent`.

## Requirements

To develop a screen a web-based application that uses the OpenTok Annotations Accelerator Pack for JavaScript:

1. Review the basic requirements for [OpenTok](https://tokbox.com/developer/requirements/) and [OpenTok.js](https://tokbox.com/developer/sdks/js/#browsers).
1. Include [jQuery](https://jquery.com/) and [Underscore](http://underscorejs.org/).
1. Install the OpenTok Annotations Accelerator Pack: <ol><li>Install with [npm](https://www.npmjs.com/package/opentok-annotation).</li><li>Run the [build.sh script](./build.sh).</li><li>Download and extract the **annotation-acc-pack.js** file from the [zip](https://s3.amazonaws.com/artifact.tokbox.com/solution/rel/annotations/JS/opentok-js-annotations-1.1.0.zip) file provided by TokBox.</li></ol>
1. Code the web page to load [OpenTok.js](https://tokbox.com/developer/sdks/js/) first, and then load [opentok-annotations.js](./sample-app/public/js/components/opentok-annotation.js).
