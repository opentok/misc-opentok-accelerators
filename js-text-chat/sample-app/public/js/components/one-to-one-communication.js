var Sample = (function () {

  // Constructor
  var SampleComponent = function (options) {
    if (!options || !options.session) {
      throw new Error('No session provided.');
    }

    this._session = options.session;

    this.options = options;

    this._session.on('streamCreated', this._handleParticipantJoined.bind(this)); //participant joined to the call

    this._session.on('streamDestroyed', this._handleParticipantLeft.bind(this)); //participant left the call

    var _otkanalyticsData = {
      sessionId: this.options.sessionId,
      connectionId: this._session.connection.connectionId,
      partnerId: this.options.apiKey,
      clientVersion: '1.0.0'
    };

    var _otkanalytics = new OTKAnalytics(_otkanalyticsData);

    var _loggingData = {action: 'one-to-one-sample-app', variation: ''};

    _otkanalytics.logEvent(_loggingData);

  };

  // Private methods
  var _publish = function (type) {
    currentSource = type;
    var handler = this.onError;

    this._initPublisherCamera();

    return this._session.publish(this.options.publishers[type], function (error) {
      if (error) {
        console.log("Error starting a call " + error.code + " - " + error.message);
        error.message = "Error starting a call";
        if (error.code === 1010) {
          var errorStr = error.message + ". Check your network connection.";
          error.message = errorStr;
        }
        _handleError(error, handler);
      }
    });
  };

  var _unpublish = function (type) {
    var self = this;
    if (this.options.publishers[type]) {
      self._session.unpublish(this.options.publishers[type]);
    }
  };

  var _initPublisherCamera = function () {
    var self = this;
    if (self.options.user) {
      this.options.localCallProperties.name = self.options.user.name;
    }
    self.options.publishers.camera = OT.initPublisher('videoHolderSmall', self.options.localCallProperties, function (error) {
      if (error) {
        error.message = "Error starting a call";
        _handleError(error, handler);
      }
      //self.options.publishers.camera.on('streamDestroyed', this._publisherStreamDestroyed);
    });
  };

  var _publisherStreamDestroyed = function (event) {
    console.log('publisherStreamDestroyed', event);
    event.preventDefault();
  };

  var _subscribeToStream = function (stream) {
    var self = this;
    var handler = this.onError;
    if (stream.videoType == "screen") {
      var options = self.options.localScreenProperties
    } else {
      var options = self.options.localCallProperties
    }

    var subscriber = self._session.subscribe(stream,
      'videoHolderBig',
      options, function (error) {
        if (error) {
          console.log("Error starting a call " + error.code + " - " + error.message);
          error.message = "Error starting a call";
          if (error.code === 1010) {
            var errorStr = error.message + ". Check your network connection."
            error.message = errorStr;
          }
          _handleError(error, handler);
        } else {
          self.options.streams.push(subscriber);
          console.log('Subscriber added.');
          var handler = self.onSubscribe;
          if (handler && typeof handler === 'function') {
            handler(stream);
          }

        }
      });
    self.subscriber = subscriber;
  };

  var _unsubscribeStreams = function () {
    var self = this;
    _.each(this.options.streams, function (stream) {
      self._session.unsubscribe(stream);
    })
  };

  // Private handlers
  var _handleStart = function (event) {
    var self = this;
    var handler = this.onStarted;
    if (handler && typeof handler === 'function') {
      handler();
    }
  };

  var _handleEnd = function (event) {
    console.log("Call ended");
    var self = this;

    var handler = this.onEnded;
    if (handler && typeof handler === 'function') {
      handler();
    }
  };

  var _handleParticipantJoined = function (event) {
    console.log("Participant joined to the call");
    var self = this;
    //TODO: check the joined participant
    self.options.subscribers.push(event.stream);
    if (self.options.inSession) {
      self._remoteParticipant = event.connection;
      self._subscribeToStream(event.stream);
    }

    var handler = this.onParticipantJoined;
    if (handler && typeof handler === 'function') {
      handler(event); //TODO: it should be the user
    }
  };

  var _handleParticipantLeft = function (event) {
    var self = this;
    console.log('Participant left the call');
    var streamDestroyedType = event.stream.videoType;

    //remove to the subscribers list
    var index = self.options.subscribers.indexOf(event.stream);
    self.options.subscribers.splice(index, 1);

    if (streamDestroyedType == 'camera') {

      this.subscriber = null; //to review
      self._remoteParticipant = null;
      var handler = this.onParticipantLeft;

    } else if (streamDestroyedType === 'screen') {

      self.onScreenSharingEnded();

    } else {
      _.each(self.options.subscribers, function (subscriber) {
        self._subscribeToStream(subscriber);
      });
    }

//        var handler = this.onParticipantLeft(streamDestroyedType);
    var eventData = {
      userId: 'event.stream.connectionId'
    };
    if (handler && typeof handler === 'function') {
      handler(eventData); //TODO: it should be the user (userId and username)
    }
  };

  var _handleLocalPropertyChanged = function (event) {
    console.log('Local property changed');
    var handler = this.onEnableLocalMedia;
    if (event.changedProperty == 'hasAudio') {
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
    var handler = this.onEnableLocalMedia;
    if (handler && typeof handler === 'function') {
      handler(eventData);
    }
  };

  var _handleRemotePropertyChanged = function (data) {
    //TODO
  };

  var _handleError = function (error, handler) {
    if (handler && typeof handler === 'function') {
      handler(error);
    }
  };

  //    **************************************************************************************************************
  //    **************************************************************************************************************
  //    **************************************************************************************************************

  //textChat Events and functions

  var _shouldAppendMessage = function (data) {
    return this.lastMessage && this.lastMessage.user.id == data.user.id && moment(this.lastMessage.sentOn).fromNow() == moment(data.sentOn).fromNow();
  };

  var _sendTxtMessage = function (text) {
    var self = this;
    if (!_.isEmpty(text)) {
      $.when(self._sendMessage(self._remoteParticipant, text))
        .then(function (data) {
          self._handleMessageSent({user: self.options.user, message: text, sentOn: new Date()});
          if (this.futureMessageNotice)
            this.futureMessageNotice = false;
        }, function (error) {
          self._handleMessageError(error);
        });
    }
  };

  var _sendMessage = function (recipient, message) {
    var deferred = new $.Deferred();
    var self = this;
    var message_data = {
      message: arguments[1],
      user: this.options.user,
      sentOn: new Date()
    };
    console.log(self._session);
    if (recipient === undefined) {
      self._session.signal({
          type: 'chat',
          data: message_data,
        },
        function (error) {
          if (error) {
            error.message = "Error sending a message. ";
            if (error.code === 413) {
              var errorStr = error.message + "The chat message is over size limit."
              error.message = errorStr;
            }
            else {
              if (error.code === 500) {
                var errorStr = error.message + "Check your network connection."
                error.message = errorStr;
              }
            }
            deferred.reject(error);
          } else {
            console.log('Message sent');
            deferred.resolve(message_data);
          }
        }
      );
    }
    else {
      self._session.signal({
          type: 'chat',
          data: message_data,
          to: recipient
        }, function (error) {
          if (error) {
            console.log('Error sending a message');
            deferred.resolve(error);
          } else {
            console.log('Message sent');
            deferred.resolve(message_data);
          }
        }
      );
    }

    return deferred.promise();
  };
  var _handleMessageSent = function (data) {
    if (this._shouldAppendMessage(data)) {
      $('.wms-item-text').last().append('<span>' + data.message + '</span>');
      var chatholder = $(this._textChat._newMessages);
      chatholder[0].scrollTop = chatholder[0].scrollHeight;
      this._textChat._cleanComposer();

    } else {
      this._renderChatMessage(data.user, data.message, data.sentOn);
    }
    this.lastMessage = data;
  };
  var _onIncomingMessage = function (signal) {
    if (this._shouldAppendMessage(signal.data)) {
      $(".wms-item-text").last().append('<span>' + signal.data.message + '</span>');
    } else {
      this._renderChatMessage(signal.data.user, signal.data.message, signal.data.sentOn);
    }
    this.lastMessage = signal.data;
  };
  var _handleMessageError = function (error) {
    console.log(error.code, error.message);
    if (error.code === 500) {
      var view = _.template($('#chatError').html());
      $(this.comms_elements.messagesView).append(view());
    }
  };
  var _renderChatMessage = function (user, message, sentOn) {
    var self = this;
    var sent_by_class = user.id == self.options.user.id ? 'wms-message-item wms-message-sent' : 'wms-message-item';

    var view = this._textChat.getBubbleHtml({
      username: user.name,
      message: message,
      message_class: sent_by_class,
      time: sentOn
    });
    var chatholder = $(this._textChat._newMessages);
    chatholder.append(view);
    this._textChat._cleanComposer();
    chatholder[0].scrollTop = chatholder[0].scrollHeight;
  };

  var _handleTextChat = function (event) {
    var me = this._session.connection.connectionId;
    var from = event.from.connectionId;
    if (from !== me) {
      var handler = this._onIncomingMessage(event);
      if (handler && typeof handler === 'function') {
        handler(event);
      }
    }
  };

  //    **************************************************************************************************************
  // Prototype methods
  SampleComponent.prototype = {
    constructor: Sample,

    onStarted: function () {
    },
    onEnded: function () {
    },
    onSubscribe: function () {
    },
    onParticipantJoined: function (event) {
    },
    onParticipantLeft: function (event) {
    },
    onEnableLocalMedia: function (event) {
    },
    onEnableRemoteMedia: function (event) {
    },
    onError: function (error) {
    },

    start: function (recipient) {
      //TODO: Managing call status: calling, startCall,...using the recipient value
      var self = this;

      this.options.inSession = true;

      this.publisher = this._publish('camera');

      $.when(this.publisher.on('streamCreated'))
        .done(function (event) {
          self._handleStart(event)
        })
        .promise(); //call has been initialized

      this.publisher.on('streamDestroyed', function (event) {
        console.log("stream destroyed");
        self._handleEnd(event); //call has been finished
      });

      this.publisher.session.on('streamPropertyChanged', function (event) {
        if (self.publisher.stream == event.stream)
          self._handleLocalPropertyChanged(event)
      }); //to handle audio/video changes

      if (this.options.subscribers.length > 0) {
        _.each(this.options.subscribers, function (subscriber) {
          self._subscribeToStream(subscriber);
        });
      }
    },
    end: function () {
      this.options.inSession = false;
      this._unpublish('camera');
      this._unsubscribeStreams();
    },
    startTextChat: function(){
      this.options.widget = this;
      this.options.text_chat_widget_holder = "#chat-container";
      this._textChat = new OTSolution.TextChat.ChatUI(this.options);
      this._session.on('signal:chat', this._handleTextChat.bind(this));
    },
    enableLocalAudio: function (enabled) {
      this.options.publishers['camera'].publishAudio(enabled);
    },
    enableLocalVideo: function (enabled) {
      this.options.publishers['camera'].publishVideo(enabled);
    },
    enableRemoteVideo: function (enabled) {
      this.subscriber.subscribeToVideo(enabled);
      this.onEnableRemoteMedia({media: "video", enabled: enabled});
    },
    enableRemoteAudio: function (enabled) {
      this.subscriber.subscribeToAudio(enabled);
      this.onEnableRemoteMedia({media: "audio", enabled: enabled});
    },
    //private methods
    _publish: function (type) {
      return _publish.call(this, type);
    },
    _unpublish: function (type) {
      _unpublish.call(this, type)
    },
    _initPublisherCamera: function (callback) {
      _initPublisherCamera.call(this, callback);
    },
    _subscribeToStream: function (stream) {
      _subscribeToStream.call(this, stream);
    },
    _unsubscribeStreams: function () {
      _unsubscribeStreams.call(this);
    },
    //handlers
    _handleStart: function (event) {
      _handleStart.call(this, event);
    },
    _handleEnd: function (event) {
      _handleEnd.call(this, event);
    },
    _handleParticipantJoined: function (event) {
      _handleParticipantJoined.call(this, event);
    },
    _handleParticipantLeft: function (event) {
      _handleParticipantLeft.call(this, event);
    },
    _handleLocalPropertyChanged: function (event) {
      _handleLocalPropertyChanged.call(this, event);
    },
    _handleRemotePropertyChanged: function (data) {
      _handleRemotePropertyChanged.call(this, data);
    },
    _handleTextChat: function (data) {
      _handleTextChat.call(this, data);
    },
    _sendTxtMessage: function (data) {
      _sendTxtMessage.call(this, data);
    },
    _sendMessage: function (recipient, message) {
      _sendMessage.call(this, recipient, message);
    },
    _handleMessageSent: function (data) {
      _handleMessageSent.call(this, data);
    },
    _shouldAppendMessage: function (data) {
      return _shouldAppendMessage.call(this, data);
    },
    _renderChatMessage: function (user, message, sentOn) {
      _renderChatMessage.call(this, user, message, sentOn);
    },
    _onIncomingMessage: function (data) {
      _onIncomingMessage.call(this, data);
    },
    _handleMessageError: function (data) {
      _handleMessageError.call(this, data);
  }
  };

  return SampleComponent;

})();
