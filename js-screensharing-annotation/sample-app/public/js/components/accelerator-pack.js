var AcceleratorPack = (function() {

    var self;
    var _session;
    var _isConnected = false;
    var _screensharing;
    var _annotation;

    var addThings = function(extensionID) {
        $('<link/>', {
            rel: 'chrome-webstore-item',
            href: ['https://chrome.google.com/webstore/detail/', extensionID].join('')
        }).appendTo('head');
    }

    // Constructor
    var AcceleratorPackLayer = function(options) {

        self = this;

        _validateOptions(options);
        self.options = options;

        // addThings(options.screensharing.extensionID);
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
    };

    var _validateOptions = function(options) {

        var requiredProps = ['sessionId', 'apiKey', 'token'];

        _.each(requiredProps, function(prop) {
            if (!_.property(prop)(options)) {
                throw new Error('Accelerator Pack requires a session ID, apiKey, and token')
            }
        });
    };

    var _initPublisherScreen = function() {


        var createPublisher = function(publisherDiv) {

            var innerDeferred = $.Deferred();

            publisherDiv = publisherDiv || 'videoHolderScreenShare';

            self.options.publishers.screen = OT.initPublisher(publisherDiv, self.options.localScreenProperties, function(error) {
                if (error) {
                    error.message = 'Error starting the screen sharing';
                    handler(error);
                    innerDeferred.reject(error);
                } else {
                    self.options.publishers.screen.on('streamDestroyed', this._publisherStreamDestroyed);
                    self.options.publishers.screen.on('mediaStopped', this._publisherStreamDestroyed);
                    self.options.publishers.screen.on('streamCreated', function(event) {
                        console.log('streamCreated publisher screen', event.stream);
                        screenStream = event.stream;
                    });
                    innerDeferred.resolve();
                }
            });

            return innerDeferred.promise();
        };

        var outerDeferred = $.Deferred();

        if (!!self._annotation) {
            self._annotation.start(self.session, {
                    externalWindow: true
                })
                .then(function() {
                    console.log('resolve annotation start');
                    var annotationWindow = self.comms_elements.annotationWindow;
                    var annotationElements = annotationWindow.createContainerElements();
                    createPublisher(annotationElements.publisher)
                        .then(function() {
                            outerDeferred.resolve(annotationElements.annotation);
                        });
                });
        } else {

            createPublisher()
                .then(function() {
                    outerDeferred.resolve();
                });
        }

        return outerDeferred.promise();
    };


    //ScreenSharing callbacks
    var _onScreenSharingStarted = function() {
        $(this.comms_elements.precallFeedWrap).addClass('hidden');
        // $(this.comms_elements.callFeedWrap).removeClass('hidden');
        $(this.comms_elements.shareScreenBtn).addClass('hidden');
        $(this.comms_elements.endShareScreenBtn).removeClass('hidden');

        // hide the call view
        $(this.comms_elements.callFeedWrap).addClass('hidden');

        // show the view for screen sharing
        $(this.comms_elements.screenShareView).removeClass('hidden');
    };

    var _onScreenSharingEnded = function(event) {
        console.log('on the method for onScreenSharingEnded');
        $(this.comms_elements.shareScreenBtn).removeClass('hidden');
        $(this.comms_elements.endShareScreenBtn).addClass('hidden');

        // show the call view
        $(this.comms_elements.callFeedWrap).removeClass('hidden');

        // hide the view for screen sharing
        $(this.comms_elements.screenShareView).addClass('hidden');
    };


    var _onScreenSharingError = function(error) {
        console.log(error.code, error.message);
        $(this.comms_elements.screenShareView).addClass('hidden');

        this._showWMSErrorFor('screenShare', error.message);
    };

    var setupAnnotationView = function() {
        var self = this;
        $(self.comms_elements.callFeedWrap).draggable('disable');
        self._annotation.resizeCanvas();
    };

    var getSession = function() {
        return _session;
    };

    /** 
     * Initialize the annotation component
     * @param {Boolean} screensharing - If annotation is being done over the shared screen,
     * the annotation component will need to create an external window.
     * @returns {Promise} < Resolve: [Object] External annotation window >    
     */
    var initAnnotation = function(screensharing) {
        _annotation = _annotation || new AccPackAnnotation(options);

        return _annotation.start(_session, { screensharing: screensharing });

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
        _screensharing = _screensharing || new AccPackScreenSharing(options);

        _screensharing.start();
    };

    var endScreenSharing = function() {
        _screensharing.end();
    };

    AcceleratorPackLayer.prototype = {
        constructor: AcceleratorPack,
        getSession: getSession,
        startScreenSharing: startScreenSharing,
        endScreenSharing: endScreenSharing,
        initAnnotation: initAnnotation,
        linkAnnotation: linkAnnotation
    };
    return AcceleratorPackLayer;
})();