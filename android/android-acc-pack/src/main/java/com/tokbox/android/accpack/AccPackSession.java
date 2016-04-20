package com.tokbox.android.accpack;

import android.content.Context;
import android.util.Log;

import com.opentok.android.Connection;
import com.opentok.android.OpentokError;
import com.opentok.android.Session;
import com.opentok.android.Stream;

import java.util.ArrayList;

/**
 * Created by mserrano on 11/04/16.
 */
public class AccPackSession extends Session {

    private final String LOG_TAG = this.getClass().getSimpleName();

    private ArrayList<SessionListener> mSessionListeners = new ArrayList<>();
    private ArrayList<ConnectionListener> mConnectionsListeners = new ArrayList<>();
    private ArrayList<SignalListener> mSignalListeners = new ArrayList<>();
    private ArrayList<ArchiveListener> mArchiveListeners = new ArrayList<>();
    private ArrayList<StreamPropertiesListener> mStreamPropertiesListeners = new ArrayList<>();
    private ArrayList<ReconnectionListener> mReconnectionListeners = new ArrayList<>();

    public AccPackSession(Context context, String apiKey, String sessionId) {
        super(context, apiKey, sessionId);
    }

    @Override
    public void setSessionListener(SessionListener listener) {
        super.setSessionListener(listener);
        mSessionListeners.add(listener);
    }

    @Override
    public void setConnectionListener(ConnectionListener listener) {
        super.setConnectionListener(listener);
        mConnectionsListeners.add(listener);
    }

    @Override
    public void setStreamPropertiesListener(StreamPropertiesListener listener) {
        super.setStreamPropertiesListener(listener);
        mStreamPropertiesListeners.add(listener);
    }

    @Override
    public void setSignalListener(SignalListener listener) {
        super.setSignalListener(listener);
        mSignalListeners.add(listener);
    }

    @Override
    public void setArchiveListener(ArchiveListener listener) {
        super.setArchiveListener(listener);
        mArchiveListeners.add(listener);
    }

    @Override
    public void setReconnectionListener(ReconnectionListener listener) {
        super.setReconnectionListener(listener);
        mReconnectionListeners.add(listener);
    }

    @Override
    protected void onConnected() {
        for(SessionListener l : mSessionListeners){
            l.onConnected(this);
        }
    }

    @Override
    protected void onReconnecting() {
        for(ReconnectionListener l : mReconnectionListeners){
            l.onReconnecting(this);
        }
    }

    @Override
    protected void onReconnected() {
        for(ReconnectionListener l : mReconnectionListeners){
            l.onReconnected(this);
        }
    }

    @Override
    protected void onDisconnected() {
        for(SessionListener l : mSessionListeners){
            l.onDisconnected(this);
        }
    }

    @Override
    protected void onError(OpentokError error) {
        for(SessionListener l : mSessionListeners){
            l.onError(this, error);
        }
    }

    @Override
    protected void onStreamReceived(Stream stream) {
        for(SessionListener l : mSessionListeners){
            l.onStreamReceived(this, stream);
        }
    }

    @Override
    protected void onStreamDropped(Stream stream) {
        for(SessionListener l : mSessionListeners){
            l.onStreamDropped(this, stream);
        }
    }

    @Override
    protected void onSignalReceived(String type, String data, Connection connection) {
        for(SignalListener l : mSignalListeners){
            l.onSignalReceived(this, type, data, connection);
        }
    }

    @Override
    protected void onConnectionCreated(Connection connection) {
        for(ConnectionListener l : mConnectionsListeners){
            l.onConnectionCreated(this, connection);
        }
    }

    @Override
    protected void onConnectionDestroyed(Connection connection) {
        for(ConnectionListener l : mConnectionsListeners){
            l.onConnectionDestroyed(this, connection);
        }
    }

    @Override
    protected void onStreamHasAudioChanged(Stream stream, int hasAudio) {
        for(StreamPropertiesListener l : mStreamPropertiesListeners){
            l.onStreamHasAudioChanged(this, stream,  (hasAudio != 0));
        }
    }

    @Override
    protected void onStreamHasVideoChanged(Stream stream, int hasVideo) {
        for(StreamPropertiesListener l : mStreamPropertiesListeners){
            l.onStreamHasVideoChanged(this, stream,  (hasVideo != 0));
        }
    }

    @Override
    protected void onStreamVideoDimensionsChanged(Stream stream, int width, int height) {
        for(StreamPropertiesListener l : mStreamPropertiesListeners){
            l.onStreamVideoDimensionsChanged(this, stream,  width, height);
        }
    }

    @Override
    protected void onStreamVideoTypeChanged(Stream stream, Stream.StreamVideoType videoType) {
        for(StreamPropertiesListener l : mStreamPropertiesListeners){
            l.onStreamVideoTypeChanged(this, stream,  videoType);
        }
    }

    @Override
    protected void onArchiveStarted(String id, String name) {
        for(ArchiveListener l : mArchiveListeners){
            l.onArchiveStarted(this, id, name);
        }
    }

    @Override
    protected void onArchiveStopped(String id) {
        for(ArchiveListener l : mArchiveListeners){
            l.onArchiveStopped(this, id);
        }
    }


}
