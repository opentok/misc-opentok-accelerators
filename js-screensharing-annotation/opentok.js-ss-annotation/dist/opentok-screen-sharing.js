;
(function() {
    var ScreenSharingUI, opentokScreenSharing;
    ScreenSharingUI = function() {
        var startScreenSharing = ['<button class="wms-icon-screen" id="startScreenShareBtn"></button>'].join('\n');
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

        function ScreenSharingUI(options) {
            this._options = options || {};
            if (options != undefined) {
                this._session = options.session;
                this._extensionURL = options.extensionURL;
                this._extensionID = options.extensionID;
                this._extensionPathFF = options.extensionPathFF;
                this._startButtonID = options.comms_elements.shareScreenBtn;
                this._endButtonID = options.comms_elements.endShareScreenBtn;
                this._widget = options.widget;
                this._startScreenSharingBtnParent = options._startScreenSharingBtnParent || '#feedControls';
                this._screenSharingViewParent = options._screenSharingViewParent || '#videoWraper';
                if (OT.$.browser() == 'Chrome') {
                    OT.registerScreenSharingExtension('chrome', this._extensionID, 2);
                }
            }
            this._setupTemplates();
            this._setupUI();
        }

        function _checkExtension(extensionID, extensionPathFF) {
            // var handler = this.onError;
            if (OT.$.browser() == 'Chrome' && (!extensionID || extensionID.length == 0)) {
                var error = {
                    code: 200,
                    message: ' Error starting the screensharing. You need to indicate a screensharing Chrome extensionID'
                };
                console.log(error.code, error.message);
                return false;
            }
            if (OT.$.browser() == 'Firefox' && (!extensionPathFF || extensionPathFF.length == 0)) {
                var error = {
                    code: 200,
                    message: ' Error starting the screensharing. You need to indicate a screensharing extension for Fireforx'
                };
                console.log(error.code, error.message);
                return false;
            }
            return true;
        }
        ScreenSharingUI.prototype = {
            constructor: ScreenSharingUI,
            _setupTemplates: function() {},
            _setupUI: function(parent) {
                var startScreenSharingBtn = this._startScreenSharingBtnParent || document.body;
                var screenSharingViewParent = this._screenSharingViewParent || document.body;
                this._startButtonID = this._startButtonID || '#startScreenShareBtn';
                this._endButtonID = this._endButtonID || '#endScreenShareBtn';
                $('body').append(screenDialogsExtensions);
                $(startScreenSharingBtn).append(startScreenSharing);
                $(screenSharingViewParent).append(screenSharingView);
                var startButton = document.querySelector(this._startButtonID);
                var endButton = document.querySelector(this._endButtonID);
                startButton.onclick = this._startScreenSharing.bind(this);
                endButton.onclick = this._endScreenSharing.bind(this);
            },
            _startScreenSharing: function() {
                this._widget.start(); // this.widget.end();
            },
            _endScreenSharing: function() {
                this._widget.end(); // this.widget.end();
            },
            _checkExtension: function(extensionID, extensionPathFF) {
                return _checkExtension(extensionID, extensionPathFF);
            },
            onStarted: function() {},
            onEnded: function() {},
            onError: function(error) {}
        };
        return ScreenSharingUI;
    }();
    opentokScreenSharing = function(ScreenSharingUI) {
        window.OTScreenSharingSolution = window.OTScreenSharingSolution || {};
        window.OTScreenSharingSolution.ScreenSharing = {
            ScreenSharingUI: ScreenSharingUI
        };
    }(ScreenSharingUI);
}());