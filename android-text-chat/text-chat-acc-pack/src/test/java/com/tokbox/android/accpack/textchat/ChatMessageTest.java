package com.tokbox.android.accpack.textchat;

import java.util.Date;
import java.util.Random;
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

    private String generateLongString(int length){

        StringBuilder tmp = new StringBuilder();
        for (char ch = '0'; ch <= '9'; ++ch)
            tmp.append(ch);
        for (char ch = 'a'; ch <= 'z'; ++ch)
            tmp.append(ch);
        char[] symbols = tmp.toString().toCharArray();
        char[] buf = new char[length];
        Random random = new Random();

        for (int idx = 0; idx < buf.length; ++idx)
            buf[idx] = symbols[random.nextInt(symbols.length)];
        return new String(buf);
    }


    @Test
    public void ChatMessageBuilder_When_OK() throws Exception {

        senderID= "1234";
        messageID = UUID.randomUUID();
        chatMessage = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE).build(); //senderId
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
    public void ChatMessage_When_SenderIDIsNull() throws Exception {

        senderID= null;
        messageID = UUID.randomUUID();
        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.RECEIVED_MESSAGE);

        chatMessage = chatMessageBuilder.build();

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
    public void ChatMessage_When_SenderIDIsBlankSpace() throws Exception {

        senderID = "     ";
        messageID = UUID.randomUUID();
        chatMessage = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.RECEIVED_MESSAGE).build();

        Assert.assertNull("Expected: Null, Actual: NotNull", chatMessage);

    }

    @Test
    public void ChatMessage_When_SenderIDIsMAXString() throws Exception {

        senderID = generateLongString(60);
        messageID = UUID.randomUUID();
        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE);

        chatMessage = chatMessageBuilder.build();

        Assert.assertTrue(chatMessage.getSenderId().equals(senderID));

    }

    @Test
    public void ChatMessage_When_SenderIDIsLongString() throws Exception {

        senderID = generateLongString(1001);
        messageID = UUID.randomUUID();
        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE);

        chatMessage = chatMessageBuilder.build();

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

    /*
    @Test
    public void ChatMessage_When_MessageIDIsEmpty() throws Exception {

        senderID= "1234";
        messageID = new UUID(0,0);
        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.RECEIVED_MESSAGE);

        chatMessage = chatMessageBuilder.build();

        Assert.assertNull("Expected: Null, Actual: NotNull", chatMessage);

    }

    @Test
    public void ChatMessage_When_MessageIDIsEmptyString() throws Exception {

        senderID= "1234";
        messageID = UUID.fromString("");
        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE);

        chatMessage = chatMessageBuilder.build();

        Assert.assertNull("Expected: Null, Actual: NotNull", chatMessage);

    }*/

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

    @Test(expected=Exception.class)
    public void getSenderAlias_When_SenderAliasIsNull() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessage = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE).build();

        chatMessage.setSenderAlias(null);

    }

    @Test(expected=Exception.class)
    public void getSenderAliasCMB_When_SenderAliasIsNull() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE);
        chatMessageBuilder.senderAlias(null);
        chatMessage = chatMessageBuilder.build();


    }

    @Test(expected=Exception.class)
    public void getSenderAlias_When_SenderAliasIsEmpty() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessage = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE).build();

        chatMessage.setSenderAlias("");

    }

    @Test(expected=Exception.class)
    public void getSenderAliasCMB_When_SenderAliasIsEmpty() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE);
        chatMessageBuilder.senderAlias("");
        chatMessage = chatMessageBuilder.build();

    }

    @Test
    public void getSenderAlias_When_SenderAliasIsMAXString() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessage = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE).build();

        String senderAlias =  generateLongString(50);
        chatMessage.setSenderAlias(senderAlias);

        Assert.assertTrue(chatMessage.getSenderAlias().equals(senderAlias));

    }

    @Test
    public void getSenderAliasCMB_When_SenderAliasIsMAXString() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE);
        String senderAlias =  generateLongString(50);
        chatMessageBuilder.senderAlias(senderAlias);
        chatMessage = chatMessageBuilder.build();

        Assert.assertTrue(chatMessage.getSenderAlias().equals(senderAlias));

    }


    @Test(expected=Exception.class)
    public void getSenderAlias_When_SenderAliasIsLongString() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessage = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE).build();

        chatMessage.setSenderAlias(generateLongString(51));

    }

    @Test(expected=Exception.class)
    public void getSenderAliasCMB_When_SenderAliasIsLongString() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE);
        chatMessageBuilder.senderAlias(generateLongString(51));
        chatMessage = chatMessageBuilder.build();

    }

    @Test(expected=Exception.class)
    public void getSenderAlias_When_SenderAliasIsBlankSpace() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessage = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE).build();

        chatMessage.setSenderAlias("     ");

    }

    @Test(expected=Exception.class)
    public void getSenderAliasCMB_When_SenderAliasIsBlankSpace() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE);
        chatMessageBuilder.senderAlias("     ");
        chatMessage = chatMessageBuilder.build();

    }

    @Test(expected=Exception.class)
    public void getText_When_TextIsNull() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessage = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE).build();

        chatMessage.setText(null);

    }

    @Test(expected=Exception.class)
    public void getTextCMB_When_TextIsNull() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE);
        chatMessageBuilder.text(null);
        chatMessage = chatMessageBuilder.build();

    }

    @Test(expected=Exception.class)
    public void getText_When_TextIsEmpty() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessage = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE).build();

        chatMessage.setText("");

    }

    @Test(expected=Exception.class)
    public void getTextCMB_When_TextIsEmpty() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE);
        chatMessageBuilder.text("");
        chatMessage = chatMessageBuilder.build();

    }

    @Test
    public void getText_When_TextIsMAXString() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessage = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE).build();

        String text = generateLongString(8196);
        chatMessage.setText(text);

        Assert.assertTrue(chatMessage.getText().equals(text));

    }

    @Test
    public void getTextCMB_When_TextIsMAXString() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE);
        String text = generateLongString(8196);
        chatMessageBuilder.text(text);
        chatMessage = chatMessageBuilder.build();

        Assert.assertTrue(chatMessage.getText().equals(text));
    }


    @Test(expected=Exception.class)
    public void getText_When_TextIsLongString() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessage = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE).build();

        String text = generateLongString(8197);
        chatMessage.setText(text);

    }

    @Test(expected=Exception.class)
    public void getTextCMB_When_TextIsLongString() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE);
        chatMessageBuilder.text(generateLongString(8197));
        chatMessage = chatMessageBuilder.build();

    }

    @Test(expected=Exception.class)
    public void getText_When_TextIsBlankSpace() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessage = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE).build();

        chatMessage.setText("     ");

    }

    @Test(expected=Exception.class)
    public void getTextCMB_When_TextIsBlankSpace() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE);
        chatMessageBuilder.text("     ");
        chatMessage = chatMessageBuilder.build();

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

    @Test(expected=Exception.class)
    public void getTimestamp_When_TimestampIsMinLong() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessage = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE).build();

        chatMessage.setTimestamp(Long.MIN_VALUE);

    }

    @Test(expected=Exception.class)
    public void getTimestampCMB_When_TimestampIsMinLong() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE);
        chatMessageBuilder.timestamp(Long.MIN_VALUE);
        chatMessage = chatMessageBuilder.build();

    }

    /*
    @Test(expected=Exception.class)
    public void getTimestamp_When_TimestampIsMaxLong() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessage = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE).build();

        chatMessage.setTimestamp(Long.MAX_VALUE);

    }

    @Test(expected=Exception.class)
    public void getTimestampCMB_When_TimestampIsMaxLong() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE);
        chatMessageBuilder.timestamp(Long.MAX_VALUE);
        chatMessage = chatMessageBuilder.build();

    }*/

    @Test(expected=Exception.class)
    public void getTimestamp_When_TimestampIsZero() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessage = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE).build();

        chatMessage.setTimestamp(0);

    }

    @Test(expected=Exception.class)
    public void getTimestampCMB_When_TimestampIsZero() throws Exception {

        senderID = "1234";
        messageID = UUID.randomUUID();

        chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageID, ChatMessage.MessageStatus.SENT_MESSAGE);
        chatMessageBuilder.timestamp(0);
        chatMessage = chatMessageBuilder.build();

    }


}