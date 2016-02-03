package com.opentok.android.textchat;

import android.app.Fragment;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Handler;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.TimeUnit;


public class TextChatFragment extends Fragment{

    private final static String LOG_TAG = "text-chat-fragment";

    private RecyclerView mRecyclerView;
    private View mContentView;
    private View rootView;
    private RelativeLayout mActionBarLayout;
    private EditText mMsgEditText;
    private TextView mTitleBar;
    private ImageButton mMinimizeBtn;
    private ImageButton mCloseBtn;
    private TextView mAlert;

    private int maxTextLength = 1000; // By default the maximum length is 1000.
    private TextChatListener listener;
    private String senderId;
    private String senderAlias;
    private HashMap<String, String> senders = new HashMap<>();

    private List<ChatMessage> messagesList = new ArrayList<ChatMessage>();;
    private MessagesAdapter mMessageAdapter;

    private boolean isMinimized = false;

    public TextChatFragment() {
        //Init the sender information for the output messages
        this.senderId = UUID.randomUUID().toString();
        this.senderAlias = "me";
        Log.i(LOG_TAG, "senderstuff  " + this.senderId + this.senderAlias);
    };

    public interface TextChatListener {
        public boolean onMessageReadyToSend(ChatMessage msg);
        public void onTextChatError(String error);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        rootView = inflater.inflate(R.layout.main_layout, container, false);

        mMsgEditText = (EditText) rootView.findViewById(R.id.edit_msg);
        mTitleBar = (TextView) rootView.findViewById(R.id.titlebar);
        mMinimizeBtn = (ImageButton) rootView.findViewById(R.id.minimize);
        mCloseBtn = (ImageButton) rootView.findViewById(R.id.close);
        mActionBarLayout = (RelativeLayout) rootView.findViewById(R.id.action_bar);

        mContentView = rootView.findViewById(R.id.content_layout);
        mRecyclerView = (RecyclerView) rootView.findViewById(R.id.recycler_view);
        mRecyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));

        mAlert = (TextView) mContentView.findViewById(R.id.alert);

        mMsgEditText.setOnEditorActionListener(new TextView.OnEditorActionListener(){
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_DONE) {
                    InputMethodManager imm = (InputMethodManager)v.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
                    imm.hideSoftInputFromWindow(v.getWindowToken(), 0);
                    sendMessage();
                    return true;
                }
                return false;
            }
        });

        mMessageAdapter = new MessagesAdapter(messagesList);
        mRecyclerView.setAdapter(mMessageAdapter);

        mMinimizeBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.i(LOG_TAG, "Minimize onClick");
                if(isMinimized){
                    minimize(false);
                }
                else {
                    minimize(true);
                }
            }
        });

        mCloseBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.i(LOG_TAG, "Close onClick");
                close();
            }
        });

        updateTitle(defaultTitle());

        return rootView;
    }

    public void setListener(TextChatListener listener) {
        this.listener = listener;
    }

    public void setMaxTextLength(int length) {
        maxTextLength = length;
    }

    public void setSenderInfo(String senderId, String senderAlias) {
        if ( senderAlias == null || senderId == null ) {
            throw new IllegalArgumentException("The sender alias and the sender id cannot be null");
        }
        this.senderAlias = senderAlias;
        this.senderId = senderId;
        senders.put(senderId, senderAlias);
    }

    // Called when the user clicks the send button.
    private void sendMessage() {
        //checkMessage
        mMsgEditText.setEnabled(false);
        String msgStr = mMsgEditText.getText().toString();
        if (!msgStr.isEmpty()) {

            if ( msgStr.length() > maxTextLength ) {
                onError("Your chat message is over size limit");
            }
            else {
                UUID messageId = UUID.randomUUID();
                ChatMessage myMsg = new ChatMessage.ChatMessageBuilder(senderId, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)
                        .senderAlias(senderAlias)
                        .text(msgStr)
                        .build();
                if (myMsg == null){
                    onError("Error building ChatMessage");
                }
                boolean msgError = onMessageReadyToSend(myMsg);

                if (msgError) {
                    onError("Error sending a message");
                } else {
                    mMsgEditText.setEnabled(true);
                    mMsgEditText.setFocusable(true);
                    mMsgEditText.setText("");
                    addMessage(myMsg);
                }
            }
        }
        else{
            mMsgEditText.setEnabled(true);
        }
    }

    /**
     * Add a message to the TextChatListener received message list.
     */
    public void addMessage(ChatMessage msg) {
        Log.i(LOG_TAG, "New message " + msg.getText() + " is ready to be added.");

        if (msg != null) {

            if (!senders.containsKey(msg.getSenderId())) {
                senders.put(msg.getSenderId(), msg.getSenderAlias());
                updateTitle(defaultTitle());
            }

            //generate message timestamp
            Date date = new Date();
            if (msg.getTimestamp() == 0) {
                msg.setTimestamp(date.getTime());
            }

            if (!checkMessageGroup(msg)) {
                messagesList.add(msg);
                mMessageAdapter.notifyDataSetChanged();
            }
            else {
                //concat text for the messages group
                String msgText = messagesList.get(messagesList.size()-1).getText() + '\n' + msg.getText();
                msg.setText(msgText);
                messagesList.set(messagesList.size()-1, msg);
                mMessageAdapter.notifyDataSetChanged();
            }
            mRecyclerView.smoothScrollToPosition(mMessageAdapter.getItemCount() - 1); //update based on adapter

        }
    }

    protected void onError(String error) {
        if (this.listener != null) {
            Log.d(LOG_TAG, "onTextChatError");
            this.listener.onTextChatError(error);
        }
    }

    protected boolean onMessageReadyToSend(ChatMessage msg) {
        if (this.listener != null) {
            Log.d(LOG_TAG, "onMessageReadyToSend");
            return this.listener.onMessageReadyToSend(msg);
        }
        return false;
    }

    //Check the time between the current new message and the last added message
    private boolean checkTimeMsg(long lastMsgTime, long newMsgTime) {
        if (lastMsgTime - newMsgTime <= TimeUnit.MINUTES.toMillis(2)) {
            return true;
        }
        return false;
    }

    private boolean checkMessageGroup(ChatMessage msg) {
        int size = messagesList.size();
        if (size >= 1 ) {
            ChatMessage lastAdded = messagesList.get(size-1);

            //check source
            if (lastAdded.getSenderId().equals(msg.getSenderId())) {
                //check time
                return checkTimeMsg(msg.getTimestamp(), lastAdded.getTimestamp());
            }
        }
        return false;
    }
    private String defaultTitle(){
        String title = "";
        Iterator it = senders.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry e = (Map.Entry)it.next();
            if ( !title.isEmpty() ) {
                title = title + ", ";
            }
            title = title + e.getValue();
        }
        return title;
    }
    public void updateTitle(String title){

        mTitleBar.setText(title);
    }

    public void close() {
        rootView.setVisibility(View.GONE);
    }

     public void minimize (boolean minimized){
        if (!minimized){
            //maximize text-chat
            mMinimizeBtn.setBackgroundResource(R.drawable.minimize);
            mContentView.setVisibility(View.VISIBLE);
            mMsgEditText.setVisibility(View.VISIBLE);

            RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams)mActionBarLayout.getLayoutParams();
            params.addRule(RelativeLayout.ALIGN_PARENT_TOP);
            params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM, 0);
            mActionBarLayout.setLayoutParams(params);

            isMinimized = false;
        }
        else {
            //minimize text-chat
            mMinimizeBtn.setBackgroundResource(R.drawable.maximize);
            mContentView.setVisibility(View.GONE);
            mMsgEditText.setVisibility(View.GONE);

            RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams)mActionBarLayout.getLayoutParams();
            params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
            params.addRule(RelativeLayout.ALIGN_PARENT_TOP, 0);
            mActionBarLayout.setLayoutParams(params);

            isMinimized = true;
        }
    }

    /**
     * Set text-chat alert text
     */
    public void setTextAlert(String text) {
        mAlert.setText(text);
    }

    /**
     * Show text-chat alert.
     */
    public void showAlert(boolean show){
        if (show){
            mAlert.setVisibility(View.VISIBLE);
        }
        else {
            mAlert.setVisibility(View.GONE);
        }
    }
}
