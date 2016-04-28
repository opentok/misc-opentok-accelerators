package com.tokbox.android.accpack.textchat;

import android.content.Context;

import com.tokbox.android.accpack.AccPackSession;

import junit.framework.Assert;


import org.junit.Test;

public  class TextChatFragmentTest {

    private TextChatFragment textChatFragment;
    private AccPackSession accPackSession;

    private String generateLongString(){
        int length = 100*1024*1024;
        StringBuilder outputBuilder = new StringBuilder(length);
        for (int i = 0; i < length; i++){
            outputBuilder.append(" ");
        }
        return outputBuilder.toString();
    }

    @Test
    public void TextChatFragment_When_SessionIsNull() throws Exception {
        textChatFragment = TextChatFragment.newInstance(null, "100");

        Assert.assertNull(textChatFragment);

    }

//    @Test
//    public void TextChatFragment_When_ApiKeyIsNull() throws Exception {
//        accPackSession = new AccPackSession(null, "","");
//        textChatFragment = TextChatFragment.newInstance(null, null);
//
//        Assert.assertNull(textChatFragment);
//    }
//
//    @Test
//    public void TextChatFragment_When_ApiKeyIsEmpty() throws Exception {
//
//        accPackSession = new AccPackSession(null, "123","123");
//        textChatFragment = TextChatFragment.newInstance(accPackSession, "");
//
//        Assert.assertNull(textChatFragment);
//    }
//
//    @Test
//    public void TextChatFragment_When_ApiKeyIsLongString() throws Exception {
//        accPackSession = new AccPackSession(null, "","");
//        String apiKey = generateLongString();
//        textChatFragment = TextChatFragment.newInstance(accPackSession, apiKey);
//
//        Assert.assertNull(textChatFragment);
//    }
//
//    //setListener
//    //setMaxTextLength
//    @Test
//    public void setMaxLengthTest_When_MaxLengthIsLTMAX() throws Exception {
//
//        accPackSession = new AccPackSession(null, "","");
//        textChatFragment = new TextChatFragment();
//
//        //Assert not greater than MAX
//        textChatFragment.setMaxTextLength(8195);
//
//
//    }
//
//    @Test//(expected=Error)
//    public void setMaxLength_When_MaxLengthIsGTMAX() throws Exception {
//
//        accPackSession = new AccPackSession(null, "","");
//        textChatFragment = new TextChatFragment();
//
//        //Assert greater than MAX
//        textChatFragment.setMaxTextLength(8197);
//
//    }
//
//    @Test
//    public void setMaxLength_When_MaxLengthIsZero() throws Exception {
//
//        accPackSession = new AccPackSession(null, "","");
//        textChatFragment = new TextChatFragment();
//
//        //Assert zero
//        textChatFragment.setMaxTextLength(0);
//
//    }
//
//    @Test//(expected=Error)
//    public void setMaxLength_When_MaxLengthIsLTZero() throws Exception {
//
//        accPackSession = new AccPackSession(null, "","");
//        textChatFragment = new TextChatFragment();
//        //Assert minus zero
//        textChatFragment.setMaxTextLength(-1);
//
//    }
//
//    //setSenderAlias
//    @Test//(expected=Error)
//    public void setSenderAlias_When_SenderAliasIsNull() throws Exception {
//
//        accPackSession = new AccPackSession(null, "","");
//        textChatFragment = new TextChatFragment();
//
//        //Assert null
//        textChatFragment.setSenderAlias(null);
//
//        //Assert empty
//        //Assert huge string
//
//    }
//
//    @Test
//    public void setSenderAlias_When_SenderAliasIsEmpty() throws Exception {
//
//        accPackSession = new AccPackSession(null, "","");
//        textChatFragment = new TextChatFragment();
//
//        //Assert empty
//        textChatFragment.setSenderAlias("");
//
//    }
//
//    @Test
//    public void setSenderAlias_When_SenderAliasIsLongString() throws Exception {
//
//        accPackSession = new AccPackSession(null, "","");
//        textChatFragment = new TextChatFragment();
//
//        String senderAlias = generateLongString();
//        //Assert huge string
//        textChatFragment.setSenderAlias(senderAlias);
//
//    }
//
//    //getActionBar
//    //setActionBar
//    @Test
//    public void setActionBar_When_OK() throws Exception {
//
//        accPackSession = new AccPackSession(null, "","");
//        textChatFragment = new TextChatFragment();
//
//        //ViewGroup viewGroup = new ViewGroup();
//
//        //textChatFragment.setActionBar(viewGroup);
//
//        //Assert new ViewGroup
//        //Assert.assertTrue(textChatFragment.getActionBar() == viewGroup);
//
//    }
//
//    @Test
//    public void setActionBar_When_ActionBarIsNull() throws Exception {
//
//        accPackSession = new AccPackSession(null, "","");
//        textChatFragment = new TextChatFragment();
//
//        //Assert null
//        textChatFragment.setActionBar(null);
//        textChatFragment.onMinimize();
//
//
//
//    }
//
//    //getSendMessageView
//    //setSendMessageView
//    @Test
//    public void setSendMessageView_When_OK() throws Exception {
//
//        accPackSession = new AccPackSession(null, "","");
//        textChatFragment = new TextChatFragment();
//
//        //ViewGroup viewGroup = new ViewGroup() {
//        //    @Override
//        //    protected void onLayout(boolean changed, int l, int t, int r, int b) {
//        //
//        //    }
//        //};
//
//        //textChatFragment.setSendMessageView(viewGroup);
//
//        //Assert new ViewGroup
//        //Assert.assertTrue(textChatFragment.getSendMessageView() == viewGroup);
//
//    }
//
//    @Test
//    public void setSendMessageView_When_SendMessageViewIsNull() throws Exception {
//
//        accPackSession = new AccPackSession(null, "", "");
//        textChatFragment = new TextChatFragment();
//
//        //Assert null
//        textChatFragment.setSendMessageView(null);
//        textChatFragment.onMinimize();
//
//    }
//    //
//    //OT events
//    //onSignalReceived
//    //onError


}