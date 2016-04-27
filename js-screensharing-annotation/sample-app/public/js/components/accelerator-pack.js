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
            _annotation = new AccPackAnnotation(_.extend({}, self.options, {accPack: self}));
            _components.annotation = _annotation;
        }

        _componentsInitialized = true;
        _setupEventListeners();
    });

    /** Eventing */ 
    var _events = {}; // {eventName: [callbacks functions . . .]}
    var _isRegisteredEvent = _.partial(_.has, _events);
    var _eventListeners = {};
    /** 
     * Register events that can be listened to be other components/modules
     * @param {array | string} events - A list of event names. A single event may
     * also be passed as a string.
     * @returns {function} See _triggerEvent
     */
    var registerEvents = function(events) {
        
        events =  Array.isArray(events) ? events : [events];
        
        _.each(events, function(event) {
            if ( !_isRegisteredEvent(event) ) {
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
        
        if ( !_isRegisteredEvent(event) ) {
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
    
    var _setupEventListeners = function(){
        registerEventListener('startViewingSharedScreen', setupAnnotationView);
    }

    /** 
     * @param [string] type - A subset of common options
     */
    var getOptions = function(type) {

        return type ? _commonOptions[type] : _commonOptions;

    };

    /**
     * When the call ends, we need to hide certain DOM elements related to the
     * components and may also need to do some cleanup related to publishers,
     * subscribers, etc.
     */
    var _hideAccPackComponents = function() {

        _.each(_components, function(component) {
            // component.active(false);
        });
    };

    var _validateOptions = function(options) {

        var requiredProps = ['sessionId', 'apiKey', 'token'];

        _.each(requiredProps, function(prop) {
            if (!_.property(prop)(options)) {
                throw new Error('Accelerator Pack requires a session ID, apiKey, and token')
            }
        });

        return options;
    };

    // var _initPublisherScreen = function() {

    //     var createPublisher = function(publisherDiv) {

    //         var innerDeferred = $.Deferred();

    //         publisherDiv = publisherDiv || 'videoHolderScreenShare';

    //         self.options.publishers.screen = OT.initPublisher(publisherDiv, _commonOptions.localScreenProperties, function(error) {
    //             if (error) {
    //                 error.message = 'Error starting the screen sharing';
    //                 handler(error);
    //                 innerDeferred.reject(error);
    //             } else {
    //                 self.options.publishers.screen.on('streamDestroyed', this._publisherStreamDestroyed);
    //                 self.options.publishers.screen.on('mediaStopped', this._publisherStreamDestroyed);
    //                 self.options.publishers.screen.on('streamCreated', function(event) {
    //                     console.log('streamCreated publisher screen', event.stream);
    //                     screenStream = event.stream;
    //                 });
    //                 innerDeferred.resolve();
    //             }
    //         });

    //         return innerDeferred.promise();
    //     };

    //     var outerDeferred = $.Deferred();

    //     if (!!self._annotation) {
    //         self._annotation.start(self.session, {
    //                 externalWindow: true
    //             })
    //             .then(function() {
    //                 console.log('resolve annotation start');
    //                 var annotationWindow = self.comms_elements.annotationWindow;
    //                 var annotationElements = annotationWindow.createContainerElements();
    //                 createPublisher(annotationElements.publisher)
    //                 .then(function() {
    //                     outerDeferred.resolve(annotationElements.annotation);
    //                 });
                    
    //                 _triggerEvent('startAnnotation');
    //             });
    //     } else {

    //         createPublisher()
    //             .then(function() {
    //                 outerDeferred.resolve();
    //             });
    //     }

    //     return outerDeferred.promise();
    // };


    //ScreenSharing callbacks
    // var _onScreenSharingStarted = function() {
    //     $(this.comms_elements.precallFeedWrap).addClass('hidden');
    //     // $(this.comms_elements.callFeedWrap).removeClass('hidden');
    //     $(this.comms_elements.shareScreenBtn).addClass('hidden');
    //     $(this.comms_elements.endShareScreenBtn).removeClass('hidden');

    //     // hide the call view
    //     $(this.comms_elements.callFeedWrap).addClass('hidden');

    //     // show the view for screen sharing
    //     $(this.comms_elements.screenShareView).removeClass('hidden');
    // };

    // var _onScreenSharingEnded = function(event) {
    //     console.log('on the method for onScreenSharingEnded');
    //     $(this.comms_elements.shareScreenBtn).removeClass('hidden');
    //     $(this.comms_elements.endShareScreenBtn).addClass('hidden');

    //     // show the call view
    //     $(this.comms_elements.callFeedWrap).removeClass('hidden');

    //     // hide the view for screen sharing
    //     $(this.comms_elements.screenShareView).addClass('hidden');
    // };

    // var setupAnnotationView = function() {
    //     self._annotation.resizeCanvas();
    // };




    /**
     * Returns the current session
     */
    var getSession = function() {
        return _session;
    };


    /**
     * Setter which lets the AP layer know the call is active or inactive.  In turn, we can
     * let the components know if they need to show or hide controls.
     */
    var active = function(active) {



    }

    /** 
     * Initialize the annotation component for use in external window
     * @returns {Promise} < Resolve: [Object] External annotation window >    
     */
    var setupExternalAnnotation = function() {
        return _annotation.start(_session, {screensharing: true});
    };
    
    /** 
     * Initialize the annotation component for use in current window
     * @returns {Promise} < Resolve: [Object] External annotation window >    
     */
    var setupAnnotationView = function(subscriber){
        _annotation.start(_session, {})
        .then(function(){
            var mainContainer = document.getElementById('main');
            mainContainer.classList.add('aspect-ratio');            
            _annotation.linkCanvas(subscriber, document.getElementById('videoHolderSharedScreen'));
            _annotation.resizeCanvas();
        });
    };

    /** 
     * Connect the annotation canvas to the publisher or subscriber
     * @param {Object} pubSub - The publisher or subscriber
     * @param {Object} annotationContainer
     * @param [Object] externalWindow
     * 
     */
    var linkAnnotation = function(pubSub, annotationContainer, externalWindow) {
        var called = linkAnnotation.caller;
        console.log('who called link canvas', called);
        _annotation.linkCanvas(pubSub, annotationContainer, externalWindow);
    };

    var startScreenSharing = function() {

        var optionsProps = [
            'sessionID',
            'annotation',
            'extensionURL',
            'extensionID',
            'extensionPathFF',
            'screensharingContainer'
        ];

        var options = _.extend(_.pick(self.options, 'sessionId'), self.options.screensharing, { session: _session, acceleratorPack: self });

        if (!!options.annotation) {
            // Need to see what these options need to be
            _initAnnotation(options);
        }

        _screensharing.start();
    };

    var endScreenSharing = function() {
        _screensharing.end();
    };

    AcceleratorPackLayer.prototype = {
        constructor: AcceleratorPack,
        registerEvents: registerEvents,
        registerEventListener: registerEventListener,
        active: active,
        getSession: getSession,
        getOptions: getOptions,
        startScreenSharing: startScreenSharing,
        endScreenSharing: endScreenSharing,
        setupAnnotationView: setupAnnotationView,
        setupExternalAnnotation: setupExternalAnnotation,
        linkAnnotation: linkAnnotation
    };
    return AcceleratorPackLayer;
})();