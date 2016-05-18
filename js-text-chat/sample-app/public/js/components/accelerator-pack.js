/* global OT TextChatAccPack define */
(function () {

  var _this;
  var _session;
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
   * Private methods
   */

  /** Eventing */
  var _events = {}; // {eventName: [callbacks functions . . .]}
  var _isRegisteredEvent = _.partial(_.has, _events);

  /**
   * Register events that can be listened to be other components/modules
   * @param {array | string} events - A list of event names. A single event may
   * also be passed as a string.
   * @returns {function} See triggerEvent
   */
  var registerEvents = function (events) {

    var eventList = Array.isArray(events) ? events : [events];

    _.each(eventList, function (event) {
      if (!_isRegisteredEvent(event)) {
        _events[event] = [];
      }
    });

  };

  /**
   * Register an event listener with the AP layer
   * @param {string} event - The name of the event
   * @param {function} callback - The function invoked upon the event
   */
  var registerEventListener = function (event, callback) {

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
  var removeEventListener = function (event, callback) {

    if (typeof callback !== 'function') {
      throw new Error('Provided callback is not a function');
    }

    var listeners = _events[event];

    if (!listeners || !listeners.length) {
      return;
    }

    var index = listeners.indexOf(callback);

    if (index !== -1) {
      listeners.splice(index, 1);
    }

  };

  /**
   * Fire all registered callbacks for a given event
   * @param {string} event - The event name
   * @param {*} data - Data to be passed to the callback functions
   */
  var triggerEvent = function (event, data) {
    if (_.has(_events, event)) {
      _.each(_events[event], function (fn) {
        fn(data);
      });
    }
  };

  var _registerSessionEvents = function () {

    registerEvents(['streamCreated', 'streamDestroyed', 'sessionError']);

    _session.on({
      streamCreated: function (event) {
        triggerEvent('streamCreated', event);
      },
      streamDestroyed: function (event) {
        triggerEvent('streamDestroyed', event);
      }
    });
  };


  var _setupEventListeners = function () {
    // Register event listeners here for common layer
  };

  /**
   * @param [string] type - A subset of common options
   */
  var getOptions = function (type) {

    return type ? _commonOptions[type] : _commonOptions;

  };

  var _validateOptions = function (options) {

    var requiredProps = ['sessionId', 'apiKey', 'token'];

    _.each(requiredProps, function (prop) {
      if (!_.property(prop)(options)) {
        throw new Error('Accelerator Pack requires a session ID, apiKey, and token');
      }
    });

    return options;
  };

  /**
   * Initialize any of the accelerator pack components included in the application.
   */
  var _initAccPackComponents = _.once(function () {

    if (!!TextChatAccPack) {


      // Returns session id prepended and appended with unique strings
      var generateUserId = function () {

        // Generates a random alpha-numeric string
        var uniqueString = function (length) {
          var len = length || 3;
          return Math.random().toString(36).substr(2, len);
        };

        return [uniqueString(), _session.id, uniqueString()].join('');
      };

      var textChatOptions = {
        accPack: _this,
        session: _session,
        sender: _.defaults(_this.options.textChat.sender, {
          id: generateUserId()
        }),
        limitCharacterMessage: _this.options.textChat.limitCharacterMessage,
        controlsContainer: _this.options.textChat.controlsContainer,
        textChatContainer: _this.options.textChat.textChatContainer
      };

      _components.textChat = new TextChatAccPack(textChatOptions);
    }

    _setupEventListeners();
  });

  /**
   * Returns the current session
   */
  var getSession = function () {
    return _session;
  };

  /**
   * @constructor
   * Provides a common layer for logic and API for accelerator pack components
   */
  var AcceleratorPack = function (options) {

    _this = this;
    _this.options = _validateOptions(options);

    _session = OT.initSession(options.apiKey, options.sessionId);
    _registerSessionEvents();

    // Connect
    _session.connect(options.token, function (error) {
      if (error) {
        triggerEvent('sessionError', error);
      }
    });

    registerEventListener('startCall', _initAccPackComponents);

  };

  AcceleratorPack.prototype = {
    constructor: AcceleratorPack,
    registerEvents: registerEvents,
    triggerEvent: triggerEvent,
    registerEventListener: registerEventListener,
    removeEventListener: removeEventListener,
    getSession: getSession,
    getOptions: getOptions
  };

  if (typeof exports === 'object') {
    module.exports = AcceleratorPack;
  } else if (typeof define === 'function' && define.amd) {
    define(function () {
      return AcceleratorPack;
    });
  } else {
    this.AcceleratorPack = AcceleratorPack;
  }

}.call(this));
