package com.tokbox.android.accpack.screensharing.test;


import android.graphics.PixelFormat;
import android.media.ImageReader;
import android.view.View;

import com.opentok.android.BaseVideoCapturer;
import com.tokbox.android.accpack.screensharing.ScreenSharingCapturer;
import com.tokbox.android.accpack.screensharing.testbase.TestBase;

import junit.framework.Assert;

import org.junit.Test;

public class ScreenSharingCapturerTest extends TestBase{

    public ScreenSharingCapturer screenSharingCapturer;
    private ImageReader imageReader;
    private View view;

    protected void setUp() throws Exception {
        super.setUp();
        imageReader = ImageReader.newInstance(1, 1, PixelFormat.RGBA_8888, 2);
        view = new View(context);
    }

    protected void tearDown() throws Exception {
        super.tearDown();
    }

    public void testScreenSharingCapturer() throws Exception{
        screenSharingCapturer = new ScreenSharingCapturer(context, view, imageReader);
        Assert.assertNotNull(screenSharingCapturer);
        Assert.assertFalse(screenSharingCapturer.isCaptureStarted());
    }

    public void testScreenSharingCapturerWhenContextIsNull() throws Exception{
        screenSharingCapturer = null;
        try{
            screenSharingCapturer = new ScreenSharingCapturer(null, view, imageReader);
            Assert.fail("Should have thrown an exception when Context is null");
        }catch (Exception e) {
            Assert.assertNull(screenSharingCapturer);
        }
    }

    public void testScreenSharingCapturerWhenViewIsNull() throws Exception{
        screenSharingCapturer = null;
        try{
            screenSharingCapturer = new ScreenSharingCapturer(context, null, imageReader);
            Assert.fail("Should have thrown an exception when View is null");
        }catch (Exception e) {
            Assert.assertNull(screenSharingCapturer);
        }
    }

    public void testScreenSharingCapturerWhenImageIsNull() throws Exception{
        screenSharingCapturer = null;
        try{
            screenSharingCapturer = new ScreenSharingCapturer(context, view, null);
            Assert.fail("Should have thrown an exception when Image is null");
        }catch (Exception e) {
            Assert.assertNull(screenSharingCapturer);
        }
    }

    public void testStartCapture() throws Exception{
        screenSharingCapturer = new ScreenSharingCapturer(context, view, imageReader);
        Assert.assertEquals(0, screenSharingCapturer.startCapture());
        Assert.assertTrue(screenSharingCapturer.isCaptureStarted());
    }

    public void testStopCapture() throws Exception{
        screenSharingCapturer = new ScreenSharingCapturer(context, view, imageReader);
        Assert.assertEquals(0, screenSharingCapturer.stopCapture());
        Assert.assertFalse(screenSharingCapturer.isCaptureStarted());
    }

    public void testGetCaptureSettings() throws Exception{
        screenSharingCapturer = new ScreenSharingCapturer(context, view, imageReader);
        BaseVideoCapturer.CaptureSettings captureSettings = screenSharingCapturer.getCaptureSettings();
        Assert.assertEquals(2, captureSettings.format);
        Assert.assertEquals(0, captureSettings.width);
        Assert.assertEquals(0, captureSettings.height);
    }

//    @Test
//    public void runnable_When_OK() throws Exception{
//        screenSharingCapturer = new ScreenSharingCapturer(context, new View(context), ImageReader.newInstance(0, 0, PixelFormat.RGBA_8888, 2));
//        Assert.assertNotNull(screenSharingCapturer.newFrame());
//    }

}
