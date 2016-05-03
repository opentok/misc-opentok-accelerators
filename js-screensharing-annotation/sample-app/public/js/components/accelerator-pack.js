var AcceleratorPack = (function() {

  var self;
  var _session;
  var _isConnected = false;
  var _active = false;

  var _communication;
  var _screensharing;
  var _annotation;
  var _components = {};

  var _commonOptions = {
    subscribers: [],
    streams: [],
    localCallProperties: {
      insertMode: 'append',
      width: '100%',
      height: '100%',
      showControls: false,
      style: {
        buttonDisplayMode: 'off'
      }
    },
    localScreenProperties: {
      insertMode: 'append',
      width: '100%',
      height: '100%',
      videoSource: 'window',
      showControls: false,
      style: {
        buttonDisplayMode: 'off'
      }
    }
  };

  /**
   * @constructor
   * Provides a common layer for logic and API for accelerator pack components
   */
  var AcceleratorPackLayer = function(options) {

    self = this;
    self.options = _validateOptions(options);

    // Get session
    _session = OT.initSession(options.apiKey, options.sessionId);

    // Connect
    _session.connect(options.token, function(error) {
      if (error) {
        console.log('Session failed to connect');
      } else {
        _isConnected = true;
      }
    });

    registerEventListener('startCall', _initAccPackComponents);

  };

  /** 
   * Initialize any of the accelerator pack components included in the application.
   */
  var _initAccPackComponents = _.once(function() {

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
      _annotation = new AccPackAnnotation(_.extend({}, self.options, { accPack: self }));
      _components.annotation = _annotation;
    }

    _componentsInitialized = true;
    _setupEventListeners();
  });

  /** Eventing */
  var _events = {}; // {eventName: [callbacks functions . . .]}
  var _isRegisteredEvent = _.partial(_.has, _events);
  
  /** 
   * Register events that can be listened to be other components/modules
   * @param {array | string} events - A list of event names. A single event may
   * also be passed as a string.
   * @returns {function} See _triggerEvent
   */
  var registerEvents = function(events) {

    events = Array.isArray(events) ? events : [events];

    _.each(events, function(event) {
      if (!_isRegisteredEvent(event)) {
        _events[event] = [];
      }
    });

    return _triggerEvent;
  };

  /** 
   * Register an event listener with the AP layer
   * @param {string} event - The name of the event
   * @param {function} callback - The function invoked upon the event
   */
  var registerEventListener = function(event, callback) {

    if (typeof callback !== 'function') {
      throw new Error('Provided callback is not a function');
    }

    if (!_isRegisteredEvent(event)) {
      registerEvents(event);
    }

    _events[event].push(callback);
  };

  /** 
   * Fire all registered callbacks for a given event.
   * @param {string} event - The event name
   * @param {*} data - Data to be passed to the callback functions
   */
  var _triggerEvent = function(event, data) {
    if (_.has(_events, event)) {
      _.each(_events[event], function(fn) {
        fn(data);
      });
    }
  };

  var _setupEventListeners = function() {
    registerEventListener('startViewingSharedScreen', setupAnnotationView);
    registerEventListener('endViewingSharedScreen', endAnnotationView);
    registerEventListener('endScreenSharing', endExternalAnnotation);
  };

  /** 
   * @param [string] type - A subset of common options
   */
  var getOptions = function(type) {

    return type ? _commonOptions[type] : _commonOptions;

  };

  // /**
  //  * When the call ends, we need to hide certain DOM elements related to the
  //  * components and may also need to do some cleanup related to publishers,
  //  * subscribers, etc.
  //  */
  // var _hideAccPackComponents = function() {

  //   _.each(_components, function(component) {
  //     // component.active(false);
  //   });
  // };

  var _validateOptions = function(options) {

    var requiredProps = ['sessionId', 'apiKey', 'token'];

    _.each(requiredProps, function(prop) {
      if (!_.property(prop)(options)) {
        throw new Error('Accelerator Pack requires a session ID, apiKey, and token')
      }
    });

    return options
  };

  /**
   * Returns the current session
   */
  var getSession = function() {
    return _session;
  };

  /** 
   * Initialize the annotation component for use in external window
   * @returns {Promise} < Resolve: [Object] External annotation window >    
   */
  var setupExternalAnnotation = function() {
    return _annotation.start(_session, { screensharing: true });
  };
  
  /** 
   * Initialize the annotation component for use in external window
   * @returns {Promise} < Resolve: [Object] External annotation window >    
   */
  var endExternalAnnotation = function() {
    return _annotation.end();
  };

  /** 
   * Initialize the annotation component for use in current window
   * @returns {Promise} < Resolve: [Object] External annotation window >    
   */
  var setupAnnotationView = function(subscriber) {
    var canvasContainer = document.getElementById('videoHolderSharedScreen');
    var annotationOptions = { canvasContainer: canvasContainer };
    _annotation.start(_session, annotationOptions)
      .then(function() {
        var mainContainer = document.getElementById('main');
        mainContainer.classList.add('aspect-ratio');
        _annotation.linkCanvas(subscriber, canvasContainer, null);
        _annotation.resizeCanvas();
      });
  };
  
  /** 
   * Initialize the annotation component for use in current window
   * @returns {Promise} < Resolve: [Object] External annotation window >    
   */
  var endAnnotationView = function() {
    _annotation.end();
    var mainContainer = document.getElementById('main');
    mainContainer.classList.remove('aspect-ratio');  
  };

  /** 
   * Connect the annotation canvas to the publisher or subscriber
   * @param {Object} pubSub - The publisher or subscriber
   * @param {Object} annotationContainer
   * @param [Object] externalWindow
   * 
   */
  var linkAnnotation = function(pubSub, annotationContainer, externalWindow) {
    _annotation.linkCanvas(pubSub, annotationContainer, externalWindow);
  };

  AcceleratorPackLayer.prototype = {
    constructor: AcceleratorPack,
    registerEvents: registerEvents,
    registerEventListener: registerEventListener,
    getSession: getSession,
    getOptions: getOptions,
    setupAnnotationView: setupAnnotationView,
    setupExternalAnnotation: setupExternalAnnotation,
    linkAnnotation: linkAnnotation
  };
  return AcceleratorPackLayer;
})();