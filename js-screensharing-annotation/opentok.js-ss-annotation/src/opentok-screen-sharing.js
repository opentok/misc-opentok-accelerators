var ScreenSharingAccPack = (function() {


    var self;
    var _annotation;
    var extensionAvailable;

    /** 
     * Screensharing accerlator pack constructor
     * @param {Object} options
     * @param {String} options.sessionID
     * @param [String] options.extensionID
     * @param [String] options.extentionPathFF
     * @param [String] options.screensharingParent 
     */

    var ScreenSharing = function(options) {

        self = this;

        console.log('options passed to screensharing things', options);

        // Check for required options
        _validateOptions(options);

        // Extend our instance
        var optionsProps = [
            'sessionID',
            'annotation',
            'extensionURL',
            'extensionID',
            'extensionPathFF',
            'screensharingParent'
        ];

        _.extend(this, _.defaults(_.pick(options, optionsProps)), { screenSharingParent: '#videoContainer' });
        
        // Register Chrome extension
        _registerExtension(this.extensionID);

        // Do UIy things
        _setupUI(self.screensharingParent);
    };

    var _validateExtension = function(extensionID, extensionPathFF) {

        if (OT.$.browser() === 'Chrome') {
            if (!extensionID || !extensionID.length) {
                throw new Error('Error starting the screensharing. Chrome extensionID required');
            } else {
                OT.registerScreenSharingExtension('chrome', extensionID, 2);
            }
        }

        if (OT.$.browser() === 'Firefox' && (!extensionPathFF || !extensionPathFF.length)) {
            throw new Error('Error starting the screensharing. Firefox screensharing extension required');
        }
    };

    var _validateOptions = function(options) {

        if (!_.property('sessionID', options)) {
            throw new Error('Screen Share Acc Pack requires a session ID');
        }

        _validateExtension(_.property('extensionID'), _.get(options, 'extensionPathFF'));
    };

    // var startScreenSharing = ['<button class="wms-icon-screen" id="startScreenShareBtn"></button>'].join('\n');
    var screenSharingView = [
        '<div class="hidden" id="screenShareView">',
        '<div class="wms-feed-main-video">',
        '<div class="wms-feed-holder" id="videoHolderScreenShare"></div>',
        '<div class="wms-feed-mask"></div>',
        '<img src="/images/mask/video-mask.png"/>',
        '</div>',
        '<div class="wms-feed-call-controls" id="feedControlsFromScreen">',
        '<button class="wms-icon-screen active hidden" id="endScreenShareBtn"></button>',
        '</div>',
        '</div>'
    ].join('\n');

    var screenDialogsExtensions = [
        '<div id="dialog-form-chrome" class="wms-modal" style="display: none;">',
        '<div class="wms-modal-body">',
        '<div class="wms-modal-title with-icon">',
        '<i class="wms-icon-share-large"></i>',
        '<span>Screen Share<br/>Extension Installation</span>',
        '</div>',
        '<p>You need a Chrome extension to share your screen. Install Screensharing Extension. Once you have installed, please, click the share screen button again.</p>',
        '<button id="btn-install-plugin-chrome" class="wms-btn-install">Accept</button>',
        '<button id="btn-cancel-plugin-chrome" class="wms-cancel-btn-install"></button>',
        '</div>',
        '</div>',
        '<div id="dialog-form-ff" class="wms-modal" style="display: none;">',
        '<div class="wms-modal-body">',
        '<div class="wms-modal-title with-icon">',
        '<i class="wms-icon-share-large"></i>',
        '<span>Screen Share<br/>Extension Installation</span>',
        '</div>',
        '<p>You need a Firefox extension to share your screen. Install Screensharing Extension. Once you have installed, refresh your browser and click the share screen button again.</p>',
        '<a href="#" id="btn-install-plugin-ff" class="wms-btn-install" href="">Install extension</a>',
        '<a href="#" id="btn-cancel-plugin-ff" class="wms-cancel-btn-install"></a>',
        '</div>',
        '</div>'
    ].join('\n');

    var _initPublisherScreen = function(annotation) {
        var self = this;
        var handler = this.onError;

        var createPublisher = function(publisherDiv) {

            var innerDeferred = $.Deferred();

            publisherDiv = publisherDiv || 'videoHolderScreenShare';

            self.options.publishers.screen = OT.initPublisher(publisherDiv, self.options.localScreenProperties, function(error) {
                if (error) {
                    error.message = 'Error starting the screen sharing';
                    innerDeferred.reject(error);
                } else {
                    self.options.publishers.screen.on('streamCreated', function(event) {
                        console.log('streamCreated publisher screen', event.stream);
                    });
                    innerDeferred.resolve();
                }
            });

            return innerDeferred.promise();
        };

        var outerDeferred = $.Deferred();

        if (!!self.annotation) {

            self.annotation.start(self.session, {
                    externalWindow: true
                })
                .then(function() {
                    console.log('resolve annotation start');
                    // Need to get a reference to this window somewhere???
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

    var extensionAvailable = function(extensionID, extensionPathFF) {

        var deferred = $.Deferred();

        console.log('Checking for SS extension');

        if (window.location.protocol === 'http:') {
            alert("Screensharing only works under 'https', please add 'https://' in front of your debugger url.");
            deferred.reject('https required');
        }

        OT.checkScreenSharingCapability(function(response) {
            console.log('checkScreenSharingCapability', response);
            if (!response.supported || !response.extensionRegistered) {
                alert('This browser does not support screen sharing! Please use Chrome, Firefox or IE!');
                deferred.reject('browser support not available');
            } else if (!response.extensionInstalled === false) {
                $('#dialog-form-chrome').toggle();
                deferred.reject('screensharing extension not installed');
            } else {
                deferred.resolve();
            }
        });
        
        return deferred.promise();

                _initPublisherScreen()
                    .then(function(annotationContainer) {
                        console.log('resolve init publisher screen');
                        self.publisher = self._publish('screen');
                        addPublisherEventListeners();

                        if (!!annotationContainer) {
                            var annotationWindow = self.comms_elements.annotationWindow;
                            self._annotation.linkCanvas(self.publisher, annotationContainer, annotationWindow);
                        }
                    });

                var addPublisherEventListeners = function() {

                    self.publisher.on('streamCreated', function(event) {
                        self._handleStartScreenSharing(event)
                    });

                    self.publisher.on('streamDestroyed', function(event) {
                        console.log('stream destroyed called');
                        self._handleEndScreenSharing(event);
                    });

                    /*this.publisher.on("accessDenied", function() {
                        self._unpublish('screen');
                        alert("Permission to use the camera and microphone are disabled");
                    })*/
                };

            }
        });
    };

    var _initPublisher = function() {

    }

    var _setupUI = function(parent) {
        $('body').append(screenDialogsExtensions);
        // $(startScreenSharingBtn).append(startScreenSharing);
        $(parent).append(screenSharingView);
    };

    var _startScreenSharing = function() {
        extensionAvailable()
            // self._widget.start();
    };

    var _endScreenSharing = function() {
        console.log('end screensharing');
        // self.widget.end();
    };

    var start = function() {
        checkForExtension(self.options.extensionID, self.options.extensionPathFF)
        .then(initPublisherScreen)
        .then(function(){})
        .catch(function(error){
            console.log('Error starting screensharing: ', error);
        })
    };

    var end = function() {
        console.log('ending screen sharing')
    };

    ScreenSharing.prototype = {
        constructor: ScreenSharing,
        checkExtension: checkExtension,
        start: start,
        end: end,
        onStarted: function() {},
        onEnded: function() {},
        onError: function(error) {
            console.log('OT: Screen sharing error: ', error);
        }
    };

    return ScreenSharing;

})();