package com.tokbox.android.accpack.textchat;

import java.util.Date;
import java.util.UUID;

import org.junit.Assert;
import org.junit.Test;

public class ChatMessageTest {

    private ChatMessage chatMessage;
    private ChatMessage.ChatMessageBuilder chatMessageBuilder;
    private String senderID;
    private UUID messageID;
    private String senderAlias;
    private String text;
    private long timestamp;
    private Date date = new Date();

    private String generateLongString(){
        int length = 100*1024*1024;
        StringBuilder outputBuilder = new StringBuilder(length);
        for (int i = 0; i < length; i++){
            outputBuilder.append(" ");
        }
        return outputBuilder.toString();
    }


    @Test
    public void ChatMessageBuilder_When_OK() throws Exception {

        senderID= "1234";
        messageID = UUID.randomUUID();
        chatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE)); //senderId
        chatMessage.setSenderAlias("Bob");
        chatMessage.setText("Good morning!");
        long timestamp = date.getTime();
        chatMessage.setTimestamp(timestamp);

        String errorMsg = "";

        errorMsg += chatMessage.getSenderId().equals(senderID) ? "" : "SenderID is not set properly. Expected: " + senderID + ", Actual: " + chatMessage.getSenderId() + " /n";
        errorMsg += chatMessage.getMessageId().equals(messageID) ? "" : "MessageID is not set properly. Expected: " + messageID + ", Actual: " + chatMessage.getMessageId() + " /n";
        errorMsg += chatMessage.getMessageStatus().equals(ChatMessage.MessageStatus.SENT_MESSAGE) ? "" : "MessageStatus is not set properly. Expected: " + ChatMessage.MessageStatus.RECEIVED_MESSAGE + ", Actual: " + chatMessage.getMessageStatus() + " /n";
        //Alias is set properly
        errorMsg += chatMessage.getSenderAlias().equals("Bob") ? "" : "SenderAlias is not set properly. Expected: 'Bob', Actual: " + chatMessage.getSenderAlias() + " /n";
        //Assert.assertTrue(chatMessage.getSenderAlias().equals("Bob"));
        //Message text is set properly
        errorMsg += chatMessage.getText().equals("Good morning!") ? "" : "Text is not set properly. Expected: 'Good morning!', Actual: " + chatMessage.getText() + " /n";
        //Assert.assertTrue(chatMessage.getText().equals("Good morning!"));
        //Timestamp is set properly
        errorMsg += (chatMessage.getTimestamp() == timestamp) ? "" : "TimeStamp is not set properly. Expected: NotNull, Actual: " + chatMessage.getTimestamp() + " /n";
        //Assert.assertTrue(chatMessage.getTimestamp() > 0);

        Assert.assertTrue(errorMsg,errorMsg.equals(""));
    }

    @Test
    public void ChatMessage_When_OK() throws Exception {

        senderID= "1234";
        messageID = UUID.randomUUID();
        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.RECEIVED_MESSAGE);

        chatMessageBuilder.senderAlias("Bob");
        chatMessageBuilder.text("Good morning!");
        long timestamp = date.getTime();
        chatMessageBuilder.timestamp(timestamp);

        chatMessage = chatMessageBuilder.build();

        String errorMsg = "";

        errorMsg += chatMessage.getSenderId().equals(senderID) ? "" : "SenderID is not set properly. Expected: " + senderID + ", Actual: " + chatMessage.getSenderId() + " /n";
        errorMsg += chatMessage.getMessageId().equals(messageID) ? "" : "MessageID is not set properly. Expected: " + messageID + ", Actual: " + chatMessage.getMessageId() + " /n";
        errorMsg += chatMessage.getMessageStatus().equals(ChatMessage.MessageStatus.RECEIVED_MESSAGE) ? "" : "MessageStatus is not set properly. Expected: " + ChatMessage.MessageStatus.RECEIVED_MESSAGE + ", Actual: " + chatMessage.getMessageStatus() + " /n";
        //Alias is set properly
        errorMsg += chatMessage.getSenderAlias().equals("Bob") ? "" : "SenderAlias is not set properly. Expected: 'Bob', Actual: " + chatMessage.getSenderAlias() + " /n";
        //Assert.assertTrue(chatMessage.getSenderAlias().equals("Bob"));
        //Message text is set properly
        errorMsg += chatMessage.getText().equals("Good morning!") ? "" : "Text is not set properly. Expected: 'Good morning!', Actual: " + chatMessage.getText() + " /n";
        //Assert.assertTrue(chatMessage.getText().equals("Good morning!"));
        //Timestamp is set properly
        errorMsg += (chatMessage.getTimestamp() == timestamp) ? "" : "TimeStamp is not set properly. Expected: NotNull, Actual: " + chatMessage.getTimestamp() + " /n";
        //Assert.assertTrue(chatMessage.getTimestamp() > 0);

        Assert.assertTrue(errorMsg,errorMsg.equals(""));

    }

    @Test
    public void ChatMessageBuilder_When_SenderIDIsNull() throws Exception {

        senderID= null;
        messageID = UUID.randomUUID();
        chatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE));

        Assert.assertNull("Expected: Null, Actual: NotNull", chatMessage);

    }

    @Test
    public void ChatMessage_When_SenderIDIsNull() throws Exception {

        senderID= null;
        messageID = UUID.randomUUID();
        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.RECEIVED_MESSAGE);

        chatMessage = chatMessageBuilder.build();

        Assert.assertNull("Expected: Null, Actual: NotNull", chatMessage);

    }

    @Test
    public void ChatMessageBuilder_When_SenderIDIsEmpty() throws Exception {

        senderID = "";
        messageID = UUID.randomUUID();
        chatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE));

        Assert.assertNull("Expected: Null, Actual: NotNull", chatMessage);

    }

    @Test
    public void ChatMessage_When_SenderIDIsEmpty() throws Exception {

        senderID = "";
        messageID = UUID.randomUUID();
        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.RECEIVED_MESSAGE);

        chatMessage = chatMessageBuilder.build();

        Assert.assertNull("Expected: Null, Actual: NotNull", chatMessage);

    }

    @Test
    public void ChatMessageBuilder_When_SenderIDIsLongString() throws Exception {

        senderID = generateLongString();
        messageID = UUID.randomUUID();
        chatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.RECEIVED_MESSAGE));

        Assert.assertEquals(chatMessage.getSenderId(), senderID);

    }

    @Test
    public void ChatMessage_When_SenderIDIsLongString() throws Exception {

        senderID = generateLongString();
        messageID = UUID.randomUUID();
        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE);

        chatMessage = chatMessageBuilder.build();

        Assert.assertEquals(chatMessage.getSenderId(), senderID);

    }

    @Test
    public void ChatMessageBuilder_When_MessageIDIsNull() throws Exception {

        senderID= "1234";
        messageID = null;
        chatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE));

        Assert.assertNull("Expected: Null, Actual: NotNull", chatMessage);

    }

    @Test
    public void ChatMessage_When_MessageIDIsNull() throws Exception {

        senderID= "1234";
        messageID = null;
        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.RECEIVED_MESSAGE);

        chatMessage = chatMessageBuilder.build();

        Assert.assertNull("Expected: Null, Actual: NotNull", chatMessage);

    }

    @Test
    public void ChatMessageBuilder_When_MessageIDIsEmpty() throws Exception {

        senderID= "1234";
        messageID = new UUID(0,0);
        chatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE));

        Assert.assertNull("Expected: Null, Actual: NotNull", chatMessage);

    }

    @Test
    public void ChatMessage_When_MessageIDIsEmpty() throws Exception {

        senderID= "1234";
        messageID = new UUID(0,0);
        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.RECEIVED_MESSAGE);

        chatMessage = chatMessageBuilder.build();

        Assert.assertNull("Expected: Null, Actual: NotNull", chatMessage);

    }

    @Test
    public void ChatMessageBuilder_When_MessageIDIsEmptyString() throws Exception {

        senderID= "1234";
        messageID = UUID.fromString("");
        chatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.RECEIVED_MESSAGE));

        Assert.assertNull("Expected: Null, Actual: NotNull", chatMessage);

    }

    @Test
    public void ChatMessage_When_MessageIDIsEmptyString() throws Exception {

        senderID= "1234";
        messageID = UUID.fromString("");
        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE);

        chatMessage = chatMessageBuilder.build();

        Assert.assertNull("Expected: Null, Actual: NotNull", chatMessage);

    }


    @Test
    public void ChatMessageBuilder_When_MessageStatusIsNull() throws Exception {

        senderID= "1234";
        messageID = UUID.randomUUID();
        chatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageID, null));

        Assert.assertNull("Expected: Null, Actual: NotNull", chatMessage);

    }

    @Test
    public void ChatMessage_When_MessageStatusIsNull() throws Exception {

        senderID= "1234";
        messageID = UUID.randomUUID();
        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, null);

        chatMessage = chatMessageBuilder.build();

        Assert.assertNull("Expected: Null, Actual: NotNull", chatMessage);

    }


    //TO REVIEW
//    @Test
//    public void get_Message_Status_Test_When_GT_2() throws Exception {
//
//        senderID = "1234";
//        messageID = new UUID(0,0);
//
//        chatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.values()[3])); //senderId
//
//        //Message status
//        //Exception??
//        Assert.assertNull(chatMessage.getMessageStatus());
//
//    }

    @Test
    public void getSenderAlias_When_SenderAliasIsNull() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE));

        chatMessage.setSenderAlias(null);

        Assert.assertNull(chatMessage.getSenderAlias());

    }

    @Test
    public void getSenderAlias_When_SenderAliasIsEmpty() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE));

        chatMessage.setSenderAlias("");

        Assert.assertTrue(chatMessage.getSenderAlias().equals(""));

    }

    @Test
    public void getSenderAlias_When_SenderAliasIsLongString() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE));

        String senderAlias = generateLongString();
        chatMessage.setSenderAlias(senderAlias);

        Assert.assertTrue(chatMessage.getSenderAlias().equals(senderAlias));

    }

    @Test
    public void getText_When_TextIsNull() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE));

        chatMessage.setText(null);

        Assert.assertNull(chatMessage.getText());

    }

    @Test
    public void getText_When_TextIsEmpty() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE));

        chatMessage.setText("");

        Assert.assertTrue(chatMessage.getText().equals(""));

    }

    @Test
    public void getText_When_TextIsLongString() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE));

        String text = generateLongString();
        chatMessage.setText(text);

        Assert.assertTrue(chatMessage.getText().equals(text));

    }

//    @Test
//    public void getTimestamp_When_Null() throws Exception {
//
//        senderID = "1234";
//        messageID = UUID.randomUUID();
//
//        chatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE));
//
//        //chatMessage.setTimestamp(null);
//
//        //Timestamp
//        //Assert.assertNull(chatMessage.getTimestamp());
//
//    }

    @Test
    public void getTimestamp_When_TimestampIsMinLong() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE));

        chatMessage.setTimestamp(Long.MIN_VALUE);

        Assert.assertTrue(chatMessage.getTimestamp() == Long.MIN_VALUE);

    }

    @Test
    public void getTimestamp_When_TimestampIsMaxLong() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE));

        chatMessage.setTimestamp(Long.MAX_VALUE);

        Assert.assertTrue(chatMessage.getTimestamp() == Long.MAX_VALUE);

    }

    @Test
    public void getTimestamp_When_TimestampIsZero() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE));

        chatMessage.setTimestamp(0);

        Assert.assertTrue(chatMessage.getTimestamp() == timestamp);

    }


}