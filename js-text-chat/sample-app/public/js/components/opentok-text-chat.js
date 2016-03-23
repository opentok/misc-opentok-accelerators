;(function() {
var ChatUI, opentok_text_chat;
ChatUI = function () {
  var uiLayout = [
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
    '<input type="text" maxlength="160" class="wms-message-input" placeholder="Enter your message here" id="messageBox">',
    '<button class="wms-icon-check" id="sendMessage" type="submit"></button>',
    '<div class="wms-character-count"><span><span id="character-count">0</span>/160 characters</span></div>',
    '</div>',
    '</div>',
    '</div>',
    '</div>'
  ].join('\n');
  var bubbleLayout = [
    '<div>',
    '  <header class="ot-bubble-header">',
    '    <p class="ot-message-sender"></p>',
    '    <time class="ot-message-timestamp"></time>',
    '  </header>',
    '</div>'
  ].join('\n');
  var chatBubble = [
    '<div class="<%= message_class%>" >',
    '<div class="wms-user-name-initial"><%= username[0] %></div>',
    '<div class="wms-item-timestamp"><%= username%>, <span data-livestamp="<%= time%>"></span></div>',
    '<div class="wms-item-text">',
    '<span><%= message%></span>',
    '</div>',
    '</div>'
  ].join('\n');
  /**
   * User interface for a basic chat client.
   *
   * The UI display bubbles representing the chat activity in the conversation
   * area. An input area displays the remaining characters and allows to send
   * messages by hitting enter or clicking on the send button. To add a normal
   * break-line you can press the `shift + enter` combination.
   *
   * The conversation area groups messages separated no more than 2 minutes
   * (although this can be configured) and allow the user to review past
   * history even if receiving new messages.
   *
   * The chat UI can be placed inside any element by providing a `container`
   * and it will fill the container box.
   *
   * @class ChatUI
   * @constructor
   * @param {Object} [options] Hash with customizing properties.
   * @param {String} [options.container='body'] CSS selector representing the
   * container for the chat.
   * @param {String} [options.senderId] Unique id for this client. It defaults
   * in a random number.
   * @param {String} [options.senderAlias='me'] Alias to be displayed for this
   * client.
   * @param {Number} [options.maxTextLength=1000] Maximum length of the message.
   * @param {Number} [options.groupDelay=120000] Time in milliseconds to be
   * passed for the UI to separate the messages in different bubbles.
   * @param {Number} [options.timeout=5000] Time in milliseconds before
   * informing about a malfunction while sending the message.
   */
  function ChatUI(options) {
    options = options || {};
    this.senderId = options.senderId || ('' + Math.random()).substr(2);
    this.senderAlias = options.senderAlias || 'me';
    this.maxTextLength = options.maxTextLength || 1000;
    this.groupDelay = options.groupDelay || 2 * 60 * 1000;
    // 2 min
    this.timeout = options.timeout || 5000;
    this._watchScrollAtTheBottom = this._watchScrollAtTheBottom.bind(this);
    this._messages = [];
    this._setupTemplates();
    this._setupUI(options.text_chat_widget_holder);
    this._imCharacterCount = "#character-count";
    // this._updateCharCounter();
    this._widget = options.widget;
  }
  ChatUI.prototype = {
    constructor: ChatUI,
    _setupTemplates: function () {
    },
    getBubbleHtml: function (message) {
      var bubble = [
        '<div class="' + message.message_class + '" >',
        '<div class="wms-user-name-initial"> ' + message.username[0] + '</div>',
        '<div class="wms-item-timestamp"> ' + message.username + ', <span data-livestamp=" ' + message.time + '" </span></div>',
        '<div class="wms-item-text">',
        '<span> ' + message.message + '</span>',
        '</div>',
        '</div>'
      ].join('\n');
      return bubble;
    },
    addMessageToBeDelivered: function () {
      var message = [
        '<div class="wms-messages-alert">',
        '<span>Your message will be delivered once your contact has arrived.</span>',
        '</div>'
      ].join('\n');
      $('#messagesHolder').append(message);
    },
    removeAlertMessage: function () {
      $('.wms-messages-alert').html('<span>Your messages have been delivered.</span>').delay(5000).fadeOut('slow');
    },
    _setupUI: function (parent) {
      parent = document.querySelector(parent) || document.body;
      var chatView = document.createElement('section');
      chatView.innerHTML = uiLayout;
      var sendButton = chatView.querySelector('#sendMessage');
      var composer = chatView.querySelector('#messageBox');
      var charCounter = chatView.querySelector('#wms-character-count > span');
      var newMessages = chatView.querySelector('#messagesHolder');
      this._composer = composer;
      this._sendButton = sendButton;
      this._charCounter = charCounter;
      this._bubbles = chatView.firstElementChild;
      this._newMessages = newMessages;
      this._bubbles.onscroll = this._watchScrollAtTheBottom;
      this._sendButton.onclick = this._sendMessage.bind(this);
      this._composer.onkeyup = this._updateCharCounter.bind(this);
      this._composer.onkeydown = this._controlComposerInput.bind(this);
      parent.appendChild(chatView);  //document.write('<link rel="stylesheet" type="text/css" href="../css/widget.css">');
    },
    _watchScrollAtTheBottom: function () {
      if (this._isAtBottom()) {
        this._hideNewMessageAlert();
      }
    },
    _sendMessage: function () {
      var _this = this;
      console.log('opentok_text_chat sendMessage');
      console.log(this._widget);
      this._widget._sendTxtMessage(this._composer.value);
    },
    _cleanComposer: function () {
      this._composer.value = '';
      $(this._imCharacterCount).text('0');
    },
    onIncomingMessage: function (event) {
    },
    _controlComposerInput: function (evt) {
      var isEnter = evt.which === 13 || evt.keyCode === 13;
      if (!evt.shiftKey && isEnter) {
        evt.preventDefault();
        this._sendMessage();
      }
    },
    _updateCharCounter: function () {
      $(this._imCharacterCount).text(this._composer.value.length);
    }
  };
  return ChatUI;
}();
opentok_text_chat = function (ChatUI) {
  window.OTSolution = window.OTSolution || {};
  window.OTSolution.TextChat = {
    // Chat: Chat,
    ChatUI: ChatUI
  };
}(ChatUI);
}());