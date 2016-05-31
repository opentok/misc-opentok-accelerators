package com.tokbox.android.accpack.annotations.services;

import android.app.Service;
import android.content.Intent;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.Messenger;
import android.os.RemoteException;
import android.util.Log;

import java.util.ArrayList;

public abstract class AbstractService extends Service {
    private static final String LOG_TAG = AbstractService.class.getSimpleName();

    static final int MSG_REGISTER_CLIENT = 9991;
    static final int MSG_UNREGISTER_CLIENT = 9992;

    ArrayList<Messenger> mClients = new ArrayList<Messenger>(); // Keeps track of all current registered clients.
    final Messenger mMessenger = new Messenger(new IncomingHandler()); // Target we publish for clients to send messages to IncomingHandler.
    ArrayList<Message> mPendingMsgs = new ArrayList<Message>();

    private class IncomingHandler extends Handler { // Handler of incoming messages from clients.
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case MSG_REGISTER_CLIENT:
                    Log.i(LOG_TAG, "Client registered: "+msg.replyTo);
                    mClients.add(msg.replyTo);

                    for (int i=0; i<mPendingMsgs.size(); i++){
                        send(mPendingMsgs.get(i));
                    }
                    break;
                case MSG_UNREGISTER_CLIENT:
                    Log.i(LOG_TAG, "Client un-registered: "+msg.replyTo);
                    mClients.remove(msg.replyTo);
                    break;
                default:
                    Log.i(LOG_TAG, "onReceiveMessage: "+ msg.what);
                    onReceiveMessage(msg);
            }
        }
    }

    @Override
    public void onCreate() {
        Log.i(LOG_TAG, "Service Started.");
        super.onCreate();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.i(LOG_TAG, "Received start id " + startId + ": " + intent);
        onStartService();
        mClients = new ArrayList<Messenger>();
        return START_STICKY; // run until explicitly stopped.
    }

    @Override
    public IBinder onBind(Intent intent) {
        return mMessenger.getBinder();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();

        onStopService();

        Log.i(LOG_TAG, "Service Stopped.");
    }

    protected void send(Message msg) {
        for (int i=mClients.size()-1; i>=0; i--) {
            try {
                mClients.get(i).send(msg);

                if (mPendingMsgs.contains(msg)){
                    removeMessage(msg);
                }
            }
            catch (RemoteException e) {
                 mClients.remove(i);
            }
        }
    }

    protected void addMessage(Message msg){
        mPendingMsgs.add(msg);
    }

    protected void removeMessage(Message msg){
        mPendingMsgs.remove(msg);
    }

    public abstract void onStartService();
    public abstract void onStopService();
    public abstract void onReceiveMessage(Message msg);

}
