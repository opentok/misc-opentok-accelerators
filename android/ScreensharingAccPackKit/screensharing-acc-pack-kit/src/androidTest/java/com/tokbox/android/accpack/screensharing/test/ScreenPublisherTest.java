package com.tokbox.android.accpack.screensharing.test;

import com.opentok.android.BaseVideoCapturer;
import com.tokbox.android.accpack.AccPackSession;
import com.tokbox.android.accpack.screensharing.ScreenPublisher;
import com.tokbox.android.accpack.screensharing.testbase.TestBase;
import com.tokbox.android.accpack.screensharing.util.TestUtils;

import junit.framework.Assert;

import org.junit.Test;

public class ScreenPublisherTest extends TestBase {

    private ScreenPublisher screenPublisher;

    protected void setUp() throws Exception {
        super.setUp();
    }

    protected void tearDown() throws Exception {
        super.tearDown();
    }

    public void testScreenPublisher() throws Exception{
        screenPublisher = new ScreenPublisher(context);
        Assert.assertNotNull(screenPublisher);
    }

    public void testScreenPublisherWhenContextIsNull(){
        screenPublisher = null;
        try{
            screenPublisher = new ScreenPublisher(null);
            Assert.fail("Should have thrown an exception when Context is null");
        }catch (Exception e) {
            Assert.assertNull(screenPublisher);
        }
    }

    public void testScreenPublisherWhenStringIsOK() throws Exception{
        String name = TestUtils.generateString(6);
        screenPublisher = new ScreenPublisher(context, name);
        Assert.assertNotNull(screenPublisher);
        Assert.assertEquals(name, screenPublisher.getName());
    }

    public void testScreenPublisherWhenStringIsEmpty() throws Exception{
        screenPublisher = new ScreenPublisher(context, "");
        Assert.assertNotNull(screenPublisher);
    }

    public void testScreenPublisherWhenStringIsNull() throws Exception{
        screenPublisher = new ScreenPublisher(context, null);
        Assert.assertNotNull(screenPublisher);
    }

    public void testScreenPublisherWhenStringIsLong() throws Exception{
        String name = TestUtils.generateString(60);
        screenPublisher = new ScreenPublisher(context, name);
        Assert.assertNotNull(screenPublisher);
        Assert.assertEquals(name, screenPublisher.getName());
    }

    public void  testScreenPublisherWhenCapturerIsNull() throws Exception {
        screenPublisher = null;
        try{
            screenPublisher = new ScreenPublisher(context, TestUtils.generateString(6), null);
            Assert.fail("Should have thrown an exception when Capturer is null");
        }catch (Exception e) {
            Assert.assertNull(screenPublisher);
        }
    }

    public void  testScreenPublisherWhenCapturerIsOK() throws Exception {
        String name = TestUtils.generateString(6);
        screenPublisher = new ScreenPublisher(context, name, new BaseVideoCapturer() {
            @Override
            public void init() {

            }

            @Override
            public int startCapture() {
                return 0;
            }

            @Override
            public int stopCapture() {
                return 0;
            }

            @Override
            public void destroy() {

            }

            @Override
            public boolean isCaptureStarted() {
                return false;
            }

            @Override
            public CaptureSettings getCaptureSettings() {
                return null;
            }

            @Override
            public void onPause() {

            }

            @Override
            public void onResume() {

            }
        });
        Assert.assertNotNull(screenPublisher);
        Assert.assertEquals(name, screenPublisher.getName());
    }

}
