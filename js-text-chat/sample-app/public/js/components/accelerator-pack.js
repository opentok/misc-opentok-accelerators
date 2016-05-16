var AcceleratorPack = (function() {

  var _this;
  var _session;
  var _isConnected = false;
  var _active = false;

  var _communication;
  var _textChat;

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

    _this = this;
    _this.options = _validateOptions(options);

    // Get session
    _session = OT.initSession(options.apiKey, options.sessionId);

    _registerSessionEvents()

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
    
    TextChatAccPack = window.TextChatAccPack || null;
    if (!!TextChatAccPack) {
      
      var textChatOptions = {
        accPack: _this,
        sender : _.extend(_this.options.textChat.sender, {id: _session.id}),
        limitCharacterMessage: _this.options.textChat.limitCharacterMessage,
        controlsContainer: _this.options.textChat.controlsContainer,
        textChatContainer: _this.options.textChat.textChatContainer
      };
      
      _textChat = new TextChatAccPack(textChatOptions);
    }

    _componentsInitialized = true;
    _setupEventListeners();
  });

  /** Eventing */

  var _registerSessionEvents = function() {

    registerEvents(['streamCreated', 'streamDestroyed']);

    _session.on({
      streamCreated: function(event) {
        _triggerEvent('streamCreated', event)
      },
      streamDestroyed: function(event) {
        _triggerEvent('streamDestroyed', event)
      }
    });
  }

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
   * Stop a callback from being fired when an event is triggered
   * @param {string} event - The name of the event
   * @param {function} callback - The function invoked upon the event
   */  
  var removeEventListener = function(event, callback) {
    
    if (typeof callback !== 'function') {
      throw new Error('Provided callback is not a function');
    }
    
    var listeners = _events[event];
    
    if (!listeners || !listeners.length) {
      return;
    }
    
    var index = listeners.indexOf(callback);
    
    if ( index !== -1 ) {
      listeners.splice(index, 1);
    }
    
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
    //register event listeners here for common layer
  };

  /** 
   * @param [string] type - A subset of common options
   */
  var getOptions = function(type) {

    return type ? _commonOptions[type] : _commonOptions;

  };
  
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
    
  AcceleratorPackLayer.prototype = {
    constructor: AcceleratorPack,
    registerEvents: registerEvents,
    registerEventListener: registerEventListener,
    getSession: getSession,
    getOptions: getOptions
  };
  return AcceleratorPackLayer;
})();
