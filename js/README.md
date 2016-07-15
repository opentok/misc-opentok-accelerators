![logo](../tokbox-logo.png)

# OpenTok Annotations Accelerator Pack for JavaScript<br/>Version 1.0.0

This document describes how to use the OpenTok Annotations Accelerator Pack for JavaScript. Through the exploration of this Accelerator Pack, you will learn best practices for development and customization with annotations in a web-based application.

**Note**: The OpenTok Annotations Accelerator Pack does not include a standalone sample app such as [screensharing-annotation-acc-pack](https://github.com/opentok/screensharing-annotation-acc-pack), though you can easily build your own apps with it. It is also used as a component for more comprehensive Accelerator Packs that offer such features as screensharing and video along with annotations. 


This guide has the following sections:

- [Prerequisites](#prerequisites): A checklist of everything you need to get started.
- [Deploy](#deploy): Deploy your own application that hosts the OpenTok Annotations Accelerator.
- [Explore the code](#explore-the-code): This describes the Accelerator Pack code design, which uses recommended best practices to implement the annotation and frame grab capabilities available in the OpenTok client SDK.


## Prerequisites

To be prepared to develop a web-based application that uses the OpenTok Annotations Accelerator for JavaScript:

1. Review the basic requirements for [OpenTok](https://tokbox.com/developer/requirements/) and [OpenTok.js](https://tokbox.com/developer/sdks/js/#browsers).
2. Your project must include [jQuery](https://jquery.com/) and [Underscore](http://underscorejs.org/).
3. There are several ways to install the OpenTok Annotations Accelerator Pack: <ol><li>Install with [npm](https://www.npmjs.com/package/opentok-annotation).</li><li>Run the [build.sh script](./build.sh).</li><li>Download and extract the **annotation-acc-pack.js** file from the [zip](https://s3.amazonaws.com/artifact.tokbox.com/solution/rel/annotations/JS/opentok-js-annotations-1.0.0.zip) file provided by TokBox.</li></ol>
4. Your web page must load [OpenTok.js](https://tokbox.com/developer/sdks/js/) first, and then load [opentok-annotations.js](./sample-app/public/js/components/opentok-annotation.js).  
5. Your app will need a **Session ID**, **Token**, and **API key**, which you can get at the [OpenTok Developer Dashboard](https://dashboard.tokbox.com). 

_**NOTE**: The OpenTok Developer Dashboard allows you to quickly run this sample program. For production deployment, you must generate the **Session ID** and **Token** values using the [OpenTok Server SDK](https://tokbox.com/developer/sdks/server/)._


## Deploy

The web page that loads your app must be served over HTTP/HTTPS. Browser security limitations prevent you from publishing video using a `file://` path, as discussed in the OpenTok.js [Release Notes](https://www.tokbox.com/developer/sdks/js/release-notes.html#knownIssues). 

To support clients running [Chrome 47 or later](https://groups.google.com/forum/#!topic/discuss-webrtc/sq5CVmY69sc), HTTPS is required, though localhost Chrome clients are considered secure and HTTP is permitted in such cases. 

A web server such as [MAMP](https://www.mamp.info/) or [Apache](https://httpd.apache.org/) will work, or you can use a cloud service such as [Heroku](https://www.heroku.com/) to host the widget. 

## Explore the code

This section describes how the sample app code design uses recommended best practices to create a working implementation that uses the Screensharing with Annotations Accelerator. 

To develop your own application, follow this section to learn how to add the toolbar to your container and create an annotation canvas for both the publisher and subscriber. 

The following steps will help you get started, and you can refer to the [complete code example](./sample-app/public/index.html):

1. [Web page design](#web-page-design)
2. [Initializing the session](#initializing-the-session)
3. [Best Practices for Resizing the Canvas](#best-practices-for-resizing-the-canvas)

To learn more about the annotation widget, visit [OpenTok Annotations Widget for JavaScript](https://github.com/opentok/annotation-widget/tree/js). 


### Web page design

While TokBox hosts [OpenTok.js](https://tokbox.com/developer/sdks/js/), you must host the JavaScript Annotations widget yourself. You can specify toolbar items, colors, icons, and other options for the annotation widget via the common layer. The accelerator pack includes the following:

* **[acc-pack-annotation.js](./opentok.js-ss-annotation/src/acc-pack-annotation.js)**: This contains the constructor for the annotation component used over video or a shared screen.

* **[CSS files](./sample-app/public/css)**: Defines the client UI style.

* **[Images](./opentok.js-ss-annotation/images)**: This contains the default icons used in the annotation toolbar.


### Initializing the session

The `AnnotationAccPack` constructor, located in `acc-pack-annotation.js`, sets the `accPack` property to register, trigger, and start events via the common layer API used for all accelerator packs.

If you install the Annotation Accelerator Pack with [npm](https://www.npmjs.com/package/opentok-annotation), you can instantiate the `AnnotationAccPack` instance with this approach:

```javascript
const annotation = require(‘opentok-annotation’);
const annotationAccPack = new annotation(options);
```

Otherwise, this initialization code demonstrates how the `AnnotationAccPack` object is initialized:

```javascript
  // Trigger event via common layer API
  var _triggerEvent = function (event, data) {
    if (_accPack) {
      _accPack.triggerEvent(event, data);
    }
  };

  . . .

  var AnnotationAccPack = function (options) {
    _this = this;
    _this.options = _.omit(options, 'accPack');
    _accPack = _.property('accPack')(options); // Supports events in the common layer.
    _registerEvents();
    _setupUI();
  };
```

The events that may be triggered include:

 - Resizing the canvas
 - Closing the external annotation window
 - Starting an annotation
 - Linking the canvas to the annotation
 - Ending an annotation


For more information, see [Initialize, Connect, and Publish to a Session](https://tokbox.com/developer/concepts/connect-and-publish/).



### Best Practices for Resizing the Canvas

The `linkCanvas()` method, located in `acc-pack-annotation.js`, refers to a parent DOM element called the `absoluteParent`. This is needed in order to maintain accurate information needed to properly resize both the canvas and its container element as the window is resized. This is a recommended best practice that mitigates potential issues with jQuery in which information may be lost upon multiple resize attempts. 