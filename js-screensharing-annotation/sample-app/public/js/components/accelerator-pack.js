var AcceleratorPack = (function() {

    var self;
    var _session;
    var _isConnected = false;
    var _screensharing;
    var _annotation;

    // Constructor
    var AcceleratorPackLayer = function(options) {
        
        self = this;
        
        _validateOptions(options);
        self.options = options;
        
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
            if ( !_.property(prop)(options) ) {
                throw new Error('Accelerator Pack requires a session ID, apiKey, and token')
            }
        });
    };

    var addScreenSharingListeners = function() {
        var dialog;
        var self = this;

        $(self.options.comms_elements.installButtonPluginChrome).bind('click', function() {
            chrome.webstore.install('https://chrome.google.com/webstore/detail/' + self.options.extensionID,
                function(success) {
                    console.log('success', success);
                },
                function(error) {
                    console.log('error', error);
                });
            $('#dialog-form-chrome').toggle();
        });
        $(self.options.comms_elements.cancelButtonPluginChrome).bind('click', function() {
            $('#dialog-form-chrome').toggle();
        });
        $(self.comms_elements.installButtonPluginFF).prop('href', this.options.mainPath + self.options.extensionPathFF);
        $(self.options.comms_elements.installButtonPluginFF).bind('click', function() {
            $('#dialog-form-ff').toggle();
        });
        $(self.options.comms_elements.cancelButtonPluginFF).bind('click', function() {
            $('#dialog-form-ff').toggle();
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
    
    
    /** 
     * Initialize the annotation component
     * @param {Boolean} screensharing - If annotation is being done over the shared screen,
     * the annotation component will need to create an external window.
     * @returns {Promise} < Resolve: [Object] External annotation window >    
     */
    var initAnnotation = function (screensharing) {
        _annotation = _annotation || new AnnotationAccPack(options);
        
        return _annotation.start(_session, {screensharing: screensharing});
        
    };
    
    /** 
     * Connect the annotation canvas to the publisher or subscriber
     * @param {Object} pubSub - The publisher or subscriber
     * @param {Object} annotationContainer
     * @param [Object] externalWindow
     * 
     */
    var linkAnnotation = function(pubSub, annotationContainer, externalWindow){
        _annotation.linkCanvas(pubSub, annotationContainer, externalWindow);
    };
    
    

    // Start from WMS
    var startScreenSharing = function() { 
        
        var optionsProps = [
            'sessionID',
            'annotation',
            'extensionURL',
            'extensionID',
            'extensionPathFF',
            'screensharingContainer'
        ];
        
        var options = _.extend(_.pick(self.options, 'sessionId'), self.options.screensharing, {session: _session, acceleratorPack: self});
        
        if ( !!options.annotation ) {
            // Need to see what these options need to be
            _initAnnotation(options);
            // Pass the annotation acc pack to the screensharing acc pack (I DONT Like this)cc
            // options.annotation = _annotation;
        }
        _screensharing = _screensharing || new ScreenSharingAccPack(options);
        
        
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