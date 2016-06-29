/* global OTKAnalytics moment define */
(function () {

  // Reference to instance of TextChatAccPack
  var _this;
  var _session;

  /** Analytics */
  var _otkanalytics;

  var _logEventData = {
    // vars for the analytics logs. Internal use
    clientVersion: 'js-vsol-1.0.0',
    componentId: 'textChatAccPack',
    actionInitialize: 'Init',
    actionSendMessage: 'SendMessage',
    actionReceiveMessage: 'ReceiveMessage',
    actionMaximize: 'Maximize',
    actionMinimize: 'Minimize',
    actionSetMaxLength: 'SetMaxLength',
    variationAttempt: 'Attempt',
    variationError: 'Failure',
    variationSuccess: 'Success'
  };

  var _createCookie = function (name,value,days) {
    if (days) {
        var date = new Date();
        date.setTime(date.getTime()+(days*24*60*60*1000));
        var expires = "; expires="+date.toGMTString();
    }
    else var expires = "";
    var guid = name+"="+value+expires+"; path=/";
    document.cookie = guid;
    return 
  }

  var _readCookie = function (name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for(var i=0;i < ca.length;i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1,c.length);
        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
    }
    return null;
  } 

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

  var _logAnalytics = function () {

    // init the analytics logs
    var _source = window.location.href;
    
    var _guid = _readCookie('guidTextChatAccPack')
    if ( !_guid) {
      _guid = _createCookie('guidTextChatAccPack', _generateUuid(), 7);
    } 
   
    var otkanalyticsData = {
      clientVersion: _logEventData.clientVersion,
      source: _source,
      componentId: _logEventData.componentId,
      guid: _guid
    };
    
    _otkanalytics = new OTKAnalytics(otkanalyticsData);
   
    var sessionInfo = {
      sessionId: _session.id,
      connectionId: _session.connection.connectionId,
      partnerId: _session.apiKey
    }
    
    _otkanalytics.addSessionInfo(sessionInfo);
  
  };

  var _log = function (action, variation) {
    var data = {
      action: action,
      variation: variation
    };
    _otkanalytics.logEvent(data);
  };
  
  /** End Analytics */

  // State vars
  var _enabled = false;
  var _displayed = false;
  var _initialized = false;
  var _controlAdded = false;
  var _sender;
  var _composer;
  var _lastMessage;
  var _newMessages;

  // Reference to Accelerator Pack Common Layer
  var _accPack;

  var _triggerEvent = function (event, data) {
    _accPack && _accPack.triggerEvent(event, data);
  };

  // Private methods
  var renderUILayout = function () {
    /* eslint-disable max-len, prefer-template */
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
      '<input type="text" maxlength=' + _this.options.limitCharacterMessage + ' class="wms-message-input" placeholder="Enter your message here" id="messageBox">',
      '<button class="wms-icon-check" id="sendMessage" type="submit"></button>',
      '<div class="wms-character-count"><span><span id="characterCount">0</span>/' + _this.options.limitCharacterMessage + ' characters</span></div>',
      '</div>',
      '</div>',
      '</div>',
      '</div>'
    ].join('\n');
    /* eslint-enable max-len, prefer-template */
  };

  var _shouldAppendMessage = function (data) {

    if (_lastMessage) {
      return _lastMessage.sender.id === data.sender.id && _lastMessage.sender.id === data.sender.id;
    }

    return false;

  };

  var _cleanComposer = function () {
    _composer.value = '';
    $('#characterCount').text('0');
  };


  var _getBubbleHtml = function (message) {
    /* eslint-disable max-len, prefer-template */
    var bubble = [
      '<div class="' + message.messageClass + '" >',
      '<div class="wms-user-name-initial"> ' + message.username[0] + '</div>',
      '<div class="wms-item-timestamp"> ' + message.username + ', <span data-livestamp=" ' + new Date(message.time) + '" </span></div>',
      '<div class="wms-item-text">',
      '<span> ' + message.message + '</span>',
      '</div>',
      '</div>'
    ].join('\n');
    /* eslint-enable max-len, prefer-template */
    return bubble;
  };

  var _renderChatMessage = function (messageSenderId, messageSenderAlias, message, sentOn) {

    var sentByClass = _sender.id === messageSenderId ? 'wms-message-item wms-message-sent' : 'wms-message-item';

    var view = _getBubbleHtml({
      username: messageSenderAlias,
      message: message,
      messageClass: sentByClass,
      time: sentOn
    });

    var chatholder = $(_newMessages);
    chatholder.append(view);
    _cleanComposer();
    chatholder[0].scrollTop = chatholder[0].scrollHeight;

  };

  var _handleMessageSent = function (data) {
    if (_shouldAppendMessage(data)) {
      $('.wms-item-text').last().append(['<span>', data.message, '</span>'].join(''));
      var chatholder = $(_newMessages);
      chatholder[0].scrollTop = chatholder[0].scrollHeight;
      _cleanComposer();

    } else {
      _renderChatMessage(_sender.id, _sender.alias, data.message, data.sentOn);
    }
    _lastMessage = data;

    _triggerEvent('messageSent', data);

  };

  var _handleMessageError = function (error) {
    console.log(error.code, error.message);
    if (error.code === 500) {
      var view = _.template($('#chatError').html());
      $(_this.comms_elements.messagesView).append(view());
    }
    _triggerEvent('errorSendingMessage', error);
  };


  var _sendMessage = function (recipient, message) {
    var deferred = new $.Deferred();
    var messageData = {
      text: message,
      sender: {
        id: _sender.id,
        alias: _sender.alias,
      },
      sentOn: Date.now()
    };

    // Add SEND_MESSAGE attempt log event
    _log(_logEventData.actionSendMessage, _logEventData.variationAttempt);

    if (recipient === undefined) {
      _session
        .signal({
          type: 'text-chat',
          data: JSON.stringify(messageData)
        }, function (error) {
          if (error) {
            var errorMessage = 'Error sending a message. ';
            // Add SEND_MESSAGE failure log event
            _log(_logEventData.actionSendMessage, _logEventData.variationFailure);
            if (error.code === 413) {
              errorMessage += 'The chat message is over size limit.';
            } else {
              if (error.code === 500) {
                errorMessage += 'Check your network connection.';
              }
            }
            deferred.reject(_.extend(_.omit(error, 'message')), {
              message: errorMessage
            });
          } else {
            console.log('Message sent');
            // Add SEND_MESSAGE success log event
            _log(_logEventData.actionSendMessage, _logEventData.variationSuccess);
            deferred.resolve(messageData);
          }
        });
    } else {
      _session.signal({
        type: 'text-chat',
        data: JSON.stringify(messageData),
        to: recipient
      }, function (error) {
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


  var _sendTxtMessage = function (text) {
    if (!_.isEmpty(text)) {
      $.when(_sendMessage(_this._remoteParticipant, text))
        .then(function () {
          _handleMessageSent({
            sender: {
              id: _sender.id,
              alias: _sender.alias
            },
            message: text,
            sentOn: Date.now()
          });
          if (this.futureMessageNotice) {
            this.futureMessageNotice = false;
          }
        }, function (error) {
          _handleMessageError(error);
        });
    }
  };

  var _setupUI = function () {

    var parent = document.querySelector(_this.options.textChatContainer) || document.body;

    var chatView = document.createElement('section');
    chatView.innerHTML = renderUILayout();

    _composer = chatView.querySelector('#messageBox');

    _newMessages = chatView.querySelector('#messagesHolder');

    _composer.onkeyup = function updateCharCounter() {
      $('#characterCount').text(_composer.value.length);
    };

    _composer.onkeydown = function controlComposerInput(event) {
      var isEnter = (event.which === 13 || event.keyCode === 13);
      if (!event.shiftKey && isEnter) {
        event.preventDefault();
        _sendTxtMessage(_composer.value);
      }
    };

    parent.appendChild(chatView);

    document.getElementById('sendMessage').onclick = function () {
      _sendTxtMessage(_composer.value);
    };
    // Add INITIALIZE success log event
    _log(_logEventData.actionInitialize, _logEventData.variationSuccess);
  };

  var _onIncomingMessage = function (signal) {
    _log(_logEventData.actionReceiveMessage, _logEventData.variationAttempt);

    var data = JSON.parse(signal.data);

    if (_shouldAppendMessage(data)) {
      $('.wms-item-text').last().append(['<span>', data.text, '</span>'].join(''));
    } else {
      _renderChatMessage(data.sender.id, data.sender.alias, data.text, data.sentOn);
    }

    _lastMessage = data;
    _log(_logEventData.actionReceiveMessage, _logEventData.variationSuccess);
  };

  var _handleTextChat = function (event) {
    var me = _session.connection.connectionId;
    var from = event.from.connectionId;
    if (from !== me) {
      var handler = _onIncomingMessage(event);
      if (handler && typeof handler === 'function') {
        handler(event);
      }
      _triggerEvent('messageReceived', event);
    }
  };

  var _initTextChat = function () {
    // Add INITIALIZE attempt log event
    _log(_logEventData.actionInitialize, _logEventData.variationAttempt);

    _enabled = true;
    _displayed = true;
    _initialized = true;
    _setupUI();
    _triggerEvent('showTextChat');
    _session.on('signal:text-chat', _handleTextChat);
  };

  var _showTextChat = function () {
    // Add MAXIMIZE attempt log event
    _log(_logEventData.actionMaximize, _logEventData.variationAttempt);

    document.querySelector(_this.options.textChatContainer).classList.remove('hidden');
    _displayed = true;
    _triggerEvent('showTextChat');

    // Add MAXIMIZE success log event
    _log(_logEventData.actionMaximize, _logEventData.variationSuccess);
  };

  var _hideTextChat = function () {
    // Add MINIMIZE attempt log event
    _log(_logEventData.actionMinimize, _logEventData.variationAttempt);

    document.querySelector(_this.options.textChatContainer).classList.add('hidden');
    _displayed = false;
    _triggerEvent('hideTextChat');

    // Add MINIMIZE success log event
    _log(_logEventData.actionMinimize, _logEventData.variationSuccess);

  };

  var _appendControl = function () {

    var feedControls = document.querySelector(_this.options.controlsContainer);

    var el = document.createElement('div');
    el.innerHTML = '<div class="video-control circle text-chat enabled" id="enableTextChat"></div>';

    var enableTextChat = el.firstChild;
    feedControls.appendChild(enableTextChat);

    _controlAdded = true;

    enableTextChat.onclick = function () {

      if (!_initialized) {
        _initTextChat();
      } else if (!_displayed) {
        _showTextChat();
      } else {
        _hideTextChat();
      }
    };
  };


  var _validateOptions = function (options) {

    if (!options.session) {
      throw new Error('Text Chat Accelerator Pack requires an OpenTok session.');
    }

    // Generates a random alpha-numeric string of n length
    var uniqueString = function (length) {
      var len = length || 3;
      return Math.random().toString(36).substr(2, len);
    };

    // Returns session id prepended and appended with unique strings
    var generateUserId = function () {
      return [uniqueString(), _session.id, uniqueString()].join('');
    };

    _session = _.property('session')(options);
    _accPack = _.property('accPack')(options);

    /**
     * Create arbitary values for sender id and alias if not recieved
     * in options hash.
     */
    _sender = _.defaults(options.sender || {}, {
      id: generateUserId(),
      alias: ['User', uniqueString()].join(' ')
    });

    return _.defaults(_.omit(options, ['accPack', '_sender']), {
      limitCharacterMessage: 160,
      controlsContainer: '#feedControls',
      textChatContainer: '#chatContainer'
    });
  };

  var _registerEvents = function () {
    var events = [
      'showTextChat',
      'hideTextChat',
      'messageSent',
      'errorSendingMessage',
      'messageReceived'
    ];
    _accPack && _accPack.registerEvents(events);
  };

  var _addEventListeners = function () {

    if (_accPack) {

      _accPack.registerEventListener('startCall', function () {
        if (_controlAdded) {
          document.querySelector('#enableTextChat').classList.remove('hidden');
        } else {
          _appendControl();
        }
      });

      _accPack.registerEventListener('endCall', function () {
        document.getElementById('enableTextChat').classList.add('hidden');
        if (_displayed) {
          _hideTextChat();
        }
      });
    }
  };

  // Constructor
  var TextChatAccPack = function (options) {

    // Save a reference to this
    _this = this;

    // Extend instance and set private vars
    _this.options = _validateOptions(options);

    // Init the analytics logs
    _logAnalytics();

    if (!!_.property('_this.options.limitCharacterMessage')(options)) {
      _log(_logEventData.actionSetMaxLength, _logEventData.variationAttempt);
      _log(_logEventData.actionSetMaxLength, _logEventData.variationSuccess);
    }

    _appendControl();
    _registerEvents();
    _addEventListeners();
  };

  TextChatAccPack.prototype = {
    constructor: TextChatAccPack,
    isEnabled: function () {
      return _enabled;
    },
    isDisplayed: function () {
      return _displayed;
    },
    showTextChat: function () {
      _showTextChat();
    },
    hideTextChat: function () {
      _hideTextChat();
    }
  };


  if (typeof exports === 'object') {
    module.exports = TextChatAccPack;
  } else if (typeof define === 'function' && define.amd) {
    define(function () {
      return TextChatAccPack;
    });
  } else {
    this.TextChatAccPack = TextChatAccPack;
  }

}.call(this));
