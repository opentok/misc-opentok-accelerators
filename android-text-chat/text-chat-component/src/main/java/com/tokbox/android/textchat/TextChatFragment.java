package com.tokbox.android.textchat;

import android.support.v4.app.Fragment;
import android.content.Context;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
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


public class TextChatFragment extends Fragment {

    private final static String LOG_TAG = Fragment.class.getName();

    private RecyclerView mRecyclerView;
    private LinearLayout mContentView;
    private ViewGroup rootView;
    private ViewGroup mActionBarView;
    private ViewGroup mSendMessageView;
    private EditText mMsgEditText;
    private TextView mTitleBar;
    private ImageButton mMinimizeBtn;
    private ImageButton mCloseBtn;

    private int maxTextLength = 1000; // By default the maximum length is 1000.
    private TextChatListener listener;
    private String senderId;
    private String senderAlias;
    private HashMap<String, String> senders = new HashMap<>();

    private List<ChatMessage> messagesList = new ArrayList<ChatMessage>();

    private MessagesAdapter mMessageAdapter;

    private boolean isMinimized = false;

    /*
    * Constructor
    */
    public TextChatFragment() {
        //Init the sender information for the output messages
        this.senderId = UUID.randomUUID().toString();
        this.senderAlias = "me";
        Log.i(LOG_TAG, "senderstuff  " + this.senderId + this.senderAlias);
    }


    /**
     * Monitors state changes in the TextChatFragment.
     *
     */
    public interface TextChatListener {

        /**
         * Invoked when a new message is ready to be sent.
         *
         * @param msg The ChatMessage to be sent.
         */
        boolean onMessageReadyToSend(ChatMessage msg);

        /**
         * Invoked when there is an error on the text-chat.
         *
         * @param error The error message
         */
        void onTextChatError(String error);

        /**
         * Invoked when the close button is clicked
         *
         */
        void onClose();

        /**
         * Invoked when the minimize button is clicked
         *
         */
        void onMinimize();

        /**
         * Invoked when the maximize button is clicked
         *
         */
        void onMaximize();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        rootView = (ViewGroup) inflater.inflate(R.layout.main_layout, container, false);

        mMsgEditText = (EditText) rootView.findViewById(R.id.edit_msg);
        mTitleBar = (TextView) rootView.findViewById(R.id.titlebar);
        mMinimizeBtn = (ImageButton) rootView.findViewById(R.id.minimize);
        mCloseBtn = (ImageButton) rootView.findViewById(R.id.close);
        mActionBarView = (ViewGroup) rootView.findViewById(R.id.action_bar);
        mSendMessageView = (ViewGroup) rootView.findViewById(R.id.send_msg);

        mContentView = (LinearLayout) rootView.findViewById(R.id.content_layout);
        mRecyclerView = (RecyclerView) rootView.findViewById(R.id.recycler_view);
        mRecyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));

        mMsgEditText.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_DONE) {
                    InputMethodManager imm = (InputMethodManager) v.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
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
                if (isMinimized) {
                    minimize(false);
                    onMaximize();
                } else {
                    minimize(true);
                    onMinimize();
                }
            }
        });

        mCloseBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.i(LOG_TAG, "Close onClick");
                onClose();
            }
        });

        updateTitle(defaultTitle());

        return rootView;
    }


    /**
     * Sets a {@link TextChatListener} object to monitor state changes for this
     * TextChatFragment object.
     *
     * @param listener The {@link TextChatListener} instance.
     */
    public void setListener(TextChatListener listener) {
        this.listener = listener;
    }

    /**
     * Set the maximum length of a text chat message (in characters).
     *
     * @param length The maximum length
     */
    public void setMaxTextLength(int length) {
        maxTextLength = length;
    }

    /**
     * Set the sender alias and the sender ID of the outgoing messages.
     *
     * @param senderId The id for the sender
     * @param senderAlias The alias for the sender
     */
    public void setSenderInfo(String senderId, String senderAlias) {
        if (senderAlias == null || senderId == null) {
            throw new IllegalArgumentException("The sender alias and the sender id cannot be null");
        }
        this.senderAlias = senderAlias;
        this.senderId = senderId;
        senders.put(senderId, senderAlias);
    }

    /**
     * Add a message to the message list.
     */
    public void addMessage(ChatMessage msg) {
        Log.i(LOG_TAG, "New message " + msg.getText() + " is ready to be added.");

        if (msg != null) {

            if (!senders.containsKey(msg.getSenderId())) {
                if (msg.getSenderAlias() != null && !msg.getSenderAlias().isEmpty()) {
                    senders.put(msg.getSenderId(), msg.getSenderAlias());
                    updateTitle(defaultTitle());
                }
            }

            //generate message timestamp
            Date date = new Date();
            if (msg.getTimestamp() == 0) {
                msg.setTimestamp(date.getTime());
            }

            if (!checkMessageGroup(msg)) {
                messagesList.add(msg);
                mMessageAdapter.notifyDataSetChanged();
            } else {
                //concat text for the messages group
                String msgText = messagesList.get(messagesList.size() - 1).getText() + '\n' + msg.getText();
                msg.setText(msgText);
                messagesList.set(messagesList.size() - 1, msg);
                mMessageAdapter.notifyDataSetChanged();
            }
            mRecyclerView.smoothScrollToPosition(mMessageAdapter.getItemCount() - 1); //update based on adapter

        }
    }

    /**
     * Get action bar to be customized
     */
    public ViewGroup getActionBar() {
        return mActionBarView;
    }

    /**
     * Set a customized action bar.
     * @param actionBar a customized action bar
     */
    public void setActionBar(ViewGroup actionBar) {
        mActionBarView = actionBar;
    }

    /**
     * Get the send message area view to be customized.
     */
    public ViewGroup getSendMessageView() {
        return mSendMessageView;
    }

    /**
     * Set a customized send message area view
     * @param sendMessageView a customized send message area view
     */
    public void setSendMessageView(ViewGroup sendMessageView) {
        mSendMessageView = sendMessageView;
    }

    /**
     * Restart to the origin status: removing all the messages
     */
    public void restartFragment(){
        minimize(false);
        messagesList = new ArrayList<ChatMessage>();
        mMessageAdapter = new MessagesAdapter(messagesList);
        mRecyclerView.setAdapter(mMessageAdapter);
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

    protected void onClose() {
        //rootView.setVisibility(View.GONE);
        if (this.listener != null) {
            listener.onClose();
        }
        minimize(false);
    }

    protected void onMinimize(){
        if (this.listener != null) {
            listener.onMinimize();
        }
    }

    protected void onMaximize(){
        if (this.listener != null) {
            listener.onMaximize();
        }
    }

    // Called when the user clicks the send button.
    private void sendMessage() {
        //checkMessage
        mMsgEditText.setEnabled(false);
        String msgStr = mMsgEditText.getText().toString();
        if (!msgStr.isEmpty()) {

            if (msgStr.length() > maxTextLength) {
                onError("Your chat message is over size limit");
            } else {
                UUID messageId = UUID.randomUUID();
                ChatMessage myMsg = new ChatMessage.ChatMessageBuilder(senderId, messageId, ChatMessage.MessageStatus.SENT_MESSAGE)
                        .senderAlias(senderAlias)
                        .text(msgStr)
                        .build();
                if (myMsg == null) {
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
        } else {
            mMsgEditText.setEnabled(true);
        }
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
        if (size >= 1) {
            ChatMessage lastAdded = messagesList.get(size - 1);

            //check source
            if (lastAdded.getSenderId().equals(msg.getSenderId())) {
                //check time
                return checkTimeMsg(msg.getTimestamp(), lastAdded.getTimestamp());
            }
        }
        return false;
    }

    private String defaultTitle() {
        String title = "";
        Iterator it = senders.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry e = (Map.Entry) it.next();
            if (!title.isEmpty()) {
                title = title + ", ";
            }
            title = title + e.getValue();
        }
        return title;
    }

    private void updateTitle(String title) {
        mTitleBar.setText(title);
    }

    private void minimize(boolean minimized) {
        if (!minimized) {
            //maximize text-chat
            mMinimizeBtn.setBackgroundResource(R.drawable.minimize);
            mContentView.setVisibility(View.VISIBLE);
            mMsgEditText.setVisibility(View.VISIBLE);

            RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams) mActionBarView.getLayoutParams();
            params.addRule(RelativeLayout.ALIGN_PARENT_TOP);
            params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM, 0);
            mActionBarView.setLayoutParams(params);

            isMinimized = false;
        } else {
            //minimize text-chat
            mMinimizeBtn.setBackgroundResource(R.drawable.maximize);
            mContentView.setVisibility(View.GONE);
            mMsgEditText.setVisibility(View.GONE);

            RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams) mActionBarView.getLayoutParams();
            params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
            params.addRule(RelativeLayout.ALIGN_PARENT_TOP, 0);
            mActionBarView.setLayoutParams(params);
            isMinimized = true;
        }
    }
}
