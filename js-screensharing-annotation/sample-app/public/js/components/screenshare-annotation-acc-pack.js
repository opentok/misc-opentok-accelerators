var AccPackAnnotation = (function() {

    var self;

    /** 
     * Annotation Accelerator Pack Constructor
     * @param {Object} options
     * @param {String} options.canvasContainer - The id of the parent element for the annotation canvas
     */
    var Annotation = function(options) {
        
        if ( !options || !this.options.canvasContainer ) {
            throw new Error('Annotation requires')
        }
        
        this.options = options || {};
        // UPDATE FROM WMS       
        this.elements = { canvasContainer : this.options.canvasContainer };
        self = this;
    };

    // Toolbar items
    var _defaultToolbarItems = [{
        id: 'OT_pen',
        title: 'Pen',
        icon: '../images/annotation/freehand.png',
        selectedIcon: '../images/annotation/freehand_selected.png'
    }, {
        id: 'OT_line',
        title: 'Line',
        icon: '../images/annotation/line.png',
        selectedIcon: '../images/annotation/line_selected.png'
    }, {
        id: 'OT_shapes',
        title: 'Shapes',
        icon: '../images/annotation/shapes.png',
        items: [{
            id: 'OT_arrow',
            title: 'Arrow',
            icon: '../images/annotation/arrow.png'
        }, {
            id: 'OT_rect',
            title: 'Rectangle',
            icon: '../images/annotation/rectangle.png'
        }, {
            id: 'OT_oval',
            title: 'Oval',
            icon: '../images/annotation/oval.png'
        }, {
            id: 'OT_star',
            title: 'Star',
            icon: '../images/annotation/star.png',
            points: [
                [0.5 + 0.5 * Math.cos(90 * (Math.PI / 180)), 0.5 + 0.5 * Math.sin(90 * (Math.PI / 180))],
                [0.5 + 0.25 * Math.cos(126 * (Math.PI / 180)), 0.5 + 0.25 * Math.sin(126 * (Math.PI / 180))],
                [0.5 + 0.5 * Math.cos(162 * (Math.PI / 180)), 0.5 + 0.5 * Math.sin(162 * (Math.PI / 180))],
                [0.5 + 0.25 * Math.cos(198 * (Math.PI / 180)), 0.5 + 0.25 * Math.sin(198 * (Math.PI / 180))],
                [0.5 + 0.5 * Math.cos(234 * (Math.PI / 180)), 0.5 + 0.5 * Math.sin(234 * (Math.PI / 180))],
                [0.5 + 0.25 * Math.cos(270 * (Math.PI / 180)), 0.5 + 0.25 * Math.sin(270 * (Math.PI / 180))],
                [0.5 + 0.5 * Math.cos(306 * (Math.PI / 180)), 0.5 + 0.5 * Math.sin(306 * (Math.PI / 180))],
                [0.5 + 0.25 * Math.cos(342 * (Math.PI / 180)), 0.5 + 0.25 * Math.sin(342 * (Math.PI / 180))],
                [0.5 + 0.5 * Math.cos(18 * (Math.PI / 180)), 0.5 + 0.5 * Math.sin(18 * (Math.PI / 180))],
                [0.5 + 0.25 * Math.cos(54 * (Math.PI / 180)), 0.5 + 0.25 * Math.sin(54 * (Math.PI / 180))],
                [0.5 + 0.5 * Math.cos(90 * (Math.PI / 180)), 0.5 + 0.5 * Math.sin(90 * (Math.PI / 180))]
            ]
        }]
    }, {
        id: 'OT_colors',
        title: 'Colors',
        icon: '',
        items: { /* Built dynamically */ }
    }, {
        id: 'OT_line_width',
        title: 'Line Width',
        icon: '../images/annotation/line_width.png',
        items: { /* Built dynamically */ }
    }, {
        id: 'OT_clear',
        title: 'Clear',
        icon: '../images/annotation/clear.png'
    }];

    var _palette = [
        '#1abc9c',
        '#2ecc71',
        '#3498db',
        '#9b59b6',
        '#8e44ad',
        '#f1c40f',
        '#e67e22',
        '#e74c3c',
        '#ded5d5'
    ];

    var _aspectRatio = (10 / 6);
    
    /** Private methods */
    
    var _listenForResize = function() {
        $(self.elements.resizeSubject).on('resize', resizeCanvas);
    };

    var _createToolbar = function(session, options, externalWindow) {

        var toolbarId = _.property('toolbarId')(options) || 'toolbar';
        var items = _.property('toolbarItems')(options) || _defaultToolbarItems;
        var colors = _.property('colors')(options) || _palette;

        var container = function() {
            var w = !!externalWindow ? externalWindow : window;
            return w.document.getElementById(toolbarId);
        };

        toolbar = new OTSolution.Annotations.Toolbar({
            session: session,
            container: container(),
            colors: colors,
            items: items,
            externalWindow: externalWindow || null
        });

    };

    var _refreshCanvas = _.throttle(function() {
        self.canvas.onResize();
    }, 1000);

    // Create external screen sharing window
    var _createExternalWindow = function() {

        var deferred = $.Deferred();

        var width = screen.width * .80 | 0;
        var height = width / (_aspectRatio);
        var url = ['templates/screenshare.html?opentok-annotation'].join('');

        var windowFeatures = [
            'toolbar=no',
            'location=no',
            'directories=no',
            'status=no',
            'menubar=no',
            'scrollbars=no',
            'resizable=no',
            'copyhistory=no',
            'width=' + width,
            'height=' + height,
            'left=' + ((screen.width / 2) - (width / 2)),
            'top=' + ((screen.height / 2) - (height / 2))
        ].join(',');

        var annotationWindow = window.open(url, '', windowFeatures);

        // External window needs access to certain globals
        annotationWindow.toolbar = toolbar;
        annotationWindow.OT = OT;
        annotationWindow.$ = $;

        // TODO Find something better.
        var windowReady = function() {
            if (!!annotationWindow.createContainerElements) {
                $(annotationWindow.document).ready(function() {
                    deferred.resolve(annotationWindow);
                });
            } else {
                setTimeout(windowReady, 100);
            }
        };

        windowReady();

        return deferred.promise();
    };

    // Remove the toolbar and cancel event listeners
    var _removeToolbar = function() {
        $(self.elements.resizeSubject).off('resize', resizeCanvas);
        toolbar.remove();
    };

    /**
     * Creates an external window (if required) and links the annotation toolbar
     * to the session
     * @param {Object} session
     * @param {Object} [options]
     * @param {Boolean} [options.screensharing] - Using an external window
     * @param {String} [options.toolbarId] - If the container has an id other than 'toolbar'
     * @param {Array} [options.items] - Custom set of tools
     * @param {Array} [options.colors] - Custom color palette
     * @returns {Promise} < Resolve: undefined | {Object} Reference to external annotation window >
     */
    var start = function(session, options) {

        var deferred = $.Deferred();

        if (_.property('screensharing')(options)) {
            _createExternalWindow()
            .then(function(externalWindow) {
                _createToolbar(session, options, externalWindow);
                toolbar.createPanel(externalWindow);
                deferred.resolve(externalWindow);
            });
        } else {
            _createToolbar(session, options);
            deferred.resolve();
        }

        return deferred.promise();
    };

    /**
     * @param {object} pubSub - Either the publisher(share screen) or subscriber(viewing shared screen)
     * @param {object} container - The actual DOM node
     * @param {object} [windowReference] - Reference to the annotation window if publishing
     */
    var linkCanvas = function(pubSub, container, externalWindow) {

        /**
         * jQuery only allows listening for a resize event on the window or a
         * jQuery resizable element, like #wmsFeedWrap.  windowRefernce is a
         * reference to the popup window created for annotation.  If this doesn't
         * exist, we are watching the canvas belonging to the party viewing the
         * shared screen
         */
        self.elements.resizeSubject = externalWindow || self.elements.canvasContainer;
        self.elements.externalWindow = externalWindow;
        self.elements.annotationContainer = container;

        self.canvas = new OTSolution.Annotations({
            feed: pubSub,
            container: container
        });

        var context =self.elements.externalWindow ?self.elements.externalWindow : window;

        self.elements.canvas = $(_.first(context.document.getElementsByTagName('canvas')));

        toolbar.addCanvas(self.canvas);

        self.canvas.onScreenCapture(function(dataUrl) {
            var win = window.open(dataUrl, '_blank');
            win.focus();
        });

        _listenForResize();
        resizeCanvas();

    };

    /** Resize the canvas to match the size of its container */
    var resizeCanvas = function() {
        
        var width, height;

        if ( !!self.elements.externalWindow ) {

            var windowDimensions = {
                width:self.elements.externalWindow.innerWidth,
                height:self.elements.externalWindow.innerHeight
            };

            var computedHeight = windowDimensions.width / _aspectRatio;

            if ( computedHeight <= windowDimensions.height ) {
                width = windowDimensions.width;
                height = computedHeight;
            } else {
                height = windowDimensions.height;
                width = height * _aspectRatio;
            }

        } else {
            width = $(self.elements.canvasContainer).width();
            height = $(self.elements.canvasContainer).height();
        }

        $(self.elements.annotationContainer).css({
            width: width,
            height: height
        });

        $(self.elements.canvas).css({
            width: width,
            height: height
        });

        $(self.elements.canvas).attr({
            width: width,
            height: height
        });

        _refreshCanvas();
    };

    /**
     * Stop annotation and clean up components
     */
    var end = function() {
        _removeToolbar();
        delete self.canavs;
        delete self.elements;
        if (!!self.elements.externalWindow) {
            self.elements.externalWindow.close();
        }
    };

    Annotation.prototype = {
        constructor: Annotation,
        start: start,
        linkCanvas: linkCanvas,
        resizeCanvas: resizeCanvas,
        end: end
    };

    return Annotation;

})();

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