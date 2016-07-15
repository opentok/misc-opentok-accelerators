package com.tokbox.android.accpack.textchat;

import android.content.SharedPreferences;
import android.graphics.Color;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.content.Context;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.DisplayMetrics;
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
import android.widget.TextView;

import com.opentok.android.Connection;
import com.opentok.android.OpentokError;
import com.opentok.android.Session;
import com.opentok.android.Stream;
import com.tokbox.android.accpack.AccPackSession;
import com.tokbox.android.accpack.textchat.config.OpenTokConfig;
import com.tokbox.android.logging.OTKAnalytics;
import com.tokbox.android.logging.OTKAnalyticsData;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.TimeUnit;


public class TextChatFragment extends Fragment implements AccPackSession.SignalListener, AccPackSession.SessionListener {

    private final static String LOG_TAG = Fragment.class.getSimpleName();

    private final static int MAX_OPENTOK_LENGTH = 8196;
    private final static int MAX_DEFAULT_LENGTH = 1000;
    private final static String DEFAULT_SENDER_ALIAS = "me";

    private RecyclerView mRecyclerView;
    private LinearLayout mContentView;
    private ViewGroup rootView;
    private ViewGroup mActionBarView;
    private ViewGroup mSendMessageView;
    private EditText mMsgEditText;
    private TextView mTitleBar;
    private ImageButton mCloseBtn;
    private TextView mMsgCharsView;

    private int maxTextLength = MAX_DEFAULT_LENGTH;
    private TextChatListener mListener;
    private String senderId;
    private String senderAlias;
    private HashMap<String, String> senders = new HashMap<>();

    private List<ChatMessage> messagesList = new ArrayList<ChatMessage>();
    private MessagesAdapter mMessageAdapter;

    private boolean isRestarted = false;
    private boolean customActionBar = false;
    private boolean customSenderArea = false;

    private AccPackSession mSession;
    private String mApiKey;

    private OTKAnalyticsData mAnalyticsData;
    private OTKAnalytics mAnalytics;

    /**
     * Monitors state changes in the TextChatFragment.
     *
     */
    public interface TextChatListener {

        /**
         * Invoked when a new text chat message has been sent.
         *
         * @param message The text chat message that was sent.
         */
        void onNewSentMessage(ChatMessage message);

        /**
         * Invoked when a new text chat message has been received.
         *
         * @param message The text chat message that was received.
         */
        void onNewReceivedMessage(ChatMessage message);

        /**
         * Invoked when a text chat error occurs.
         *
         * @param error The error message.
         */
        void onTextChatError(String error);

        /**
         * Invoked when the close button is clicked.
         *
         */
        void onClosed();

        /**
         * Invoked when the text chat is restarted.
         *
         */
        void onRestarted();
    }

    /*
    * Default constructor.
    */
    public TextChatFragment(){

    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        addLogEvent(OpenTokConfig.LOG_ACTION_INITIALIZE, OpenTokConfig.LOG_VARIATION_ATTEMPT);
        super.onCreate(savedInstanceState);

        // Retain this fragment across configuration changes.
        setRetainInstance(true);
        addLogEvent(OpenTokConfig.LOG_ACTION_INITIALIZE, OpenTokConfig.LOG_VARIATION_SUCCESS);
    }

    /*
    * Constructor.
    * @param session The OpenTok session instance.
    * @param apiKey  The API Key.
    */
    public static TextChatFragment newInstance(AccPackSession session, String apiKey) {
        if ( session == null ){
            throw new IllegalArgumentException("Session argument cannot be null");
        }

        TextChatFragment fragment = new TextChatFragment();

        fragment.senderId = UUID.randomUUID().toString(); //by default
        fragment.senderAlias = DEFAULT_SENDER_ALIAS; // by default

        fragment.mSession = session;
        fragment.mSession.setSignalListener(fragment);
        fragment.mSession.setSessionListener(fragment);
        fragment.mApiKey = apiKey;

        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        // Inflate the layout for this fragment
        rootView = (ViewGroup) inflater.inflate(R.layout.main_layout, container, false);

        mMsgEditText = (EditText) rootView.findViewById(R.id.edit_msg);
        mTitleBar = (TextView) rootView.findViewById(R.id.titlebar);
        mCloseBtn = (ImageButton) rootView.findViewById(R.id.close);
        mActionBarView = (ViewGroup) rootView.findViewById(R.id.action_bar);
        mSendMessageView = (ViewGroup) rootView.findViewById(R.id.send_msg);
        mMsgCharsView = (TextView) rootView.findViewById(R.id.characteres_msg);
        mMsgCharsView.setText(String.valueOf(maxTextLength));
        mMsgEditText.addTextChangedListener(mTextEditorWatcher);

        mContentView = (LinearLayout) rootView.findViewById(R.id.content_layout);

        LinearLayoutManager llm = new LinearLayoutManager(getContext());
        mRecyclerView = (RecyclerView) rootView.findViewById(R.id.recycler_view);
        mRecyclerView.setLayoutManager(llm);

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

        DisplayMetrics displaymetrics = new DisplayMetrics();
        getActivity().getWindowManager().getDefaultDisplay().getMetrics(displaymetrics);

        mMsgEditText.setMaxWidth(displaymetrics.widthPixels - (int)getResources().getDimension(R.dimen.edit_text_width));

        try {
            mMessageAdapter = new MessagesAdapter(messagesList);
            mRecyclerView.setAdapter(mMessageAdapter);
        } catch (Exception e) {
            e.printStackTrace();
        }

        mCloseBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.i(LOG_TAG, "Close onClick");
                addLogEvent(OpenTokConfig.LOG_ACTION_CLOSE, OpenTokConfig.LOG_VARIATION_ATTEMPT);

                try  {
                    InputMethodManager inputMgr = (InputMethodManager)getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
                    inputMgr.hideSoftInputFromWindow(mMsgEditText.getWindowToken(), 0);
                } catch (Exception e) {
                    throw e;
                }

                onClose();
            }
        });

        updateTitle(defaultTitle());

        return rootView;
    }

    /**
     * Close the text chat view.
     *
     */
    public void close(){
        addLogEvent(OpenTokConfig.LOG_ACTION_CLOSE, OpenTokConfig.LOG_VARIATION_ATTEMPT);
        onClose();
    }

    /**
     * Sets a {@link TextChatListener} object to monitor state changes for this
     * TextChatFragment object.
     *
     * @param listener The {@link TextChatListener} instance.
     */
    public void setListener(TextChatListener listener) {
        this.mListener = listener;
    }

    /**
     * Set the maximum length of a text chat message (in characters).
     *
     * @param length The maximum length of a text chat message (in characters).
     */
    public void setMaxTextLength(int length) {
        addLogEvent(OpenTokConfig.LOG_ACTION_SET_MAX_LENGTH, OpenTokConfig.LOG_VARIATION_ATTEMPT);
        if (maxTextLength > MAX_OPENTOK_LENGTH ){
            onError("Your maximum length is over size limit on the OpenTok platform (maximum length 8196)");
            addLogEvent(OpenTokConfig.LOG_ACTION_SET_MAX_LENGTH, OpenTokConfig.LOG_VARIATION_ERROR);
        }
        else {
            maxTextLength = length;
            mMsgCharsView.setText(String.valueOf(maxTextLength));
            addLogEvent(OpenTokConfig.LOG_ACTION_SET_MAX_LENGTH, OpenTokConfig.LOG_VARIATION_SUCCESS);
        }
    }

    /**
     * Set the sender alias for outgoing messages.
     *
     * @param senderAlias The alias for the sender.
     */
    public void setSenderAlias(String senderAlias) {

        if ( senderAlias == null || senderAlias.isEmpty() ) {
            onError("The alias cannot be null or empty");
        }
        this.senderAlias = senderAlias;
        senders.put(senderId, senderAlias);
        updateTitle(defaultTitle());
    }

    /**
     * Get the action bar to be customized.
     * @return The action bar.
     */
    public ViewGroup getActionBar() { return mActionBarView; }

    /**
     * Set the customized action bar.
     * @param actionBar The customized action bar.
     */
    public void setActionBar(ViewGroup actionBar) {
        mActionBarView = actionBar;
        customActionBar = true;
    }

    /**
     * Get the send message area view to be customized.
     * @return The send message view.
     */
    public ViewGroup getSendMessageView() {
        return mSendMessageView;
    }

    /**
     * Set the customized send message area view.
     * @param sendMessageView The customized send message area view.
     */
    public void setSendMessageView(ViewGroup sendMessageView) {
        mSendMessageView = sendMessageView;
        customSenderArea = true;
    }

    /**
     * Restart the session, removing all messages and maximizing the view.
     */
    public void restart(){
        isRestarted = true;
        messagesList = new ArrayList<ChatMessage>();
        mMessageAdapter = new MessagesAdapter(messagesList);
        mRecyclerView.setAdapter(mMessageAdapter);
    }

    //Private methods
    //Add a message to the message list.
    private void addMessage(final ChatMessage msg) throws Exception {
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
                String msgText = messagesList.get(messagesList.size() - 1).getText() + "\r\n" + msg.getText();
                msg.setText(msgText);
                messagesList.set(messagesList.size() - 1, msg);
                mMessageAdapter.notifyDataSetChanged();
            }

            mRecyclerView.smoothScrollToPosition(mMessageAdapter.getItemCount() - 1); //update based on adapter
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
                JSONObject messageObj = new JSONObject();
                JSONObject sender = new JSONObject();

                try {
                    sender.put("id", senderId);
                    sender.put("alias", senderAlias);
                    messageObj.put("sender", sender);
                    messageObj.put("text", msgStr);
                    messageObj.put("sentOn", System.currentTimeMillis());

                } catch (JSONException e) {
                    e.printStackTrace();
                }
                addLogEvent(OpenTokConfig.LOG_ACTION_SEND_MESSAGE, OpenTokConfig.LOG_VARIATION_ATTEMPT);
                mSession.sendSignal("text-chat", messageObj.toString());
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

    //Check messages group
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

    //Set title bar
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

    //Update the title bar
    private void updateTitle(String title) {
        mTitleBar.setText(title);
    }

    //add log events
    private void addLogEvent(String action, String variation){
        if ( mAnalytics!= null ) {
            mAnalytics.logEvent(action, variation);
        }
    }

    // Count down the characters left.
    private TextWatcher mTextEditorWatcher = new TextWatcher() {

        public void beforeTextChanged(CharSequence s, int start, int count, int after) {
        }

        public void onTextChanged(CharSequence s, int start, int before, int count) {
            int chars_left = maxTextLength - s.length();

            mMsgCharsView.setText(String.valueOf((maxTextLength - s.length())));
            if (chars_left < 4) {
                mMsgCharsView.setTextColor(Color.RED);

                if (chars_left < 0) {
                    String maxStr = mMsgEditText.getText().toString().substring(0, mMsgEditText.getText().length() - 1);
                    mMsgEditText.setText(maxStr);
                    mMsgEditText.setSelection(mMsgEditText.getText().length());
                }
            }
            else {
                mMsgCharsView.setTextColor(getResources().getColor(R.color.info));
            }

        }

        @Override
        public void afterTextChanged(Editable s) {
        }
    };

    //TEXTCHAT LISTENER events
    protected void onError(String error) {
        if (this.mListener != null) {
            Log.d(LOG_TAG, "onTextChatError");
            this.mListener.onTextChatError(error);
        }
    }

    protected void onClose() {
        //rootView.setVisibility(View.GONE);
        if (this.mListener != null) {
            mListener.onClosed();
        }
        isRestarted = true;

        addLogEvent(OpenTokConfig.LOG_ACTION_CLOSE, OpenTokConfig.LOG_VARIATION_SUCCESS);
    }

    protected void onNewSentMessage(ChatMessage message){
        if (this.mListener != null) {
            mListener.onNewSentMessage(message);
        }
        addLogEvent(OpenTokConfig.LOG_ACTION_SEND_MESSAGE, OpenTokConfig.LOG_VARIATION_SUCCESS);
    }

    protected void onNewReceivedMessage(ChatMessage message){
        if (this.mListener != null) {
            mListener.onNewReceivedMessage(message);
        }
        addLogEvent(OpenTokConfig.LOG_ACTION_RECEIVE_MESSAGE, OpenTokConfig.LOG_VARIATION_SUCCESS);
    }

    protected void onRestart(){
        if (this.mListener != null ) {
            mListener.onRestarted();
        }
    }

    //OPENTOK EVENTS
    @Override
    public void onSignalReceived(Session session, String type, String data, Connection connection) {
        ChatMessage msg = null;
        String senderId = null;
        String senderAlias = null;
        String text = null;
        Long date = null;

        if (type.equals("text-chat")){
            JSONObject json = null;
            try {
                json = new JSONObject(data);
                text = json.getString("text");
                date = json.getLong("sentOn");
                JSONObject sender = json.getJSONObject("sender");
                senderId = sender.getString("id");
                senderAlias = sender.getString("alias");
            } catch (JSONException e) {
                e.printStackTrace();
            }

            if (text == null || text.isEmpty()){
                onError("Message format is wrong. Text is empty or null");
                if(connection.getConnectionId().equals(mSession.getConnection().getConnectionId()) ) {
                    addLogEvent(OpenTokConfig.LOG_ACTION_SEND_MESSAGE, OpenTokConfig.LOG_VARIATION_ERROR);
                }
                else {
                    addLogEvent(OpenTokConfig.LOG_ACTION_RECEIVE_MESSAGE, OpenTokConfig.LOG_VARIATION_ERROR);
                }
            }
            else {
                if (connection.getConnectionId().equals(mSession.getConnection().getConnectionId())){
                    try {
                        msg = new ChatMessage.ChatMessageBuilder(senderId, UUID.randomUUID(), ChatMessage.MessageStatus.SENT_MESSAGE)
                                .senderAlias(senderAlias)
                                .text(text)
                                .build();
                        msg.setTimestamp(Long.valueOf(date).longValue());
                        mMsgEditText.setEnabled(true);
                        mMsgEditText.setFocusable(true);
                        mMsgEditText.setText("");
                        mMsgCharsView.setTextColor(getResources().getColor(R.color.info));
                        addMessage(msg);
                        onNewSentMessage(msg);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                }
                else {
                    Log.i(LOG_TAG, "A new message has been received "+data);
                    addLogEvent(OpenTokConfig.LOG_ACTION_RECEIVE_MESSAGE, OpenTokConfig.LOG_VARIATION_ATTEMPT);
                    try {
                        msg = new ChatMessage.ChatMessageBuilder(senderId, UUID.randomUUID(), ChatMessage.MessageStatus.RECEIVED_MESSAGE)
                                    .senderAlias(senderAlias)
                                    .text(text)
                                    .build();
                        msg.setTimestamp(Long.valueOf(date).longValue());
                        addMessage(msg);
                        onNewReceivedMessage(msg);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                }
            }
        }
    }

    @Override
    public void onConnected(Session session) {
        String source = getContext().getPackageName();

        SharedPreferences prefs = getContext().getSharedPreferences("opentok", Context.MODE_PRIVATE);
        String guidVSol = prefs.getString("guidVSol", null);
        if (null == guidVSol) {
            guidVSol = UUID.randomUUID().toString();
            prefs.edit().putString("guidVSol", guidVSol).commit();
        }

        mAnalyticsData = new OTKAnalyticsData.Builder(OpenTokConfig.LOG_CLIENT_VERSION, source, OpenTokConfig.LOG_COMPONENTID, guidVSol).build();
        mAnalytics = new OTKAnalytics(mAnalyticsData);

        mAnalyticsData.setSessionId(session.getSessionId());
        mAnalyticsData.setConnectionId(session.getConnection().getConnectionId());
        mAnalyticsData.setPartnerId(mApiKey);

        mAnalytics. setData(mAnalyticsData);

        //TO IMPROVE: add pending log events --> recall methods
        if ( this.maxTextLength != MAX_DEFAULT_LENGTH ){
            setMaxTextLength(this.maxTextLength);
        }
        if ( this.senderAlias != DEFAULT_SENDER_ALIAS ){
            setSenderAlias(this.senderAlias);
        }
        if ( this.customActionBar ){
            setActionBar(this.mActionBarView);
        }
        if ( this.customSenderArea ) {
            setSendMessageView(this.mSendMessageView);
        }
    }

    @Override
    public void onDisconnected(Session session) {
    }

    @Override
    public void onStreamReceived(Session session, Stream stream) {
    }

    @Override
    public void onStreamDropped(Session session, Stream stream) {
    }

    @Override
    public void onError(Session session, OpentokError opentokError) {
        onError(opentokError.getMessage());

        if (opentokError.getErrorCode().equals(OpentokError.ErrorCode.SessionInvalidSignalType) || opentokError.getErrorCode().equals(OpentokError.ErrorCode.SessionSignalDataTooLong) || opentokError.getErrorCode().equals(OpentokError.ErrorCode.SessionSignalTypeTooLong) ) {
            addLogEvent(OpenTokConfig.LOG_ACTION_SEND_MESSAGE, OpenTokConfig.LOG_VARIATION_ERROR);
        }
        else {
            addLogEvent(OpenTokConfig.LOG_ACTION_INITIALIZE, OpenTokConfig.LOG_VARIATION_ERROR);
        }
    }

    /**
     * Converts dp to real pixels, according to the screen density.
     *
     * @param dp A number of density-independent pixels.
     * @return The equivalent number of real pixels.
     */
    private int dpToPx(int dp) {
        double screenDensity = this.getResources().getDisplayMetrics().density;
        return (int) (screenDensity * (double) dp);
    }
}
