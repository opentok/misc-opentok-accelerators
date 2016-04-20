var ScreenSharingAccPack = (function() {

    var self;
    var _annotation;
    var _localScreenProperties = {
        insertMode: 'append',
        width: '100%',
        height: '100%',
        videoSource: 'window',
        showControls: false,
        style: {
            buttonDisplayMode: 'off'
        }
    };

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
            'screensharingParent',
            'acceleratorPack'
        ];

        _.extend(this, _.defaults(_.pick(options, optionsProps)), { screenSharingParent: '#videoContainer' });
        
        window.extensionID = self.extensionID;


        // Do UIy things
        _setupUI(self.screensharingParent);
    };

    var _validateExtension = function(extensionID, extensionPathFF) {
         
        if (OT.$.browser() === 'Chrome') {
            if (!extensionID || !extensionID.length) {
                throw new Error('Error starting the screensharing. Chrome extensionID required');
            } else {
                $('<link/>', {
                    rel: 'chrome-webstore-item',
                    href: ['https://chrome.google.com/webstore/detail/', extensionID].join('')
                }).appendTo('head');
                
               
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

        _validateExtension(_.property('extensionID')(options), _.property('extensionPathFF')(options));
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


    /**
     * Create a publisher for the screen.  If we're using annotation, we first need
     * to create the annotion window and get a reference to its annotation container
     * element so that we can pass it to the initPublisher function.
     * @returns {Promise} < Resolve: [Object] Container element for annotation in external window >
     */
    var _initPublisher = function() {

        var self = this;

        var createPublisher = function(publisherDiv) {

            var innerDeferred = $.Deferred();

            publisherDiv = publisherDiv || 'videoHolderScreenShare';

            self.publisher = OT.initPublisher(publisherDiv, _localScreenProperties, function(error) {
                if (error) {
                    error.message = 'Error starting the screen sharing';
                    innerDeferred.reject(error);
                } else {
                    self.publisher.on('streamCreated', function(event) {
                        console.log('streamCreated publisher screen', event.stream);
                    });
                    innerDeferred.resolve();
                }
            });

            return innerDeferred.promise();
        };

        var outerDeferred = $.Deferred();

        if (!!self.annotation) {

            self.acceleratorPack.initAnnotation(true)
                .then(function(annotationWindow) {
                    self.annotationWindow = annotationWindow || null;
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


    /** 
     * Publish the screen
     * @param annotationContainer
     */
    var _publish = function(annotationContainer) {

        self.session.publish(self.publisher, function(error) {
            if (error) {
                console.log('Failed to connect: ', error.message);
                if (error.code == 1500 && navigator.userAgent.indexOf('Firefox') != -1) {
                    $('#dialog-form-ff').toggle();
                } else {
                    error.message = 'Error sharing the screen';
                    console.log('Error sharing the screen' + error.code + ' - ' + error.message);
                    if (error.code === 1010) {
                        var errorStr = error.message + 'Check your network connection';
                        error.message = errorStr;
                    }
                }
            } else {
                addPublisherEventListeners();
                self.acceleratorPack.linkAnnotation(self.publisher, annotationContainer, self.annotationWindow);

                console.log('Connected');
            }
        });


        if (!!annotationContainer) {
            var annotationWindow = self.comms_elements.annotationWindow;
            self._annotation.linkCanvas(self.publisher, annotationContainer, annotationWindow);
        }

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

    var extensionAvailable = function(extensionID, extensionPathFF) {

        var deferred = $.Deferred();

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

    };

    var _setupUI = function(parent) {
        $('body').append(screenDialogsExtensions);
        // $(startScreenSharingBtn).append(startScreenSharing);
        $(parent).append(screenSharingView);
    };

    var _endScreenSharing = function() {
        console.log('end screensharing');
        // self.widget.end();
    };

    var start = function() {
        
        extensionAvailable(self.extensionID, self.extensionPathFF)
            .then(_initPublisher)
            .then(_publish)
            .fail(function(error) {
                console.log('Error starting screensharing: ', error);
            });

    };

    var end = function() {
        console.log('ending screen sharing')
    };

    ScreenSharing.prototype = {
        constructor: ScreenSharing,
        extensionAvailable: extensionAvailable,
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