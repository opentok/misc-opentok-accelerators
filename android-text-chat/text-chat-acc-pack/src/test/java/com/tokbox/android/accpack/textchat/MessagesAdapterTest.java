package com.tokbox.android.accpack.textchat;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.junit.Test;
import org.junit.Assert;

public class MessagesAdapterTest {

    @Test
    public void get_item_count_Test_When_Null() throws Exception {

        MessagesAdapter messageAdapterNull = new MessagesAdapter(null);
        //EXCEPTION
        Assert.assertNull(messageAdapterNull.getItemCount());

    }

    @Test
    public void get_item_count_Test_When_Zero() throws Exception {

        List<ChatMessage> mList = new ArrayList<ChatMessage>();
        MessagesAdapter messageAdapterEmpty = new MessagesAdapter(mList);

        //Item count should be zero
        Assert.assertTrue(messageAdapterEmpty.getItemCount() == 0);

    }

    @Test
    public void get_item_count_Test_When_GT_Zero() throws Exception {

        List<ChatMessage> mList = new ArrayList<ChatMessage>();
        mList.add(new ChatMessage(new ChatMessage.ChatMessageBuilder("",UUID.randomUUID(), ChatMessage.MessageStatus.RECEIVED_MESSAGE)));
        MessagesAdapter messageAdapter = new MessagesAdapter(mList);

        //Item count should be greater than zero
        Assert.assertTrue(messageAdapter.getItemCount() == 1);

    }

    @Test
    public void get_Item_View_Type_When_Null() throws Exception {


        List<ChatMessage> mList = new ArrayList<ChatMessage>();
        MessagesAdapter messageAdapterEmpty = new MessagesAdapter(mList);
        //EXCEPTION
        Assert.assertNull(messageAdapterEmpty.getItemViewType(1));

    }

    @Test
    public void get_Item_View_Type_When_Empty_List() throws Exception {

        List<ChatMessage> mList = new ArrayList<ChatMessage>();
        MessagesAdapter messageAdapter = new MessagesAdapter(mList);

        //EXCEPTION
        Assert.assertNull(messageAdapter.getItemViewType(0));

    }

    @Test
    public void get_Item_View_Type_When_Index_GT_Size() throws Exception {

        List<ChatMessage> mList = new ArrayList<ChatMessage>();
        mList.add(new ChatMessage(new ChatMessage.ChatMessageBuilder("",UUID.randomUUID(), ChatMessage.MessageStatus.RECEIVED_MESSAGE)));
        MessagesAdapter messageAdapter = new MessagesAdapter(mList);

        //EXCEPTION
        Assert.assertNull(messageAdapter.getItemViewType(1));

    }

    @Test
    public void get_Item_View_Type_When_Index_LT_Zero() throws Exception {

        List<ChatMessage> mList = new ArrayList<ChatMessage>();
        mList.add(new ChatMessage(new ChatMessage.ChatMessageBuilder("",UUID.randomUUID(), ChatMessage.MessageStatus.RECEIVED_MESSAGE)));
        MessagesAdapter messageAdapter = new MessagesAdapter(mList);

        //EXCEPTION
        Assert.assertNull(messageAdapter.getItemViewType(-1));

    }

    @Test
    public void get_Item_View_Type_When_OK_First() throws Exception {

        List<ChatMessage> mList = new ArrayList<ChatMessage>();
        mList.add(new ChatMessage(new ChatMessage.ChatMessageBuilder("",UUID.randomUUID(), ChatMessage.MessageStatus.RECEIVED_MESSAGE)));
        MessagesAdapter messageAdapter = new MessagesAdapter(mList);

        //EXCEPTION
        Assert.assertNotNull(messageAdapter.getItemViewType(0));

    }

    @Test
    public void get_Item_View_Type_When_OK_Last() throws Exception {

        List<ChatMessage> mList = new ArrayList<ChatMessage>();
        mList.add(new ChatMessage(new ChatMessage.ChatMessageBuilder("1",UUID.randomUUID(), ChatMessage.MessageStatus.RECEIVED_MESSAGE)));
        mList.add(new ChatMessage(new ChatMessage.ChatMessageBuilder("2",UUID.randomUUID(), ChatMessage.MessageStatus.RECEIVED_MESSAGE)));
        mList.add(new ChatMessage(new ChatMessage.ChatMessageBuilder("3",UUID.randomUUID(), ChatMessage.MessageStatus.RECEIVED_MESSAGE)));
        MessagesAdapter messageAdapter = new MessagesAdapter(mList);

        //EXCEPTION
        Assert.assertNotNull(messageAdapter.getItemViewType(2));

    }

}