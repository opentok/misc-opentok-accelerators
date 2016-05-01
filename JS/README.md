![logo](tokbox-logo.png)
# OpenTok Annotations with Screensharing Accelerator Pack for JavaScript<br/>Version 1.0

This document describes how to develop a web-based application that uses the OpenTok Annotations with Screensharing Accelerator Pack for JavaScript.

This guide has the following sections:

- [Prerequisites](#prerequisites): A checklist of everything you need to get started.
- Download the accelerator pack: Download and use the OpenTok Annotations with Screensharing Accelerator Pack provided to you by TokBox for use in your own development.
- [Deploy](#deploy): Deploy your own application that hosts the Annotations with Screensharing Accelerator.
- [Explore the code](#explore-the-code): This describes the sample app code design, which uses recommended best practices to create a working implementation that uses the Annotations with Screensharing Accelerator.


## Prerequisites

To be prepared to develop a web-based application that uses the OpenTok Annotations with Screensharing Accelerator for JavaScript:

1. Review the basic requirements for [OpenTok](https://tokbox.com/developer/requirements/) and [OpenTok.js](https://tokbox.com/developer/sdks/js/#browsers).
2. Your web page must load [OpenTok.js](https://tokbox.com/developer/sdks/js/) first, and then load [opentok-annotations.js](./sample-app/public/js/components/opentok-annotation.js) and [screenshare-annotation-acc-pack.js](./sample-app/public/js/components/screenshare-annotation-acc-pack.js).  
3. Your app will need a **Session ID**, **Token**, and **API key**, which you can get at the [OpenTok Developer Dashboard](https://dashboard.tokbox.com). 

_**NOTE**: The OpenTok Developer Dashboard allows you to quickly run this sample program. For production deployment, you must generate the **Session ID** and **Token** values using the [OpenTok Server SDK](https://tokbox.com/developer/sdks/server/)._


## Deploy

The web page that loads the OpenTok Annotations with Screensharing example for JavaScript must be served over HTTP/HTTPS. Browser security limitations prevent you from publishing video using a `file://` path, as discussed in the OpenTok.js [Release Notes](https://www.tokbox.com/developer/sdks/js/release-notes.html#knownIssues). 

To support clients running [Chrome 47 or later](https://groups.google.com/forum/#!topic/discuss-webrtc/sq5CVmY69sc), HTTPS is required, though localhost Chrome clients are considered secure and HTTP is permitted in such cases. 

A web server such as [MAMP](https://www.mamp.info/) or [Apache](https://httpd.apache.org/) will work, or you can use a cloud service such as [Heroku](https://www.heroku.com/) to host the widget. 

## Explore the code

This section describes how the sample app code design uses recommended best practices to create a working implementation that uses the Annotations with Screensharing Accelerator. 

To develop your own application, follow this section to learn how to add the toolbar to your container and create an annotation canvas for both the publisher and subscriber. 

The following steps will help you get started, and you can refer to the [complete code example](./sample-app/public/index.html):

1. [Web page design](#web-page-design)
2. [Specifying the options](#specifying-the-options)
3. [Initializing the session](#initializing-the-session)
4. [Initializing the components](#initializing-the-components)

To learn more about the annotation widget, visit [OpenTok Annotations Widget for JavaScript](https://github.com/opentok/annotation-widget/tree/js). 


### Web page design

While TokBox hosts [OpenTok.js](https://tokbox.com/developer/sdks/js/), you must host the JavaScript Annotations widget yourself. This allows you to modify the widget as desired. The sample app has the following design

* **[app.js](./sample-app/public/js/app.js)**: This is where you specify the **Session ID**, **Token**, and **API key**. This file contains functionality supporting the view layer and button click events, initializes the session, instantiates the one-to-one communication layer, and listens for stream and call events.

* **[accelerator-pack.js](./sample-app/public/js/components/accelerator-pack.js)**: The TokBox Common Accelerator Session Pack is a common layer that permits all accelerators to share the same OpenTok session, API Key and other related information, and is required whenever you use any of the OpenTok accelerators. This layer handles communication between the client and any required components, such as screensharing and text chat, which are instantiated in this layer. Each component can define its own events, which are then registered in this common layer.

* **[opentok-annotation.js](./sample-app/public/js/components/opentok-annotation.js)**: This is the OpenTok Annotation Plugin. If you already have a website making calls against the OpenTok JavaScript client, you can simply download this file and the image files.

* **[screenshare-annotation-acc-pack.js](./sample-app/public/js/components/screenshare-annotation-acc-pack.js)**: _(Available only in the Annotations with Screensharing Accelerator Pack)._ Defines the annotation component that can be used with screensharing, the screensharing component, and the one-to-one communication layer used in the sample application. 

* **[screenshare.html](./sample-app/public/screenshare.html)**: The screen sharing container, which has its own toolbar and is displayed in a separate browser window.

* **[CSS files](./sample-app/public/css)**: Defines the client UI style.

* **[index.html](web/index.html)**: This web page provides you with a quick start if you don't already have a web page making calls against OpenTok.js (via accelerator-pack.js) and opentok-annotation.js. Its <head> element loads the OpenTok.js library, Annotation library, and other dependencies, and its <body> element implements the UI container for the controls on your own page.


### Specifying the options

In app.js, specify the **Session ID**, **Token**, and **API key** by editing the corresponding strings in `_options`:

```javascript
  var _options = {
    apiKey: '',
    sessionId: '',
    token: '',
```


### Initializing the session

The `init()` method in app.js initializes the session. It listens for the connection event and instantiates one-to-one communication:


```javascript
  var init = function() {
    // Get session
  var accPackOptions = _.pick(_options, ['apiKey', 'sessionId', 'token', 'screensharing']);
    
    _accPack = new AcceleratorPack(accPackOptions);
    _session = _accPack.getSession();
    _.extend(_options, _accPack.getOptions());

    _session.on({
      connectionCreated: function(event) {
        
        if ( _connected ) { return; } 
         
         _connected = true;
         
         var commOptions = _.extend({}, _options, {session: _session},  _accPack.getOptions());
         console.log(commOptions);
        _communication = new Communication(commOptions);
        _addEventListeners(); 
      }
    });
  };
```

For more information, see [Initialize, Connect, and Publish to a Session](https://tokbox.com/developer/concepts/connect-and-publish/).

### Initializing the components

The `_initAccPackComponents()` method in accelerator-pack.js initializes the components required by the application. In this example the screensharing and annotation components are initialized:


```javascript
    var _initAccPackComponents = function() {

        if (!!AccPackScreenSharing) {

            var screensharingProps = [
                'sessionId',
                'annotation',
                'extensionURL',
                'extensionID',
                'extensionPathFF',
                'screensharingContainer'
            ];

            var screensharingOptions = _.extend(_.pick(self.options, screensharingProps), self.options.screensharing, {
                session: _session,
                accPack: self,
                localScreenProperties: _commonOptions.localScreenProperties
            });

            _screensharing = new AccPackScreenSharing(screensharingOptions);
            _components.screensharing = _screensharing;
        }

        if (!!AccPackAnnotation) {
            var annotationProps = [];
            _annotation = new AccPackAnnotation(self.options);
            _components.annotation = _annotation;
        }
    };
```



