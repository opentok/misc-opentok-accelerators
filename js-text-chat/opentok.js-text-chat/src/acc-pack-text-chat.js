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
      '<div class="wms-character-count"><span><span id="characterCount">0</span>/' + limitCharacterMessage + ' characters</span></div>',
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
    $('#characterCount').text("0");
  };

  var _controlComposerInput = function(evt) {
    var isEnter = evt.which === 13 || evt.keyCode === 13;
    if (!evt.shiftKey && isEnter) {
      evt.preventDefault();
      _sendTxtMessage(composer.value);
    }
  };
  var _updateCharCounter = function() {
    $('#characterCount').text(composer.value.length);
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