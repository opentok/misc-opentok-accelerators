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
  var _viewingSharedScreen = false;
  var _callProps = {
    enableLocalAudio: true,
    enableLocalVideo: true,
    enableRemoteAudio: true,
    enableRemoteVideo: true,
  };

  // Options hash
  var _options = {
    apiKey: '45589022',
    sessionId: '1_MX40NTU4OTAyMn5-MTQ2NDc5NzE5ODUzOH5HazV0QnpCdE9zbVB3cEtuR0hnZGpYUnV-fg',
    token: 'T1==cGFydG5lcl9pZD00NTU4OTAyMiZzZGtfdmVyc2lvbj10YnBocC12MC45MS4yMDExLTA3LTA1JnNpZz1kYWNiMzc0NzU4NzE3NGIyYjdjODg3ZmM5MDM2OTc0YTY5ZjgwNDU5OnNlc3Npb25faWQ9MV9NWDQwTlRVNE9UQXlNbjUtTVRRMk5EYzVOekU1T0RVek9INUhhelYwUW5wQ2RFOXpiVkIzY0V0dVIwaG5aR3BZVW5WLWZnJmNyZWF0ZV90aW1lPTE0Njc3MzEwNjkmcm9sZT1tb2RlcmF0b3Imbm9uY2U9MTQ2NzczMTA2OS42NTc5OTA3NTg2MjImZXhwaXJlX3RpbWU9MTQ3MDMyMzA2OQ==',
    screensharing: {
      extensionID: 'knmknlapoidpamfmadaalafimbjegekh',
      extensionPathFF: 'ff-extension/wms-screensharing.xpi',
      annotation: true
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

  var _viewSharedScreen = function (viewing) {

    if (viewing) {

      if (_callActive) {
        $('#videoHolderSmall').hide();
        $('#videoHolderBig').hide();
        $('#videoHolderSharedScreen').show();
        $('#toolbar').show();
        $('#feedControls').addClass('viewing-shared-screen');
      }

    } else {

      $('#videoHolderSmall').show();
      $('#videoHolderBig').show();
      $('#videoHolderSharedScreen').hide();
      $('#feedControls').removeClass('viewing-shared-screen');

    }

    _viewingSharedScreen = viewing;
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

      if (_viewingSharedScreen) {
        _viewSharedScreen(true);
      }


    } else if ((type === 'end' && !!_remoteParticipant) || type === 'left') {

      _makePrimaryVideo('#videoHolderSmall');
      _makeSecondaryVideo('#videoHolderBig');

      $('#remoteControls').hide();
      $('#videoHolderBig').hide();

      if (_viewingSharedScreen) {
        $('#videoHolderSharedScreen').hide();
      }
    }

  };

  /**
   * Toggle local or remote audio/video
   * @param {String} type Which of the properties in _callProps
   * @param {Boolean} [reset] Set to true?
   */
  var _toggleMediaProperties = function (type, reset) {
    _callProps[type] = reset ? true : !_callProps[type];
    _communication[type](_callProps[type]);
    $(['#', type].join(''))[reset ? 'removeClass' : 'toggleClass']('disabled');
  };

  /**
   * Reset all call props to true (enabled)
   */
  var _resetCallProps = function () {
    Object.keys(_callProps).forEach(function (type) {
      _toggleMediaProperties(type, true);
    });
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
    _resetCallProps();
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

    _accPack.registerEventListener('startScreenSharing', function () {
      $('#sharingMask').show();
    });

    _accPack.registerEventListener('endScreenSharing', function () {
      $('#sharingMask').hide();
    });

    _accPack.registerEventListener('startViewingSharedScreen', function () {
      _viewSharedScreen(true);
    });

    _accPack.registerEventListener('endViewingSharedScreen', function () {
      _viewSharedScreen(false);
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

    var accPackOptions = _.pick(_options, ['apiKey', 'sessionId', 'token', 'screensharing']);

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
      _callActive ? _endCall() : _startCall();
    }
  };

  var setCredenials = function () {
    var el = document.getElementById('credentials');
    var credentials = JSON.parse(el.getAttribute('data'));
    el.remove();
    $.extend(_options, credentials);
  };

  document.addEventListener('DOMContentLoaded', function () {
    setCredenials();
    $('#callActive').on('click', _connectCall);
  });

}());
