/* global AcceleratorPack CommunicationAccPack */
(function () {

  // Modules
  var _accPack;
  var _communication;

  // OpenTok session
  var _session;

  // Application State
  var _initialized = false;
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
    apiKey: '45621172', // Add you OpenTok API Key here
    sessionId: '2_MX40NTYyMTE3Mn5-MTQ3MTM5MzY2Nzk3M35heXBTdGZZemYvS3o3aytkU05UTWFUQ2l-fg', // Add your OpenTok session id here
    token: 'T1==cGFydG5lcl9pZD00NTYyMTE3MiZzaWc9OWMwNjc0ZWVjMTFiYTc2MmMxY2MxN2JhZWNmNzk0YTE2MzgzZmIzYjpzZXNzaW9uX2lkPTJfTVg0ME5UWXlNVEUzTW41LU1UUTNNVE01TXpZMk56azNNMzVoZVhCVGRHWlplbVl2UzNvM2F5dGtVMDVVVFdGVVEybC1mZyZjcmVhdGVfdGltZT0xNDcxMzkzNjc1Jm5vbmNlPTAuNTk1NzI0ODUwMTk0NTI4NyZyb2xlPXB1Ymxpc2hlciZleHBpcmVfdGltZT0xNDcxMzk3Mjc0', // Add your OpenTok session token here
    textChat: {
      sender: {
        alias: 'user1',
      },
      limitCharacterMessage: 160,
      controlsContainer: '#feedControls',
      textChatContainer: '#chatContainer'
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

  var _init = function () {
    // Get session
    var accPackOptions = _.pick(_options, ['apiKey', 'sessionId', 'token', 'textChat']);

    _accPack = new AcceleratorPack(accPackOptions);
    _session = _accPack.getSession();
    _.extend(_options, _accPack.getOptions());

    _session.on({
      connectionCreated: function () {

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
        _initialized = true;
        _startCall();
      }
    });
  };

  var _connectCall = function () {

    if (!_initialized) {
      _init();
    } else {
      !_callActive ? _startCall() : _endCall();
    }

  };

  document.addEventListener('DOMContentLoaded', function () {
    // Start or end call
    $('#callActive').on('click', _connectCall);
  });

}());
