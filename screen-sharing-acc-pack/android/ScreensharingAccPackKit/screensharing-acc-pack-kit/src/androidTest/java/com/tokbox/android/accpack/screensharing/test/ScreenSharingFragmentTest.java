package com.tokbox.android.accpack.screensharing.test;

import com.opentok.android.Connection;
import com.opentok.impl.ConnectionImpl;
import com.tokbox.android.accpack.AccPackSession;
import com.tokbox.android.accpack.screensharing.ScreenSharingFragment;
import com.tokbox.android.accpack.screensharing.config.APIConfig;
import com.tokbox.android.accpack.screensharing.testbase.TestBase;
import com.tokbox.android.accpack.screensharing.util.TestUtils;
import com.tokbox.android.annotations.AnnotationsToolbar;

import junit.framework.Assert;

import org.junit.Test;

public class ScreenSharingFragmentTest extends TestBase {

    private ScreenSharingFragment screenSharingFragment;
    private String apiKey = String.valueOf(APIConfig.API_KEY);
    private Connection connection;

    protected void setUp() throws Exception {
        super.setUp(APIConfig.SESSION_ID, APIConfig.TOKEN, APIConfig.API_KEY);
        //Class[] params = {String.class, long.class, String.class};
        //connection = (Connection) TestUtils.getConstructor(Connection.class, params).newInstance(TestUtils.generateString(6), 0, TestUtils.generateString(6));
        connection = new ConnectionImpl(TestUtils.generateString(6), 0, TestUtils.generateString(6));
    }

    protected void tearDown() throws Exception {
        super.tearDown();
    }

    public void testScreenSharingFragment() throws Exception{
        session = new AccPackSession(this.context, this.apiKey, this.sessionId);
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        Assert.assertNotNull(screenSharingFragment);
    }

    public void testScreenSharingFragmentWhenSessionIsNull(){
        screenSharingFragment = null;
        try{
            screenSharingFragment = ScreenSharingFragment.newInstance(null, apiKey);
            Assert.fail("Should have thrown an exception when Session is null");
        }catch (Exception e) {
            Assert.assertNull(screenSharingFragment);
        }
    }

    public void testScreenSharingFragmentWhenApiKeyIsNull(){
        session = new AccPackSession(this.context, this.apiKey, this.sessionId);
        screenSharingFragment = null;
        try{
            screenSharingFragment = ScreenSharingFragment.newInstance(session, null);
            Assert.fail("Should have thrown an exception when APIkey is null");
        }catch (Exception e) {
            Assert.assertNull(screenSharingFragment);
        }
    }

    public void testScreenSharingFragmentWhenApiKeyIsEmpty(){
        session = new AccPackSession(this.context, this.apiKey, this.sessionId);
        screenSharingFragment = null;
        try{
            screenSharingFragment = ScreenSharingFragment.newInstance(session, "");
            Assert.fail("Should have thrown an exception when APIkey is empty");
        }catch (Exception e) {
            Assert.assertNull(screenSharingFragment);
        }
    }

    public void testScreenSharingFragmentWhenApiKeyIsLongString(){
        session = new AccPackSession(this.context, this.apiKey, this.sessionId);
        screenSharingFragment = null;
        try{
            screenSharingFragment = ScreenSharingFragment.newInstance(session, TestUtils.generateString(60));
            Assert.fail("Should have thrown an exception when APIkey is too long");
        }catch (Exception e) {
            Assert.assertNull(screenSharingFragment);
        }
    }

    public void testStart() throws Exception{
        session = new AccPackSession(this.context, this.apiKey, this.sessionId);
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.start();
        Assert.assertTrue(screenSharingFragment.isStarted());
    }


    public void testStop() throws Exception{
        session = new AccPackSession(this.context, this.apiKey, this.sessionId);
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.stop();
        Assert.assertFalse(screenSharingFragment.isStarted());
    }

    public void testOnSiganlReceived() throws Exception{
        session = new AccPackSession(this.context, this.apiKey, this.sessionId);
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.onSignalReceived(session, TestUtils.generateString(6), TestUtils.generateString(6), connection);
    }

    public void testOnSiganlReceivedWhenSessionIsNull(){
        session = new AccPackSession(this.context, this.apiKey, this.sessionId);
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        try{
            screenSharingFragment = ScreenSharingFragment.newInstance(null, apiKey);
            Assert.fail("Should have thrown an exception when Session is null");
        }catch (Exception e) {}
    }

    public void testOnSiganlReceivedWhenTypeIsNull() throws Exception{
        session = new AccPackSession(this.context, this.apiKey, this.sessionId);
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.onSignalReceived(session, null, TestUtils.generateString(6), connection);
    }

    public void testOnSiganlReceivedWhenTypeIsEmpty() throws Exception{
        session = new AccPackSession(this.context, this.apiKey, this.sessionId);
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.onSignalReceived(session, "", TestUtils.generateString(6), connection);
    }

    public void testOnSiganlReceivedWhenTypeIsLong() throws Exception{
        session = new AccPackSession(this.context, this.apiKey, this.sessionId);
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.onSignalReceived(session, TestUtils.generateString(600), TestUtils.generateString(6), connection);
    }

    public void testOnSiganlReceivedWhenDataIsNull() throws Exception {
        session = new AccPackSession(this.context, this.apiKey, this.sessionId);
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.onSignalReceived(session, TestUtils.generateString(6), null, connection);
    }

    public void testOnSiganlReceivedWhenDataIsEmpty() throws Exception{
        session = new AccPackSession(this.context, this.apiKey, this.sessionId);
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.onSignalReceived(session, TestUtils.generateString(6), "", connection);
    }

    public void testOnSiganlReceivedWhenDataIsLong() throws Exception{
        session = new AccPackSession(this.context, this.apiKey, this.sessionId);
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.onSignalReceived(session, TestUtils.generateString(6), TestUtils.generateString(600), connection);
    }

    public void testOnSiganlReceivedWhenConnectionIsNull(){
        session = new AccPackSession(this.context, this.apiKey, this.sessionId);
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        try{
            screenSharingFragment.onSignalReceived(session, TestUtils.generateString(6), TestUtils.generateString(6), null);
            Assert.fail("Should have thrown an exception when Connection is null");
        }catch (Exception e) {}
    }

    public void testEnableAnnotations() throws Exception{
        session = new AccPackSession(this.context, this.apiKey, this.sessionId);
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.enableAnnotations(true, new AnnotationsToolbar(context));
        Assert.assertTrue(TestUtils.getPrivateField(screenSharingFragment, "isAnnotationsEnabled").get(screenSharingFragment).equals(true));
        screenSharingFragment.enableAnnotations(false, new AnnotationsToolbar(context));
        Assert.assertTrue(TestUtils.getPrivateField(screenSharingFragment, "isAnnotationsEnabled").get(screenSharingFragment).equals(false));
    }

    public void testEnableAudioScreenSharing() throws Exception{
        session = new AccPackSession(this.context, this.apiKey, this.sessionId);
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.enableAudioScreensharing(true);
        Assert.assertTrue(TestUtils.getPrivateField(screenSharingFragment, "isAudioEnabled").get(screenSharingFragment).equals(true));
        screenSharingFragment.enableAudioScreensharing(false);
        Assert.assertTrue(TestUtils.getPrivateField(screenSharingFragment, "isAudioEnabled").get(screenSharingFragment).equals(false));
    }

    public void testOnPause() throws Exception{
        session = new AccPackSession(this.context, this.apiKey, this.sessionId);
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.onPause();
        Assert.assertFalse(screenSharingFragment.isStarted());
    }

    public void testOnResume() throws Exception{
        session = new AccPackSession(this.context, this.apiKey, this.sessionId);
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.onResume();
        Assert.assertTrue(screenSharingFragment.isStarted());
    }

    public void testOnDestroy() throws Exception{
        session = new AccPackSession(this.context, this.apiKey, this.sessionId);
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.onDestroy();
        Assert.assertNull(TestUtils.getPrivateField(screenSharingFragment, "mScreensharingBar").get(screenSharingFragment));
        Assert.assertNull(TestUtils.getPrivateField(screenSharingFragment, "mMediaProjection").get(screenSharingFragment));
    }
}
