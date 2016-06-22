describe("TextChatSpec", function () {

	var TextChatAccPack = require('../../src/acc-pack-text-chat');

	it("TextChat Initializer not to be null", function() {
    	var textchat = new TextChatAccPack({});

    	//demonstrates use of custom matcher
    	expect(textchat).not.toBeNull();
  	});
});