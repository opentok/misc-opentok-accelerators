var app = (function() {

  // Sample component
  var _communication;
  var _accPack;
  var _session;
  var _connected;

  var _options = {
    apiKey: '100',
    sessionId: '2_MX4xMDB-fjE0NTg3NTI3NTc0MDB-dkdPT3hVT1RMRm85MkFUMVhBR0NXbTJufn4',
    token: 'T1==cGFydG5lcl9pZD0xMDAmc2RrX3ZlcnNpb249dGJwaHAtdjAuOTEuMjAxMS0wNy0wNSZzaWc9OTI3YTJkMTZhZjNmYmVmYzk5MDI0Y2FjODg0NTYwZjM3NWI5ODE0MTpzZXNzaW9uX2lkPTJfTVg0eE1EQi1makUwTlRnM05USTNOVGMwTURCLWRrZFBUM2hWVDFSTVJtODVNa0ZVTVZoQlIwTlhiVEp1Zm40JmNyZWF0ZV90aW1lPTE0NjEzNTU2NTMmcm9sZT1wdWJsaXNoZXImbm9uY2U9MTQ2MTM1NTY1My4zMTkxMjg3NDg1ODQ5JmV4cGlyZV90aW1lPTE0NjM5NDc2NTM=',
    user: {
      id: 1,
      name: 'User1'
    },
    screensharing: {
      extensionID: 'idhnlbjlmkghinljcijgljbmcoonppgi',
      extensionPathFF: 'ff-extension/wms-screensharing.xpi',
      annotation: true
    },
    annotation: true
  };

  var _communicationElements = {
    mainContainer: document.getElementById('main'),
    startEndCall: document.getElementById('callActive'),
    localVideo: document.getElementById('videoHolderSmall'),
    remoteVideo: document.getElementById('videoHolderBig'),
    sharedScreen: document.getElementById('videoHolderSharedScreen'),
    remoteControls: document.getElementById('remoteControls'),
    enableLocalAudio: document.getElementById('enableLocalAudio'),
    enableLocalVideo: document.getElementById('enableLocalVideo'),
    enableRemoteAudio: document.getElementById('enableRemoteAudio'),
    enableRemoteVideo: document.getElementById('enableRemoteVideo'),
    sharingPoster: document.getElementById('sharingPoster')
  };

  var _communicationProperties = {
    callActive: false,
    remoteParticipant: false,
    enableLocalAudio: true,
    enableLocalVideo: true,
    enableRemoteAudio: true,
    enableRemoteVideo: true,
    sharingScreen: false
  };

  // DOM helper functions
  var _show = function() {

    elements = Array.prototype.slice.call(arguments);

    elements.forEach(function(element) {
      element.classList.remove('hidden');
    });
  };

  var _hide = function() {

    elements = Array.prototype.slice.call(arguments);

    elements.forEach(function(element) {
      element.classList.add('hidden');
    });
  };

  var _updateClassList = function(element, className, add) {
    element.classList[add ? 'add' : 'remove'](className);
  };

  var _toggleClass = function(element, className) {
    element.classList.toggle(className);
  };

  // Swap positions of the small and large video elements when participant joins or leaves call
  var _swapVideoPositions = function(type) {

    if (type === 'start' || type === 'joined') {

      _toggleClass(_communicationElements.localVideo, 'secondary-video');
      _toggleClass(_communicationElements.localVideo, 'primary-video');
      _toggleClass(_communicationElements.remoteVideo, 'secondary-video');
      _toggleClass(_communicationElements.remoteVideo, 'primary-video');

      _show(_communicationElements.remoteControls);


    } else if (type === 'end' || type === 'left') {

      _toggleClass(_communicationElements.remoteVideo, 'secondary-video');
      _toggleClass(_communicationElements.remoteVideo, 'primary-video');
      _toggleClass(_communicationElements.localVideo, 'secondary-video');
      _toggleClass(_communicationElements.localVideo, 'primary-video');

      _hide(_communicationElements.remoteControls);
    }

  };


  // Toggle local or remote audio/video
  var _toggleMediaProperties = function(type) {

    _communicationProperties[type] = !_communicationProperties[type];

    _communication[type](_communicationProperties[type]);

    _updateClassList(_communicationElements[type], 'disabled', !_communicationProperties[type]);

  };

  var _addEventListeners = function() {

    // Call events
    _accPack.registerEventListener('streamCreated', function(event) {

      if (event.stream.videoType === 'camera') {
        // Not doing anything with the event
        _communicationProperties.remoteParticipant = true;
        _communicationProperties.callActive && _swapVideoPositions('joined');
      }
      
    });
    
    _accPack.registerEventListener('streamDestroyed', function(event) {

      if (event.stream.videoType === 'camera') {
        // Not doing anything with the event
        _communicationProperties.remoteParticipant = true;
        _communicationProperties.callActive && _swapVideoPositions('joined');
      }
      
    });

    // Start or end call
    _communicationElements.startEndCall.onclick = _connectCall;

    var _viewSharedScreen = function(viewing) {

      if (viewing) {
        _hide(_communicationElements.localVideo, _communicationElements.remoteVideo);
        _show(_communicationElements.sharedScreen);

      } else {
        _show(_communicationElements.localVideo, _communicationElements.remoteVideo);
        _hide(_communicationElements.sharedScreen);
      }
    };

    _accPack.registerEventListener('startSharingScreen', _.partial(_show, _communicationElements.sharingPoster));
    _accPack.registerEventListener('endSharingScreen', _.partial(_hide, _communicationElements.sharingPoster));
    _accPack.registerEventListener('startViewingSharedScreen', _.partial(_viewSharedScreen, true));
    _accPack.registerEventListener('endViewingSharedScreen', _.partial(_viewSharedScreen, false));

    // Click events for enabling/disabling audio/video
    var controls = ['enableLocalAudio', 'enableLocalVideo', 'enableRemoteAudio', 'enableRemoteVideo'];
    controls.forEach(function(control) {
      document.getElementById(control).onclick = function() {
        _toggleMediaProperties(control);
      };
    });
  };

  var _startCall = function() {

    // Start call
    _communication.start();
    _communicationProperties.callActive = true;
    _accPack.active(true);


    // Update UI
    [_communicationElements.startEndCall, _communicationElements.localVideo].forEach(function(element) {
      _updateClassList(element, 'active', true);
    });

    _show(_communicationElements.enableLocalAudio, _communicationElements.enableLocalVideo);

    _communicationProperties.remoteParticipant && _swapVideoPositions('start');
  };

  var _endCall = function() {

    // End call
    _communication.end();
    _communicationProperties.callActive = false;
    _accPack.active(false);

    // Update UI
    _toggleClass(_communicationElements.startEndCall, 'active');

    _hide(_communicationElements.enableLocalAudio, _communicationElements.enableLocalVideo, _communicationElements.shareScreen);

    !!(_communicationProperties.callActive || _communicationProperties.remoteParticipant) && _swapVideoPositions('end');
  };

  var _connectCall = function() {

    !_communicationProperties.callActive ? _startCall() : _endCall();

  };

  var init = function() {
    // Get session
    var accPackOptions = _.pick(_options, ['apiKey', 'sessionId', 'token', 'screensharing']);

    _accPack = new AcceleratorPack(accPackOptions);
    _session = _accPack.getSession();
    _.extend(_options, _accPack.getOptions());

    _session.on({
      connectionCreated: function(event) {

        if (_connected) {
          return;
        }

        _connected = true;

        var commOptions = _.extend({}, _options, { session: _session, accPack: _accPack }, _accPack.getOptions());
        console.log(commOptions);
        _communication = new Communication(commOptions);
        _addEventListeners(); 
      }
    });
  };

  return init;
})();

app();