/* global AcceleratorPack CommunicationAccPack */

var app = (function () {

  // Modules
  var _accPack;
  var _communication;

  // OpenTok session
  var _session;

  // Application State
  var _connected = false;
  var _callActive = false;
  var _remoteParticipant = false;
  var _callProps = {
    enableLocalAudio: true,
    enableLocalVideo: true,
    enableRemoteAudio: true,
    enableRemoteVideo: true,
  };

  // Options hash
  var _options = {
    apiKey: '', // Replace with your OpenTok API key
    sessionId: '', // Replace with a generated Session ID
    token: '', // Replace with a generated token
    user: {
      name: 'User1'
    },
    textChat: function () {
      return {
        sender: {
          alias: 'user1',
        },
        limitCharacterMessage: 160,
        controlsContainer: '#feedControls',
        textChatContainer: '#chatContainer'
      };
    }
  };

  /** DOM Helper Methods */
  var _makePrimaryVideo = function (element) {
    $(element).addClass('primary-video');
    $(element).removeClass('secondary-video');
  };

  var _makeSecondaryVideo = function (element) {
    $(element).removeClass('primary-video');
    $(element).addClass('secondary-video');
  };

  // Swap positions of the small and large video elements when participant joins or leaves call
  var _swapVideoPositions = function (type) {

    if (type === 'start' || type === 'joined') {

      _makePrimaryVideo('#videoHolderBig');
      _makeSecondaryVideo('#videoHolderSmall');

      /**
       * The other participant may or may not have joined the call at this point.
       */
      if (!!_remoteParticipant) {
        $('#remoteControls').show();
        $('#videoHolderBig').show();
      }

    } else if ((type === 'end' && !!_remoteParticipant) || type === 'left') {

      _makePrimaryVideo('#videoHolderSmall');
      _makeSecondaryVideo('#videoHolderBig');

      $('#remoteControls').hide();
      $('#videoHolderBig').hide();
    }

  };

  var _startCall = function () {

    // Start call
    _communication.start();
    _callActive = true;

    // Update UI
    $('#callActive').addClass('active');
    $('#videoHolderSmall').addClass('active');

    $('#enableLocalAudio').show();
    $('#enableLocalVideo').show();

    if (_remoteParticipant) {
      _swapVideoPositions('start');
    }

  };

  var _endCall = function () {

    // End call
    _communication.end();
    _callActive = false;

    // Update UI
    $('#callActive').toggleClass('active');

    $('#enableLocalAudio').hide();
    $('#enableLocalVideo').hide();

    if (_callActive || _remoteParticipant) {
      _swapVideoPositions('end');
    }

  };

  var _connectCall = function () {

    if (!!_callActive) {
      _endCall();
    } else {
      _startCall();
    }

  };

  // Toggle local or remote audio/video
  var _toggleMediaProperties = function (type) {

    _callProps[type] = !_callProps[type];

    _communication[type](_callProps[type]);

    $(['#', type].join('')).toggleClass('disabled');

  };

  var _addEventListeners = function () {

    // Call events
    _accPack.registerEventListener('streamCreated', function (event) {

      if (event.stream.videoType === 'camera') {
        _remoteParticipant = true;
        if (_callActive) {
          _swapVideoPositions('joined');
        }
      }

    });

    _accPack.registerEventListener('streamDestroyed', function (event) {

      if (event.stream.videoType === 'camera') {
        _remoteParticipant = false;
        if (_callActive) {
          _swapVideoPositions('left');
        }
      }

    });

    // Start or end call
    $('#callActive').on('click', _connectCall);

    // Click events for enabling/disabling audio/video
    var controls = [
      'enableLocalAudio',
      'enableLocalVideo',
      'enableRemoteAudio',
      'enableRemoteVideo'
    ];
    controls.forEach(function (control) {
      $(['#', control].join('')).on('click', function () {
        _toggleMediaProperties(control);
      });
    });
  };

  var init = function () {
    // Get session
    var accPackOptions = _.extend({},
      _.pick(_options, ['apiKey', 'sessionId', 'token']), {
        textChat: _options.textChat()
      }
    );

    _accPack = new AcceleratorPack(accPackOptions);
    _session = _accPack.getSession();
    _.extend(_options, _accPack.getOptions());

    _session.on({
      connectionCreated: function (event) {

        console.log(event);

        if (_connected) {
          return;
        }

        _connected = true;

        var commOptions = _.extend({}, _options, {
          session: _session,
          accPack: _accPack
        }, _accPack.getOptions());

        _communication = new CommunicationAccPack(commOptions);
        _addEventListeners();
      }
    });
  };

  return init;
}());

app();
