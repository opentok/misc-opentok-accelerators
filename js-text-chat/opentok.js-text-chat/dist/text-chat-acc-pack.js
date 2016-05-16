var CommunicationAccPack = (function() {

    var _this;

    var _otkanalytics;
    //vars for the analytics logs. Internal use
    var logEventData = {
        clientVersion: 'js-vsol-1.0.0',
        source: 'avcommunication_acc_pack',
        actionInitialize: 'initialize',
        actionStartComm: 'start',
        actionStopComm: 'stop',
        variationAttempt: 'Attempt',
        variationError: 'Failure',
        variationSuccess: 'Success'
    };

    /** 
     * @constructor
     * Represents a one-to-one AV communication layer
     * @param {object} options
     * @param {object} options.session
     * @param {string} options.sessionId
     * @param {string} options.apiKey
     * @param {array} options.subscribers
     * @param {array} options.streams
     * @param {boolean} options.annotation
     */
    var Communication = function(options) {
        
        // Save a reference to this
        _this = this;

        var nonOptionProps = ['accPack', 'session', 'subscribers', 'streams'];
        _this.options = _validateOptions(options, nonOptionProps);
        _.extend(_this, _.pick(options, nonOptionProps));

        //init analytics logs
        _logAnalytics();

        _log(logEventData.actionInitialize, logEventData.variationAttempt);

        _registerEvents();
        _setEventListeners();

        _log(logEventData.actionInitialize, logEventData.variationSuccess)
        
    };


    /** Private Methods */

    /**
     * Validates options and returns a filtered hash to be added to the instance
     * @param {object} options
     * @param {array} ignore - Properties that should not be included in options
     */
    var _validateOptions = function(options, ignore) {

        if (!options || !options.session) {
            throw new Error('No session provided.');
        }

        return _.omit(options, ignore);
    };

    var _triggerEvent;
    var _registerEvents = function() {

        var events = [
            'startCall',
            'endCall',
            'startViewingSharedScreen',
            'endViewingSharedScreen'
        ];

        _triggerEvent = _this.accPack.registerEvents(events);
    };

    var _setEventListeners = function() {
        _this.accPack.registerEventListener('streamCreated', _handleStreamCreated);
        _this.accPack.registerEventListener('streamDestroyed', _handleStreamDestroyed);
    };

    var _logAnalytics = function() {

        var otkanalyticsData = {
            sessionId: _this.options.sessionId,
            connectionId: _this.session.connection.connectionId,
            partnerId: _this.options.apiKey,
            clientVersion: logEventData.clientVersion,
            source: logEventData.source
        };

        //init the analytics logs
        _otkanalytics = new OTKAnalytics(otkanalyticsData);
    };

    var _log = function(action, variation) {
        var data = {
        action: action,
        variation: variation
        };
        _otkanalytics.logEvent(data);
    };

    var _publish = function(type) {

        currentSource = type;

        var handler = _this.onError;

        _initPublisherCamera();

        return _this.session.publish(_this.publisher, function(error) {
            if (error) {
                console.log("Error starting a call " + error.code + " - " + error.message);
                error.message = "Error starting a call";
                if (error.code === 1010) {
                    var errorStr = error.message + ". Check your network connection.";
                    error.message = errorStr;
                }
                _handleError(error, handler);
                _log(logEventData.actionStartComm, logEventData.variationError);
            }
        });
    };

    var _unpublish = function() {
        if (_this.publisher) {
            _this.session.unpublish(_this.publisher);
        }
    };

    var _initPublisherCamera = function() {
        if (_this.options.user) {
            _this.options.localCallProperties.name = _this.options.user.name;
        }
        _this.publisher = OT.initPublisher('videoHolderSmall', _this.options.localCallProperties, function(error) {
            if (error) {
                error.message = "Error starting a call";
                _handleError(error, handler);
            }
            //_this.publishers.camera.on('streamDestroyed', _this._publisherStreamDestroyed);
        });
    };

    var _publisherStreamDestroyed = function(event) {
        console.log('publisherStreamDestroyed', event);
        event.preventDefault();
    };

    var _subscribeToStream = function(stream) {
        var handler = _this.onError;
        if (stream.videoType === 'screen') {
            var options = _this.options.localScreenProperties
        } else {
            var options = _this.options.localCallProperties
        }

        var videoContainer = stream.videoType === 'screen' ? 'videoHolderSharedScreen' : 'videoHolderBig';

        var subscriber = _this.session.subscribe(stream,
            videoContainer,
            options,
            function(error) {
                if (error) {
                    console.log('Error starting a call ' + error.code + ' - ' + error.message);
                    error.message = 'Error starting a call';
                    if (error.code === 1010) {
                        var errorStr = error.message + '. Check your network connection.'
                        error.message = errorStr;
                    }
                    _handleError(error, handler);
                } else {

                    _this.streams.push(subscriber);

                    if (stream.videoType === 'screen') {
                        console.log('starting to view shared screen here');
                        _triggerEvent('startViewingSharedScreen', subscriber);
                    }
                }
            });

        _this.subscriber = subscriber;
    };

    var _unsubscribeStreams = function() {
        _.each(_this.streams, function(stream) {
            _this.session.unsubscribe(stream);
        })
    };

    // Private handlers
    var _handleStart = function(event) {

    };

    var _handleEnd = function(event) {

    };

    var _handleStreamCreated = function(event) {
        console.log('new stream here ', event);
        //TODO: check the joined participant
        _this.subscribers.push(event.stream);

            _this._remoteParticipant = event.connection;
            _subscribeToStream(event.stream);

    };

    var _handleStreamDestroyed = function(event) {
        console.log('Participant left the call');
        var streamDestroyedType = event.stream.videoType;

        //remove to the subscribers list
        var index = _this.subscribers.indexOf(event.stream);
        _this.subscribers.splice(index, 1);

        if (streamDestroyedType === 'camera') {
            _this.subscriber = null; //to review
            _this._remoteParticipant = null;

        } else if (streamDestroyedType === 'screen') {
            _triggerEvent('endViewingSharedScreen');
        } else {
            _.each(_this.subscribers, function(subscriber) {
                _subscribeToStream(subscriber);
            });
        }

        //var handler = this.onParticipantLeft(streamDestroyedType);
        // TODO Do we need user date for anything???
        var userData = {
            userId: 'event.stream.connectionId'
        };

    };

    var _handleLocalPropertyChanged = function(event) {

        if (event.changedProperty === 'hasAudio') {
            var eventData = {
                property: 'Audio',
                enabled: event.newValue
            }
        } else {
            var eventData = {
                property: 'Video',
                enabled: event.newValue
            }
        }
    }

    var _handleError = function(error, handler) {
        if (handler && typeof handler === 'function') {
            handler(error);
        }
    };

    // Prototype methods
    Communication.prototype = {
        constructor: Communication,
        start: function(recipient) {
            //TODO: Managing call status: calling, startCall,...using the recipient value
            
            _log(logEventData.actionStartComm, logEventData.variationAttempt);
            
            _this.options.inSession = true;

            _this.publisher = _publish('camera');

            $.when(_this.publisher.on('streamCreated'))
                .done(function(event) {
                    _handleStart(event)
                })
                .promise(); //call has been initialized

            _this.publisher.on('streamDestroyed', function(event) {
                console.log("stream destroyed");
                _handleEnd(event); //call has been finished
            });

            _this.publisher.session.on('streamPropertyChanged', function(event) {
                if (_this.publisher.stream === event.stream) {
                    _handleLocalPropertyChanged(event)
                }
            }); //to handle audio/video changes

            _.each(_this.subscribers, function(subscriber) {
                _subscribeToStream(subscriber);
            });

            _triggerEvent('startCall');

            _log(logEventData.actionStartComm, logEventData.variationSuccess);
        },
        end: function() {
            _log(logEventData.actionStopComm, logEventData.variationAttempt);
            _this.options.inSession = false;
            _unpublish('camera');
            _unsubscribeStreams();
            _triggerEvent('endCall');
            _log(logEventData.actionStopComm, logEventData.variationSuccess); 
        },
        enableLocalAudio: function(enabled) {
            _this.publisher.publishAudio(enabled);
        },
        enableLocalVideo: function(enabled) {
            _this.publisher.publishVideo(enabled);
        },
        enableRemoteVideo: function(enabled) {
            _this.subscriber.subscribeToVideo(enabled);
        },
        enableRemoteAudio: function(enabled) {
            _this.subscriber.subscribeToAudio(enabled);
        }
    };

    return Communication;

})();
var TextChatAccPack = (function() {
  var _enabled = false;
  var _displayed = false;
  var _initialized = false;
  var _accPack;
  var _controlAdded = false;
  var textChatContainer;
  var lastMessage, sender, composer;
  var newMessages, _this, limitCharacterMessage;
  var _active = false;

  /** Analytics */
  var _otkanalytics;
  var _otkanalyticsData = function() {
    return {
      sessionId: _accPack.getSession().sessionId,
      connectionId: _accPack.getSession().connection.connectionId,
      partnerId: _accPack.getSession().apiKey,
      clientVersion: _logEventData.clientVersion,
      source: _logEventData.source
    };
  };
  var _logEventData = {
    //vars for the analytics logs. Internal use
    clientVersion: 'js-vsol-1.0.0',
    source: 'text_chat_acc_pack',
    actionInitialize: 'initialize',
    actionSendMessage: 'send_message',
    actionReceiveMessage: 'receive_message',
    actionMaximize: 'maximize',
    actionMinimize: 'minimize',
    actionSetMaxLength: 'set_max_length',
    variationAttempt: 'Attempt',
    variationError: 'Failure',
    variationSuccess: 'Success'
  };

  var _log = function(action, variation) {
    var data = {
      action: action,
      variation: variation
    };
    _otkanalytics.logEvent(data);
  };

  // Constructor
  var TextChat = function(options) {

    // Save a reference to this
    _this = this;

    _accPack = _.property('accPack')(options);
    sender = _.property('sender')(options);
    limitCharacterMessage = _.property('limitCharacterMessage')(options) || 160;
    controlsContainer = _.property('controlsContainer')(options) || '#feedControls';
    textChatContainer = _.property('textChatContainer')(options);

    //init the analytics logs
    _otkanalytics = new OTKAnalytics(_otkanalyticsData());

    if (!!_.property('limitCharacterMessage')(options)) {
      _log(_logEventData.actionSetMaxLength, _logEventData.variationAttempt);
      _log(_logEventData.actionSetMaxLength, _logEventData.variationSuccess);
    }

    _appendControl();
    _registerEvents();
    _addEventListeners();
  };


  var _appendControl = function() {

    var feedControls = document.querySelector(controlsContainer);

    var el = document.createElement('div');
    el.innerHTML = '<div class="video-control circle text-chat enabled" id="enableTextChat"></div>';

    var enableTextChat = el.firstChild;
    feedControls.appendChild(enableTextChat);
    
    _controlAdded = true;
    
    enableTextChat.onclick = function() {

      if (!_initialized) {
        _initTextChat();
      } else if (!_displayed) {
        _showTextChat();
      } else {
        _hideTextChat();
      }
    }
  };

  var _showTextChat = function() {
    //add MAXIMIZE attempt log event
    _log(_logEventData.actionMaximize, _logEventData.variationAttempt);

    document.querySelector(textChatContainer).classList.remove('hidden');
    _displayed = true;

    //add MAXIMIZE success log event
    _log(_logEventData.actionMaximize, _logEventData.variationSuccess);
  };

  var _hideTextChat = function() {
    //add MINIMIZE attempt log event
    _log(_logEventData.actionMinimize, _logEventData.variationAttempt);
    document.querySelector(textChatContainer).classList.add('hidden');
    _displayed = false;

    //add MINIMIZE success log event
    _log(_logEventData.actionMinimize, _logEventData.variationSuccess);

  }

  var _triggerEvent;
  var _registerEvents = function() {
    var events = ['messageSent', 'errorSendingMessage', 'messageReceived'];
    _triggerEvent = _accPack.registerEvents(events);
  };

  var _addEventListeners = function() {

    _accPack.registerEventListener('startCall', function() {
      
      if ( _controlAdded ) {
        document.querySelector('#enableTextChat').classList.remove('hidden');
      } else {
        _appendControl();
      }
    });

    _accPack.registerEventListener('endCall', function() {
      document.getElementById('enableTextChat').classList.add('hidden');
      !!_displayed && _hideTextChat();
    });
  }

  // Private methods
  var renderUILayout = function(type) {

    return [
      '<div class="wms-widget-wrapper">',
      '<div class="wms-widget-chat wms-widget-extras" id="chatContainer">',
      '<div class="wms-messages-header hidden" id="chatHeader">',
      '<span>Chat with</span>',
      '</div>',
      '<div id="wmsChatWrap">',
      '<div class="wms-messages-holder" id="messagesHolder">',
      '<div class="wms-message-item wms-message-sent">',
      '</div>',
      '</div>',
      '<div class="wms-send-message-box">',
      '<input type="text" maxlength=' + limitCharacterMessage + ' class="wms-message-input" placeholder="Enter your message here" id="messageBox">',
      '<button class="wms-icon-check" id="sendMessage" type="submit"></button>',
      '<div class="wms-character-count"><span><span id="character-count">0</span>/' + limitCharacterMessage + ' characters</span></div>',
      '</div>',
      '</div>',
      '</div>',
      '</div>'
    ].join('\n');
  };

  var enableTextChatControl = function() {
    var el = document.createElement('div');
    el.innerHTML = '<div class="video-control circle text-chat enabled hidden" id="enableTextChat"></div>';
    return el.firstChild;
  }

  var _initTextChat = function() {
    //add INITIALIZE attempt log event
    _log(_logEventData.actionInitialize, _logEventData.variationAttempt);

    _enabled = true;
    _displayed = true;
    _initialized = true;
    _setupUI();
    _accPack.getSession().on('signal:text-chat', _handleTextChat);
  };

  var _setupUI = function() {

    var parent = document.querySelector(textChatContainer) || document.body;

    var chatView = document.createElement('section');
    chatView.innerHTML = renderUILayout();

    composer = chatView.querySelector('#messageBox');

    newMessages = chatView.querySelector('#messagesHolder');
    composer.onkeyup = _updateCharCounter;
    composer.onkeydown = _controlComposerInput;

    parent.appendChild(chatView);

    document.getElementById('sendMessage').onclick = function() {
      _sendTxtMessage(composer.value);
    };
    //add INITIALIZE success log event
    _log(_logEventData.actionInitialize, _logEventData.variationSuccess);
  };

  var _shouldAppendMessage = function(data) {
    return lastMessage && lastMessage.senderId === data.senderId && moment(lastMessage.sentOn).fromNow() === moment(data.sentOn).fromNow();
  };

  var _sendTxtMessage = function(text) {
    if (!_.isEmpty(text)) {
      $.when(_sendMessage(_this._remoteParticipant, text))
        .then(function(data) {
          _handleMessageSent({
            senderId: sender.id,
            alias: sender.alias,
            message: text,
            sentOn: Date.now()
          });
          if (this.futureMessageNotice)
            this.futureMessageNotice = false;
        }, function(error) {
          _handleMessageError(error);
        });
    }
  };

  var _sendMessage = function(recipient, message) {
    var deferred = new $.Deferred();
    var messageData = {
      text: message,
      sender: {
        id: sender.id,
        alias: sender.alias,
      },
      sentOn: Date.now()
    };

    //add SEND_MESSAGE attempt log event
    _log(_logEventData.actionSendMessage, _logEventData.variationAttempt);

    if (recipient === undefined) {
      _accPack.getSession().signal({
          type: 'text-chat',
          data: messageData,
        },
        function(error) {
          if (error) {
            error.message = 'Error sending a message. ';
            //add SEND_MESSAGE failure log event
            _log(_logEventData.actionSendMessage, _logEventData.variationFailure);
            if (error.code === 413) {
              var errorStr = error.message + 'The chat message is over size limit.'
              error.message = errorStr;
            } else {
              if (error.code === 500) {
                var errorStr = error.message + 'Check your network connection.'
                error.message = errorStr;
              }
            }
            deferred.reject(error);
          } else {
            console.log('Message sent');
            //add SEND_MESSAGE success log event
            _log(_logEventData.actionSendMessage, _logEventData.variationSuccess);
            deferred.resolve(messageData);
          }
        }
      );
    } else {
      _accPack.getSession().signal({
        type: 'text-chat',
        data: messageData,
        to: recipient
      }, function(error) {
        if (error) {
          console.log('Error sending a message');
          deferred.resolve(error);
        } else {
          console.log('Message sent');
          deferred.resolve(messageData);
        }
      });
    }

    return deferred.promise();
  };

  var _handleMessageSent = function(data) {
    if (_shouldAppendMessage(data)) {
      $('.wms-item-text').last().append('<span>' + data.message + '</span>');
      var chatholder = $(newMessages);
      chatholder[0].scrollTop = chatholder[0].scrollHeight;
      _cleanComposer();

    } else {
      _renderChatMessage(sender.id, sender.alias, data.message, data.sentOn);
    }
    lastMessage = data;

    _triggerEvent('messageSent', data);

  };

  var _onIncomingMessage = function(signal) {
    _log(_logEventData.actionReceiveMessage, _logEventData.variationAttempt);
    if (typeof signal.data === 'string') {
      signal.data = JSON.parse(signal.data);
    }
    if (_shouldAppendMessage(signal.data)) {
      $(".wms-item-text").last().append('<span>' + signal.data.text + '</span>');
    } else {
      _renderChatMessage(signal.data.sender.id, signal.data.sender.alias, signal.data.text, signal.data.sentOn);
    }
    lastMessage = signal.data;
    _log(_logEventData.actionReceiveMessage, _logEventData.variationSuccess);
  };

  var _handleMessageError = function(error) {
    console.log(error.code, error.message);
    if (error.code === 500) {
      var view = _.template($('#chatError').html());
      $(_this.comms_elements.messagesView).append(view());
    }
    _triggerEvent('errorSendingMessage', error);
  };

  var _renderChatMessage = function(messageSenderId, messageSenderAlias, message, sentOn) {

    var sentByClass = sender.id === messageSenderId ? 'wms-message-item wms-message-sent' : 'wms-message-item';

    var view = _getBubbleHtml({
      username: messageSenderAlias,
      message: message,
      messageClass: sentByClass,
      time: sentOn
    });

    var chatholder = $(newMessages);
    chatholder.append(view);
    _cleanComposer();
    chatholder[0].scrollTop = chatholder[0].scrollHeight;

  };

  var _getBubbleHtml = function(message) {
    var bubble = [
      '<div class="' + message.messageClass + '" >',
      '<div class="wms-user-name-initial"> ' + message.username[0] + '</div>',
      '<div class="wms-item-timestamp"> ' + message.username + ', <span data-livestamp=" ' + new Date(message.time) + '" </span></div>',
      '<div class="wms-item-text">',
      '<span> ' + message.message + '</span>',
      '</div>',
      '</div>'
    ].join('\n');
    return bubble;
  };

  var _handleTextChat = function(event) {
    var me = _accPack.getSession().connection.connectionId;
    var from = event.from.connectionId;
    if (from !== me) {
      var handler = _onIncomingMessage(event);
      if (handler && typeof handler === 'function') {
        handler(event);
      }
      _triggerEvent('messageReceived', event);
    }
  };

  var _cleanComposer = function() {
    composer.value = '';
    $('#character-count').text("0");
  };

  var _controlComposerInput = function(evt) {
    var isEnter = evt.which === 13 || evt.keyCode === 13;
    if (!evt.shiftKey && isEnter) {
      evt.preventDefault();
      _sendTxtMessage(composer.value);
    }
  };
  var _updateCharCounter = function() {
    $('#character-count').text(composer.value.length);
  };

  TextChat.prototype = {
    constructor: TextChat,
    isEnabled: function() {
      return _enabled;
    },
    isDisplayed: function() {
      return _displayed;
    },
    showTextChat: function(value) {
      _showTextChat();
    },
    hideTextChat: function(value) {
      _hideTextChat();
    }
  };
  return TextChat;
})();
var OTKAnalytics = (function() {

    var OTKAnalyticsComponent = function(data) {
        this.url = 'https://hlg.tokbox.com/prod/logging/ClientEvent';

        this.analyticsData = data;
    }

    var _checkData = function() {
        var self = this;
        
        if ( self.analyticsData.sessionId === null || self.analyticsData.sessionId.length === 0){
            console.log ("Error. The sessionId field cannot be null in the log entry");
            throw("The sessionId field cannot be null in the log entry");
        }
        if ( self.analyticsData.connectionId == null || self.analyticsData.connectionId.length == 0){
            console.log ("Error. The connectionId field cannot be null in the log entry");
            throw("The connectionId field cannot be null in the log entry");
        }
        if ( self.analyticsData.partnerId == 0){
            console.log ("Error. The partnerId field cannot be null in the log entry");
            throw("The partnerId field cannot be null in the log entry");
        }
        if ( self.analyticsData.clientVersion == null || self.analyticsData.clientVersion.length == 0){
            console.log ("Error. The clientVersion field cannot be null in the log entry");
            throw("The clientVersion field cannot be null in the log entry");
        }
        if ( self.analyticsData.source == null || self.analyticsData.source.length == 0){
            console.log ("Error. The source field cannot be null in the log entry");
            throw("The source field cannot be null in the log entry");
        }
        if ( self.analyticsData.logVersion == null || self.analyticsData.logVersion.length == 0){
            self.analyticsData.logVersion  = "2";
        }
        if ( self.analyticsData.guid == null || self.analyticsData.guid.length == 0){
            self.analyticsData.guid  = _generateUuid();
        }
        if ( self.analyticsData.clientSystemTime == 0){
            self.analyticsData.clientSystemTime  = new Date().getTime();;
        }    
    };

    var _generateUuid = function() {

        // http://www.ietf.org/rfc/rfc4122.txt
        var s = [];
        var hexDigits = "0123456789abcdef";
        for (var i = 0; i < 36; i++) {
            s[i] = hexDigits.substr(Math.floor(Math.random() * 0x10), 1);
        }
        s[14] = "4";  // bits 12-15 of the time_hi_and_version field to 0010
        s[19] = hexDigits.substr((s[19] & 0x3) | 0x8, 1);  // bits 6-7 of the clock_seq_hi_and_reserved to 01
        s[8] = s[13] = s[18] = s[23] = "-";

        var uuid = s.join("");
        return uuid;
    }

    var _sendData = function() {
        var self = this;

        var payload = self.analyticsData.payload || "";

        if (typeof(payload) === "object") {
            payload = JSON.stringify(payload);
        }

        self.analyticsData.payload = payload;

        var urlEncodedData = JSON.stringify(self.analyticsData);

        var http = new XMLHttpRequest();
        http.open("POST", self.url, true);
        http.setRequestHeader("Content-type", "application/json");
        http.send(urlEncodedData);
    };

    OTKAnalyticsComponent.prototype =  {
        constructor: OTKAnalytics,

        logEvent: function(data) { 
            
            this.analyticsData.action = data.action;
            this.analyticsData.variation = data.variation;

            //check values
            _checkData.call(this);

            //send data to analytics server
            _sendData.call(this);
        }
    }
    return OTKAnalyticsComponent;
})();
