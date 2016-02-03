package com.opentok.android.im.sample;

import android.app.FragmentTransaction;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;


import com.opentok.android.Connection;
import com.opentok.android.OpentokError;
import com.opentok.android.Session;
import com.opentok.android.Stream;
import com.opentok.android.textchat.ChatMessage;
import com.opentok.android.textchat.TextChatFragment;

import java.util.UUID;
public class MainActivity extends AppCompatActivity implements Session.SignalListener, Session.SessionListener, TextChatFragment.TextChatListener{

    private static final String LOGTAG = "text-chat-sample-app";
    private static final String SIGNAL_TYPE = "TextChat";

    private TextChatFragment mTextChatFragment;
    private FragmentTransaction mFragmentTransaction;
    private Session mSession = null;

    // Replace with a generated Session ID
    public static final String SESSION_ID = "2_MX4xMDB-fjE0NTQwNTg5MjU1MjZ-VmZNMG1pNUtwaXNNOHVYeUh5aWZqV3Bqfn4";
    // Replace with a generated token (from the dashboard or using an OpenTok server SDK)
    public static final String TOKEN = "T1==cGFydG5lcl9pZD0xMDAmc2RrX3ZlcnNpb249dGJwaHAtdjAuOTEuMjAxMS0wNy0wNSZzaWc9Y2UyYmIwMzI5ODlhYzhhMWNkYzUyODMwMmQ1OGRjZjQxZDZiYmE4ODpzZXNzaW9uX2lkPTJfTVg0eE1EQi1makUwTlRRd05UZzVNalUxTWpaLVZtWk5NRzFwTlV0d2FYTk5PSFZZZVVoNWFXWnFWM0JxZm40JmNyZWF0ZV90aW1lPTE0NTQwNTcwOTYmcm9sZT1tb2RlcmF0b3Imbm9uY2U9MTQ1NDA1NzA5Ni4zODE0MTMxMTE5ODMwMyZleHBpcmVfdGltZT0xNDU2NjQ5MDk2JmNvbm5lY3Rpb25fZGF0YT1tYXJpbmFz";
    // Replace with your OpenTok API key
    public static final String API_KEY = "100";


    private boolean msgError = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        sessionConnect();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    private void sessionConnect() {
        if (mSession == null) {
            mSession = new Session(MainActivity.this,
                    API_KEY, SESSION_ID);
            mSession.setSignalListener(this);
            mSession.setSessionListener(this);
            mSession.connect(TOKEN);
        }
    }

    // Initialize a TextChatFragment instance and add it to the UI
    private void loadTextChatFragment(){
        int containerId = R.id.fragment_container;
        mFragmentTransaction = getFragmentManager().beginTransaction();
        mTextChatFragment = (TextChatFragment) this.getFragmentManager().findFragmentByTag("TextChatFragment");

        if (mTextChatFragment == null) {
            mTextChatFragment = new TextChatFragment();
            mTextChatFragment.setMaxTextLength(1050);
            mTextChatFragment.setListener(this);
            mTextChatFragment.setSenderInfo(mSession.getConnection().getConnectionId(), mSession.getConnection().getData());

            mFragmentTransaction.add(containerId, mTextChatFragment, "TextChatFragment").commit();

        }
    }

    @Override
    public boolean onMessageReadyToSend(ChatMessage msg) {
        Log.d(LOGTAG, "TextChat listener: onMessageReadyToSend: " + msg.getText());

        if (mSession != null) {
            mSession.sendSignal(SIGNAL_TYPE, msg.getText());
        }
        return msgError;
    }

    @Override
    public void onTextChatError(String error) {
        Log.d(LOGTAG, "Error: "+error);
    }


    @Override
    public void onSignalReceived(Session session, String type, String data, Connection connection) {
        Log.d(LOGTAG, "onSignalReceived. Type: " + type + " data: " + data);
        ChatMessage msg = null;

        if (!connection.getConnectionId().equals(mSession.getConnection().getConnectionId())) {

            // The signal was sent from another participant. The sender ID is set to the sender's
            // connection ID. The sender alias is the value added as connection data when you
            // created the user's token.

            msg = new ChatMessage.ChatMessageBuilder(connection.getConnectionId(), UUID.randomUUID(), ChatMessage.MessageStatus.RECEIVED_MESSAGE)
                    .senderAlias(connection.getData())
                    .text(data)
                    .build();
            // Add the new ChatMessage to the text-chat component
            mTextChatFragment.addMessage(msg);
        }
    }


    @Override
    public void onConnected(Session session) {
        Log.d(LOGTAG, "The session is connected.");

        loadTextChatFragment();
    }

    @Override
    public void onDisconnected(Session session) {
        Log.d(LOGTAG, "The session disconnected.");
    }

    @Override
    public void onError(Session session, OpentokError opentokError) {
        Log.d(LOGTAG, "Session error. OpenTokError: " + opentokError.getErrorCode() + " - " + opentokError.getMessage());
        OpentokError.ErrorCode errorCode = opentokError.getErrorCode();
    }

    @Override
    public void onStreamReceived(Session session, Stream stream) {
    }

    @Override
    public void onStreamDropped(Session session, Stream stream) {
    }


}
