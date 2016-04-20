package com.tokbox.android.accpack.textchat;

import android.view.ViewGroup;

import com.tokbox.android.accpack.AccPackSession;

import junit.framework.Assert;

import java.lang.Override;

import org.junit.Test;
import 	android.test.mock.MockContext;

public  class TextChatFragmentTest {

    //CONSTRUCTOR

    //setListener
    //setMaxTextLength
    @Test
    public void set_Max_Length_Test_When_OK() throws Exception {

        MockContext context = new MockContext();
        AccPackSession session = new AccPackSession(context, "", "");

        TextChatFragment textChatFragment = new TextChatFragment(session);

        //Assert not greater than MAX
        textChatFragment.setMaxTextLength(8195);

    }

    @Test//(expected=Error)
    public void set_Max_Length_Test_When_GT_MaxLength() throws Exception {

        MockContext context = new MockContext();
        AccPackSession session = new AccPackSession(context, "", "");

        TextChatFragment textChatFragment = new TextChatFragment(session);

        //Assert greater than MAX
        textChatFragment.setMaxTextLength(8197);

    }

    @Test
    public void set_Max_Length_Test_When_Zero() throws Exception {

        MockContext context = new MockContext();
        AccPackSession session = new AccPackSession(context, "", "");

        TextChatFragment textChatFragment = new TextChatFragment(session);

        //Assert zero
        textChatFragment.setMaxTextLength(0);

    }

    @Test//(expected=Error)
    public void set_Max_Length_Test_When_LT_Zero() throws Exception {

        MockContext context = new MockContext();
        AccPackSession session = new AccPackSession(context, "", "");

        TextChatFragment textChatFragment = new TextChatFragment(session);

        //Assert minus zero
        textChatFragment.setMaxTextLength(-1);

    }

    @Test
    public void set_Max_Length_Test_When_Null() throws Exception {

        MockContext context = new MockContext();
        AccPackSession session = new AccPackSession(context, "", "");

        TextChatFragment textChatFragment = new TextChatFragment(session);

        //Assert null
        //textChatFragment.setMaxTextLength(null);

    }

    //setSenderAlias
    @Test//(expected=Error)
    public void set_Sender_Alias_Test_When_Null() throws Exception {

        MockContext context = new MockContext();
        AccPackSession session = new AccPackSession(context, "", "");

        TextChatFragment textChatFragment = new TextChatFragment(session);

        //Assert null
        textChatFragment.setSenderAlias(null);

        //Assert empty
        //Assert huge string

    }

    @Test
    public void set_Sender_Alias_Test_When_Empty() throws Exception {

        MockContext context = new MockContext();
        AccPackSession session = new AccPackSession(context, "", "");

        TextChatFragment textChatFragment = new TextChatFragment(session);

        //Assert empty
        textChatFragment.setSenderAlias("");

    }

    @Test
    public void set_Sender_Alias_Test_When_Huge_String() throws Exception {

        MockContext context = new MockContext();
        AccPackSession session = new AccPackSession(context, "", "");

        TextChatFragment textChatFragment = new TextChatFragment(session);

        int length = Integer.MAX_VALUE;
        StringBuffer outputBuffer = new StringBuffer(length);
        for (int i = 0; i < length; i++){
            outputBuffer.append(" ");
        }

        //Assert huge string
        textChatFragment.setSenderAlias(outputBuffer.toString());

    }

    //getActionBar
    //setActionBar
    @Test
    public void set_Action_Bar_Test_When_OK() throws Exception {

        MockContext context = new MockContext();
        AccPackSession session = new AccPackSession(context, "", "");

        TextChatFragment textChatFragment = new TextChatFragment(session);

        //ViewGroup viewGroup = new ViewGroup();

        //textChatFragment.setActionBar(viewGroup);

        //Assert new ViewGroup
        //Assert.assertTrue(textChatFragment.getActionBar() == viewGroup);

    }

    @Test
    public void set_Action_Bar_Test_When_Null() throws Exception {

        MockContext context = new MockContext();
        AccPackSession session = new AccPackSession(context, "", "");

        TextChatFragment textChatFragment = new TextChatFragment(session);

        //Assert null
        textChatFragment.setActionBar(null);
        textChatFragment.onMinimize();



    }

    //getSendMessageView
    //setSendMessageView
    @Test
    public void set_Send_Message_View_Test_When_OK() throws Exception {

        MockContext context = new MockContext();
        AccPackSession session = new AccPackSession(context, "", "");

        TextChatFragment textChatFragment = new TextChatFragment(session);

        //ViewGroup viewGroup = new ViewGroup() {
        //    @Override
        //    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        //
        //    }
        //};

        //textChatFragment.setSendMessageView(viewGroup);

        //Assert new ViewGroup
        //Assert.assertTrue(textChatFragment.getSendMessageView() == viewGroup);

    }

    @Test
    public void set_Send_Message_View_Test_When_Null() throws Exception {

        MockContext context = new MockContext();
        AccPackSession session = new AccPackSession(context, "", "");

        TextChatFragment textChatFragment = new TextChatFragment(session);

        //Assert null
        textChatFragment.setSendMessageView(null);
        textChatFragment.onMinimize();

    }
    //
    //OT events
    //onSignalReceived
    //onError


}