var app = (function() {

    // Sample component
    var _communication;

    var _options = {
        apiKey: '100',
        sessionId: '2_MX4xMDB-fjE0NTc1NTU4Mjk4NDN-M0RvR0JjMFlUSFp1SkdzbUZzRmd4UEhmfn4',
        token: 'T1==cGFydG5lcl9pZD0xMDAmc2RrX3ZlcnNpb249dGJwaHAtdjAuOTEuMjAxMS0wNy0wNSZzaWc9NTIxNjk1MmNiNDViZjgxZDdlZmI2M2Q0MmU5YzZiMWFlYTgwNWYxNjpzZXNzaW9uX2lkPTJfTVg0eE1EQi1makUwTlRjMU5UVTRNams0TkROLU0wUnZSMEpqTUZsVVNGcDFTa2R6YlVaelJtZDRVRWhtZm40JmNyZWF0ZV90aW1lPTE0NTg2NjYwMTUmcm9sZT1tb2RlcmF0b3Imbm9uY2U9MTQ1ODY2NjAxNS44MDUxNDc1Njg4NDcyJmV4cGlyZV90aW1lPTE0NjEyNTgwMTUmY29ubmVjdGlvbl9kYXRhPW1hcmNvMg==',
        publishers: {},
        subscribers: [],
        streams: [],
        user: {
            id: 1,
            name: 'User1'
        },
        localCallProperties: {
            insertMode: 'append',
            width: '100%',
            height: '100%',
            showControls: false,
            style: {
                buttonDisplayMode: 'off'
            }
        }
    };

    var _communicationElements = {
        startEndCall: document.getElementById('callActive'),
        localVideo: document.getElementById('videoHolderSmall'),
        remoteVideo: document.getElementById('videoHolderBig'),
        remoteControls: document.getElementById('remoteControls'),
        enableLocalAudio: document.getElementById('enableLocalAudio'),
        enableLocalVideo: document.getElementById('enableLocalVideo'),
        enableRemoteAudio: document.getElementById('enableRemoteAudio'),
        enableRemoteVideo: document.getElementById('enableRemoteVideo'),
        enableTextChat: document.getElementById('enableTextChat'),
        textChatDiv: document.getElementById('chat-container')
    };

    var _communicationProperties = {
        callActive: false,
        remoteParticipant: false,
        enableLocalAudio: true,
        enableLocalVideo: true,
        enableRemoteAudio: true,
        enableRemoteVideo: true,
        enableTextChat: false,
        displayTextChat: false
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
        _communication.onParticipantJoined = function(event) {

            // Not doing anything with the event
            _communicationProperties.remoteParticipant = true;
            _communicationProperties.callActive && _swapVideoPositions('joined');

        };

        _communication.onParticipantLeft = function(event) {
            // Not doing anything with the event  
            _communicationProperties.remoteParticipant = false;
            _communicationProperties.callActive && _swapVideoPositions('left');

        };

        // Start or end call
        _communicationElements.startEndCall.onclick = _connectCall;

        // Start or end text chat
        _communicationElements.enableTextChat.onclick = _connectTextChat;

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


        // Update UI
        [_communicationElements.startEndCall, _communicationElements.localVideo].forEach(function(element) {
            _updateClassList(element, 'active', true);
        });

        _show(_communicationElements.enableLocalAudio, _communicationElements.enableLocalVideo, _communicationElements.enableTextChat);

        _communicationProperties.remoteParticipant && _swapVideoPositions('start');
    };

    var _endCall = function() {

        // End call
        _communication.end();
        _communicationProperties.callActive = false;

        // Update UI    
        _toggleClass(_communicationElements.startEndCall, 'active');

        _hide(_communicationElements.enableLocalAudio, _communicationElements.enableLocalVideo);

        !!(_communicationProperties.callActive || _communicationProperties.remoteParticipant) && _swapVideoPositions('end');
    };

    var _startTextChat = function() {

        // Start call
        _communication.startTextChat();
        _communicationProperties.enableTextChat = true;
        _communicationProperties.displayTextChat = true;

        // Update UI
        _updateClassList(_communicationElements.enableTextChat, 'active', true);
    };

    var _showTextChat = function(){
        _communicationElements.textChatDiv.classList.remove('hidden');
        _communicationProperties.displayTextChat = true;
    };

    var _hideTextChat = function() {
        _communicationElements.textChatDiv.classList.add('hidden');
        _communicationProperties.displayTextChat = false;
    };

    var _connectCall = function() {

        !_communicationProperties.callActive ? _startCall() : _endCall();

    };

    var _connectTextChat = function() {
        if(_communicationProperties.enableTextChat){
            if(_communicationProperties.displayTextChat)
                _hideTextChat();
            else
                _showTextChat();
        }
          else{
            _startTextChat()
        }
    };

    var init = function() {

        // Get session
        _options.session = OT.initSession(_options.apiKey, _options.sessionId);

        // Connect
        _options.session.connect(_options.token, function(error) {
            if (error) {
                console.log('Session failed to connect');
            } else {
                _communication = new Sample(_options);
                _addEventListeners();
            }
        });

    };

    return init;

})();

app();