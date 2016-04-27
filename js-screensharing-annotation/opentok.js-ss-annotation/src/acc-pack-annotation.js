var AccPackAnnotation = (function() {

    var self;

    /** 
     * @constructor
     * Represents an annotation component which may be used for annotation over video or a shared screen
     * @param {object} options
     * @param [string] options.canvasContainer - The id of the parent element for the annotation canvas
     */
    var Annotation = function(options) {
        self = this;
        self.options = _.omit(options, 'accPack');
        self.accPack = options.accPack;  
        self.elements = { canvasContainer : self.options.canvasContainer || window };
        _registerEvents();
        _setupUI();
    };
    
    var _triggerEvent;
    var _registerEvents = function(){
        var events = ['startAnnotation', 'linkAnnotation', 'resizeCanvas', 'endAnnotation'];
        _triggerEvent = self.accPack.registerEvents(events);
    };
    
    var _setupUI = function(){
        var toolbar = ['<div id="toolbar"></div>'].join('\n');
        $('body').append(toolbar);
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
     * @param {object} session
     * @param {object} [options]
     * @param {boolean} [options.screensharing] - Using an external window
     * @param {string} [options.toolbarId] - If the container has an id other than 'toolbar'
     * @param {array} [options.items] - Custom set of tools
     * @param {array} [options.colors] - Custom color palette
     * @returns {promise} < Resolve: undefined | {object} Reference to external annotation window >
     */
    var start = function(session, options) {
        
        var deferred = $.Deferred();

        if (_.property('screensharing')(options)) {
            _createExternalWindow()
            .then(function(externalWindow) {
                _createToolbar(session, options, externalWindow);
                toolbar.createPanel(externalWindow);
                _triggerEvent('startAnnotation', externalWindow);
                deferred.resolve(externalWindow);
            });
        } else {
            _createToolbar(session, options);
            _triggerEvent('startAnnotation');
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
        _triggerEvent('linkAnnotation');

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
        _triggerEvent('resizeCanvas');
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
        _triggerEvent('endAnnotation');
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
