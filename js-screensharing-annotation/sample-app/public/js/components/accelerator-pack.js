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
    
    var _startAnnotation = function (options) {
        _annotation = new AnnotationAccPack(options);
    };

    // Start from WMS
    var _startScreenSharing = function() { 
        
        var optionsProps = [
            'sessionID',
            'annotation',
            'extensionURL',
            'extensionID',
            'extensionPathFF',
            'screensharingContainer'
        ];
        
        var options = _.extend(_.pick(self.options, 'sessionId'), self.options.screensharing);
        
        _screensharing = _screensharing || new ScreenSharingAccPack(options);
        _screensharing.start();
    };

    var _endScreenSharing = function() {
        _screensharing.end();
    };

    AcceleratorPackLayer.prototype = {
        constructor: AcceleratorPack,

        getSession: function() {
            return _session;
        },
        startScreenSharing: function() {
            _startScreenSharing();
        },
        endScreenSharing: function() {
            _endScreenSharing();
        },
        connectAnnotation: function() {

            // Need to pass container

        }
    };
    return AcceleratorPackLayer;
})();