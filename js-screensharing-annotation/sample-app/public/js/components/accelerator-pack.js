var AcceleratorPack = (function() {

    var _session;
    var _isConnected = false;
    var _screensharing;
    var _annotation;

    // Constructor
    var AcceleratorPackLayer = function(apiKey, sessionId, token) {
        // Get session
        _session = OT.initSession(apiKey, sessionId);
        self = this;
        // Connect
        _session.connect(token, function(error) {
            if (error) {
                console.log('Session failed to connect');
            } else {
                // Add
                _screensharing = new ScreenSharingAccPack();
                _annoation = new AnnotationAccPack();
                _isConnected = true;
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

    AcceleratorPackLayer.prototype = {
        constructor: AcceleratorPack,

        getSession: function() {
            return _session;
        },
        connectScreenSharing: function() {

        },
        connectAnnotation: function() {
        
            // Need to pass container
        
        }
    };
    return AcceleratorPackLayer;
})();