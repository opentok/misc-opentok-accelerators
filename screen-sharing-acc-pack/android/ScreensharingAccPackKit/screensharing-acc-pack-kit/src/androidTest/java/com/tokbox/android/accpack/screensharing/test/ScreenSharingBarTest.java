package com.tokbox.android.accpack.screensharing.test;

import com.tokbox.android.accpack.AccPackSession;
import com.tokbox.android.accpack.screensharing.ScreenSharingBar;
import com.tokbox.android.accpack.screensharing.ScreenSharingFragment;
import com.tokbox.android.accpack.screensharing.config.APIConfig;
import com.tokbox.android.accpack.screensharing.testbase.TestBase;
import junit.framework.Assert;


public class ScreenSharingBarTest extends TestBase {

    private ScreenSharingBar screenSharingBar;
    private String apiKey = String.valueOf(APIConfig.API_KEY);

    protected void setUp() throws Exception {
        super.setUp(APIConfig.SESSION_ID, APIConfig.TOKEN, APIConfig.API_KEY);
    }

    protected void tearDown() throws Exception {
        super.tearDown();
    }

    public void testScreenSharingBar() throws Exception{
        session = new AccPackSession(this.context, this.apiKey, this.sessionId);
        screenSharingBar = new ScreenSharingBar(context, ScreenSharingFragment.newInstance(session, apiKey));
        Assert.assertNotNull(screenSharingBar);
    }

    public void testScreenSharingBarWhenContextIsNull(){
        session = new AccPackSession(this.context, this.apiKey, this.sessionId);
        screenSharingBar = null;
        try{
            screenSharingBar = new ScreenSharingBar(null, ScreenSharingFragment.newInstance(session, apiKey));
            Assert.fail("Should have thrown an exception when Context is null");
        }catch (Exception e) {
            Assert.assertNull(screenSharingBar);
        }
    }

    public void testScreenSharingBarWhenListenerIsNull(){
        screenSharingBar = null;
        try{
            screenSharingBar = new ScreenSharingBar(context, null);
            Assert.fail("Should have thrown an exception when Listener is null");
        }catch (Exception e) {
            Assert.assertNull(screenSharingBar);
        }
    }
}
