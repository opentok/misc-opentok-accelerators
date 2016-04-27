package com.tokbox.android.accpack.textchat;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.junit.Test;
import org.junit.Assert;

public class MessagesAdapterTest {

    private List<ChatMessage> messagesList;
    private MessagesAdapter messagesAdapter;


    @Test
    public void getItemCount_When_MessagesListIsNull() throws Exception {

        messagesAdapter = new MessagesAdapter(null);

        //EXCEPTION?
        Assert.assertNull(messagesAdapter.getItemCount());

    }

    @Test
    public void getItemCount_When_MessagesListIsEmpty() throws Exception {

        messagesList = new ArrayList<ChatMessage>();
        messagesAdapter = new MessagesAdapter(messagesList);

        //Item count should be zero
        Assert.assertTrue(messagesAdapter.getItemCount() == 0);

    }

    @Test
    public void getItemCount_When_MessagesListIsNotEmpty() throws Exception {


        messagesList = new ArrayList<ChatMessage>();
        messagesList.add(new ChatMessage(new ChatMessage.ChatMessageBuilder("1",UUID.randomUUID(), ChatMessage.MessageStatus.SENT_MESSAGE)));

        messagesAdapter = new MessagesAdapter(messagesList);

        //Item count should be greater than zero
        Assert.assertTrue(messagesAdapter.getItemCount() == 1);

    }

    @Test
    public void getItemCount_When_MessagesListSizeIsBig() throws Exception {

        messagesList = new ArrayList<ChatMessage>();
        int length = 100*1024*1024;
        for(int i = 0; i < length; i++){
            messagesList.add(new ChatMessage(new ChatMessage.ChatMessageBuilder("1",UUID.randomUUID(), ChatMessage.MessageStatus.RECEIVED_MESSAGE)));
        }

        messagesAdapter = new MessagesAdapter(messagesList);

        //Item count should be greater than zero
        Assert.assertTrue(messagesAdapter.getItemCount() == length);

    }


    @Test
    public void getItemViewType_When_MessagesListIsNull() throws Exception {

        messagesAdapter = new MessagesAdapter(null);
        //EXCEPTION
        Assert.assertNull(messagesAdapter.getItemViewType(1));

    }

    @Test
    public void getItemViewType_When_MessagesListIsEmpty() throws Exception {

        messagesList = new ArrayList<ChatMessage>();
        messagesAdapter = new MessagesAdapter(messagesList);

        //EXCEPTION
        Assert.assertNull(messagesAdapter.getItemViewType(0));

    }

    @Test
    public void getItemViewType_When_IndexIsGTSize() throws Exception {

        messagesList = new ArrayList<ChatMessage>();
        messagesList.add(new ChatMessage(new ChatMessage.ChatMessageBuilder("1",UUID.randomUUID(), ChatMessage.MessageStatus.SENT_MESSAGE)));
        messagesAdapter = new MessagesAdapter(messagesList);

        //EXCEPTION
        Assert.assertNull(messagesAdapter.getItemViewType(1));

    }

    @Test
    public void getItemViewType_When_IndexIsLTZero() throws Exception {

        messagesList = new ArrayList<ChatMessage>();
        messagesList.add(new ChatMessage(new ChatMessage.ChatMessageBuilder("1",UUID.randomUUID(), ChatMessage.MessageStatus.RECEIVED_MESSAGE)));
        messagesAdapter = new MessagesAdapter(messagesList);

        //EXCEPTION
        Assert.assertNull(messagesAdapter.getItemViewType(-1));

    }

    @Test
    public void getItemViewType_When_IndexIsZero() throws Exception {

        messagesList = new ArrayList<ChatMessage>();
        messagesList.add(new ChatMessage(new ChatMessage.ChatMessageBuilder("1",UUID.randomUUID(), ChatMessage.MessageStatus.RECEIVED_MESSAGE)));
        messagesAdapter = new MessagesAdapter(messagesList);

        //EXCEPTION
        Assert.assertNotNull(messagesAdapter.getItemViewType(0));

    }

    @Test
    public void getItemViewType_When_IndexIsLast() throws Exception {

        messagesList = new ArrayList<ChatMessage>();
        messagesList.add(new ChatMessage(new ChatMessage.ChatMessageBuilder("1",UUID.randomUUID(), ChatMessage.MessageStatus.RECEIVED_MESSAGE)));
        messagesList.add(new ChatMessage(new ChatMessage.ChatMessageBuilder("2",UUID.randomUUID(), ChatMessage.MessageStatus.SENT_MESSAGE)));
        messagesList.add(new ChatMessage(new ChatMessage.ChatMessageBuilder("3",UUID.randomUUID(), ChatMessage.MessageStatus.RECEIVED_MESSAGE)));
        messagesAdapter = new MessagesAdapter(messagesList);

        //
        Assert.assertNotNull(messagesAdapter.getItemViewType(2));

    }

}