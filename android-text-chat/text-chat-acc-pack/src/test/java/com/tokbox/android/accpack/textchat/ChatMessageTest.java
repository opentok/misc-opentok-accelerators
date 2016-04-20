package com.tokbox.android.accpack.textchat;

import java.util.Date;
import java.util.UUID;

import org.junit.Assert;
import org.junit.Test;

public class ChatMessageTest {


    @Test
    public void chat_Message_new_instance() throws Exception {

        String senderID= "1234";
        UUID messageId = UUID.randomUUID();
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)); //senderId
        mChatMessage.setSenderAlias("Bob");
        mChatMessage.setText("Good morning!");
        mChatMessage.setTimestamp(date.getTime());

        //AssertTrue(actual, expected)
        //Alias is set properly
        Assert.assertTrue(mChatMessage.getSenderAlias().equals("Bob"));
        //Message text is set properly
        Assert.assertTrue(mChatMessage.getText().equals("Good morning!"));
        //Timestamp is not null
        Assert.assertTrue(mChatMessage.getTimestamp() > 0);
    }

    @Test
    public void chat_Message_new_instance_with_build() throws Exception {

        String senderID= "1234";
        UUID messageId = UUID.randomUUID();
        Date date = new Date();
        ChatMessage.ChatMessageBuilder chatMessageBuilder = new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.RECEIVED_MESSAGE);

        chatMessageBuilder.senderAlias("Bob");
        chatMessageBuilder.text("Good morning!");
        chatMessageBuilder.timestamp(date.getTime());

        ChatMessage chatMessage = chatMessageBuilder.build();

        //AssertTrue(actual, expected)
        //Alias is set properly
        Assert.assertTrue(chatMessage.getSenderAlias().equals("Bob"));
        //Message text is set properly
        Assert.assertTrue(chatMessage.getText().equals("Good morning!"));
        //Timestamp is not null
        Assert.assertTrue(chatMessage.getTimestamp() > 0);

    }

    //Assert get Sender ID
    @Test//(expected=NullPointerException.class)
    public void get_Sender_ID_Test_When_Null() throws Exception {

        String senderID= null;
        UUID messageId = UUID.randomUUID();
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)); //senderId

        //Sender ID
        Assert.assertNull(mChatMessage.getSenderId());

    }

    @Test
    public void get_Sender_ID_Test_When_Empty() throws Exception {

        String senderID= "";
        UUID messageId = UUID.randomUUID();
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)); //senderId

        //Sender ID
        Assert.assertEquals(mChatMessage.getSenderId(), "");

    }

    @Test
    public void get_Sender_ID_Test_When_Huge_String() throws Exception {
        int length = Integer.MAX_VALUE;
        StringBuffer outputBuffer = new StringBuffer(length);
        for (int i = 0; i < length; i++){
            outputBuffer.append(" ");
        }

        String senderID= outputBuffer.toString();
        UUID messageId = UUID.randomUUID();
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)); //senderId

        //Sender ID
        //Assert

    }

    @Test
    public void get_Sender_ID_Test_When_OK() throws Exception {

        String senderID= "1234";
        UUID messageId = UUID.randomUUID();
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)); //senderId

        //Sender ID
        Assert.assertTrue(mChatMessage.getSenderId().equals("1234"));

    }

    //Assert get Message ID
    @Test
    public void get_Message_ID_Test_When_Null() throws Exception {

        String senderID= "1234";
        UUID messageId = null;
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)); //senderId

        //Message ID
        //Assert

    }

    @Test
    public void get_Message_ID_Test_When_Empty() throws Exception {

        String senderID= "1234";
        UUID messageId = new UUID(0,0);
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)); //senderId

        //Message ID
        //Assert

    }

    @Test
    public void get_Message_ID_Test_When_Empty_String() throws Exception {

        String senderID= "1234";
        UUID messageId = UUID.fromString("");
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)); //senderId

        //Message ID
        //Assert

    }

    @Test
    public void get_Message_ID_Test_When_OK() throws Exception {

        String senderID= "1234";
        UUID messageId = UUID.randomUUID();
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)); //senderId

        //Message ID
        Assert.assertTrue(mChatMessage.getMessageId() == messageId);

    }

    //Assert get Message Status
    @Test
    public void get_Message_Status_Test_When_Null() throws Exception {

        String senderID= "1234";
        UUID messageId = null;
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, null)); //senderId

        //Message status
        //Assert

    }

    @Test
    public void get_Message_Status_Test_When_GT_2() throws Exception {

        String senderID= "1234";
        UUID messageId = new UUID(0,0);
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.values()[3])); //senderId

        //Message status
        //Assert

    }

    @Test
    public void get_Message_Status_Test_When_SENT_MESSAGE() throws Exception {

        String senderID= "1234";
        UUID messageId = UUID.fromString("");
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)); //senderId

        //Message status
        Assert.assertTrue(mChatMessage.getMessageStatus() == ChatMessage.MessageStatus.SENT_MESSAGE);

    }

    @Test
    public void get_Message_Status_Test_When_MESSAGE_RECEIVED() throws Exception {

        String senderID= "1234";
        UUID messageId = UUID.randomUUID();
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.RECEIVED_MESSAGE)); //senderId

        //Message status
        Assert.assertTrue(mChatMessage.getMessageStatus() == ChatMessage.MessageStatus.RECEIVED_MESSAGE);

    }

    //Assert get and set Sender Alias
    @Test
    public void get_Sender_Alias_Test_When_Null() throws Exception {

        String senderID= "1234";
        UUID messageId = UUID.randomUUID();
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)); //senderId

        mChatMessage.setSenderAlias(null);

        //Sender Alias
        //Assert

    }

    @Test
    public void get_Sender_Alias_Test_When_Empty() throws Exception {

        String senderID= "1234";
        UUID messageId = UUID.randomUUID();
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)); //senderId

        mChatMessage.setSenderAlias("");

        //Sender Alias
        //Assert

    }

    @Test
    public void get_Sender_Alias_Test_When_Huge_String() throws Exception {
        int length = Integer.MAX_VALUE;
        StringBuffer outputBuffer = new StringBuffer(length);
        for (int i = 0; i < length; i++){
            outputBuffer.append(" ");
        }

        String senderID= "1234";
        UUID messageId = UUID.randomUUID();
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)); //senderId

        mChatMessage.setSenderAlias(outputBuffer.toString());

        //Sender Alias
        //Assert

    }

    @Test
    public void get_Sender_Alias_Test_When_OK() throws Exception {

        String senderID= "1234";
        UUID messageId = UUID.randomUUID();
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)); //senderId

        mChatMessage.setSenderAlias("Bob");

        //Sender Alias
        Assert.assertTrue(mChatMessage.getSenderAlias().equals("Bob"));

    }

    //Assert get and set Text
    @Test
    public void get_Text_Test_When_Null() throws Exception {

        String senderID= "1234";
        UUID messageId = UUID.randomUUID();
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)); //senderId

        mChatMessage.setText(null);

        //Text
        //Assert

    }

    @Test
    public void get_Text_Test_When_Empty() throws Exception {

        String senderID= "1234";
        UUID messageId = UUID.randomUUID();
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)); //senderId

        mChatMessage.setText("");

        //Text
        //Assert

    }

    @Test
    public void get_Text_Test_When_Huge_String() throws Exception {
        int length = Integer.MAX_VALUE;
        StringBuffer outputBuffer = new StringBuffer(length);
        for (int i = 0; i < length; i++){
            outputBuffer.append(" ");
        }

        String senderID= "1234";
        UUID messageId = UUID.randomUUID();
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)); //senderId

        mChatMessage.setText(outputBuffer.toString());

        //Text
        //Assert

    }

    @Test
    public void get_Text_Test_When_OK() throws Exception {

        String senderID= "1234";
        UUID messageId = UUID.randomUUID();
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)); //senderId

        mChatMessage.setText("Good morning!");

        //Text
        Assert.assertTrue(mChatMessage.getText().equals("Good morning!"));

    }

    //Assert get and set Timestamp
    @Test
    public void get_Timestamp_Test_When_Null() throws Exception {

        String senderID= "1234";
        UUID messageId = UUID.randomUUID();
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)); //senderId

        //mChatMessage.setTimestamp(null);

        //Timestamp
        //Assert

    }

    @Test
    public void get_Timestamp_Test_When_Not_Valid() throws Exception {

        String senderID= "1234";
        UUID messageId = UUID.randomUUID();
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)); //senderId

        mChatMessage.setTimestamp(Long.MIN_VALUE);

        //Timestamp
        //Assert

    }

    @Test
    public void get_Timestamp_Test_When_Huge() throws Exception {

        String senderID= "1234";
        UUID messageId = UUID.randomUUID();
        Date date = new Date();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)); //senderId

        mChatMessage.setTimestamp(Long.MAX_VALUE);

        //Timestamp
        //Assert

    }

    @Test
    public void get_Timestamp_Test_When_OK() throws Exception {

        String senderID= "1234";
        UUID messageId = UUID.randomUUID();
        Date date = new Date();
        long timestamp = date.getTime();
        ChatMessage mChatMessage = new ChatMessage(new ChatMessage.ChatMessageBuilder(senderID, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)); //senderId

        mChatMessage.setTimestamp(timestamp);

        //Timestamp
        Assert.assertTrue(mChatMessage.getTimestamp() == timestamp);

    }





}