var AcceleratorPack = (function() {

  var _textChat;
  var _session;
  var _isConnected = false;

  // Constructor
  var AcceleratorPackLayer = function (apiKey, sessionId, token) {
    // Get session
    _session = OT.initSession(apiKey, sessionId);
    self = this;
    // Connect
    _session.connect(token, function(error) {
      if (error) {
        console.log('Session failed to connect');
      } else {
        _textChat = new TextChatAccPack(
          {
            charCountElement: "#character-count",
            acceleratorPack: self,
            sender: {
              id: 1,
              alias: "Marco"
            },
          });
        _isConnected = true;
      }
    });
  };

  AcceleratorPackLayer.prototype = {
    constructor: AcceleratorPack,

    getSession: function(){
      return _session;
    },

    connectTextChat: function() {
      if(_textChat.getEnableTextChat()){
        if(_textChat.getDisplayTextChat())
          _textChat.hideTextChat();
        else
          _textChat.showTextChat();
      }
      else{
        _textChat.initTextChat("#chat-container");
      }
    },
  };
  return AcceleratorPackLayer;
})();
