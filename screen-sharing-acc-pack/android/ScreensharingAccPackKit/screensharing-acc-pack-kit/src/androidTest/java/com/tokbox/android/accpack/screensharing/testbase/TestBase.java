package com.tokbox.android.accpack.screensharing.testbase;

import android.content.Context;
import android.test.AndroidTestCase;
import android.util.Log;

import com.opentok.android.OpentokError;
import com.opentok.android.Session;
import com.opentok.android.Stream;
import com.tokbox.android.accpack.AccPackSession;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;


public class TestBase extends AndroidTestCase {

    public static String LOGTAG = TestBase.class.getName();

    protected final static int WAIT_TIME = 75;

    protected Context context;
    protected String apiKey;
    protected String apiSecret;
    protected String sessionId;
    protected String token;

    protected AccPackSession session;

    protected AtomicBoolean sessionConnected = new AtomicBoolean();
    protected AtomicBoolean sessionError = new AtomicBoolean();

    protected CountDownLatch sessionConnectedLock = new CountDownLatch(1);
    protected CountDownLatch sessionErrorLock = new CountDownLatch(1);

    protected OpentokError sessionLastError = null;

    protected Session.SessionListener sessionListener = new Session.SessionListener() {


        @Override
        public void onStreamReceived(Session session, Stream stream) {
            Log.d(LOGTAG,"Session - onStreamReceived");
        }

        @Override
        public void onError(Session session, OpentokError error) {
            Log.d(LOGTAG,"Session - onError");
        }

        @Override
        public void onStreamDropped(Session session, Stream stream) {
            Log.d(LOGTAG,"Session - onStreamDropped");
        }


        @Override
        public void onDisconnected(Session session) {
            Log.d(LOGTAG,"Session - onDisconnected");
        }

        @Override
        public void onConnected(Session session) {
            Log.d(LOGTAG,"Session - onConnected");
            sessionConnected.set(true);
            sessionConnectedLock.countDown();
        }
    };

    protected void setUp() throws Exception {
        super.setUp();

        this.context = getContext();
    }

    protected void setUp(String key, String secret) throws Exception {
        super.setUp();

        this.context = getContext();
        this.apiKey = key;
        this.apiSecret = secret;

    }
    protected void setUp(String sessionId, String token, String key) throws Exception {
        this.context = getContext();
        this.apiKey = key;
        this.token = token;
        this.sessionId = sessionId;
    }

    protected void tearDown() throws Exception {
        super.tearDown();

        this.sessionConnectedLock = new CountDownLatch(1);
        this.sessionErrorLock = new CountDownLatch(1);
        this.sessionConnected.set(false);
        this.sessionError.set(false);
        this.session = null;
        this.sessionLastError = null;
    }


    protected void waitSessionConnected() throws InterruptedException {
        sessionConnectedLock.await(WAIT_TIME, TimeUnit.SECONDS);
        assertTrue("session failed to connect", sessionConnected.get());
        assertFalse(sessionError.get());
        assertNull(sessionLastError);
    }
}
