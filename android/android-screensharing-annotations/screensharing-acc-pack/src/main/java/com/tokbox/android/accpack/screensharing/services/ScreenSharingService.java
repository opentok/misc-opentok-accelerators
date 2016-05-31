package com.tokbox.android.accpack.screensharing.services;


import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Message;
import android.util.Log;
import android.view.Gravity;
import android.view.WindowManager;


import com.tokbox.android.accpack.annotations.AnnotationsToolbar;
import com.tokbox.android.accpack.annotations.AnnotationsView;
import com.tokbox.android.accpack.annotations.services.AbstractService;
import com.tokbox.android.accpack.screensharing.ScreenPublisher;
import com.tokbox.android.accpack.screensharing.ScreenSharingBar;

public class ScreenSharingService extends AbstractService implements ScreenSharingBar.ScreenSharingBarListener {

    private static final String LOG_TAG = ScreenSharingService.class.getSimpleName();

    public static final int MSG_CLOSE = 1;
    public static final int MSG_ANNOTATIONS = 2;
    public static final int MSG_STARTED = 3;


    private Intent mIntent;
    private ScreenSharingBar mScreenSharingBar;
    private WindowManager wm;

    private ScreenPublisher mScreenPublisher;
    private  AnnotationsView mAnnotationView;

    private boolean mAnnotations;
    private AnnotationsToolbar mAnnotationsToolbar;


    @Override
    public void onDestroy() {
        super.onDestroy();
        if(mScreenSharingBar != null)
        {
            ((WindowManager) getSystemService(WINDOW_SERVICE)).removeView(mScreenSharingBar);
            mScreenSharingBar = null;
        }
        if (mAnnotations) {
            ((WindowManager) getSystemService(WINDOW_SERVICE)).removeView(mAnnotationsToolbar);
        }
    }

    @Override
    public void onStartService() {
        Log.i(LOG_TAG, "OnStartService: ScreenSharingService");

        mScreenSharingBar = new ScreenSharingBar(getApplicationContext(), this);

        WindowManager.LayoutParams windowParams = new WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.TYPE_SYSTEM_ALERT,
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
                        |  WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
                PixelFormat.TRANSLUCENT);
        windowParams.gravity = Gravity.RIGHT | Gravity.TOP;
        ((WindowManager) getSystemService(WINDOW_SERVICE)).addView(mScreenSharingBar, windowParams);


        addMessage(Message.obtain(null, MSG_STARTED));

    }

    @Override
    public void onStopService() {
        Log.i(LOG_TAG, "onStopService: ScreenSharingService");
        send(Message.obtain(null, MSG_CLOSE));
    }

    @Override
    public void onReceiveMessage(Message msg) {
        Log.i(LOG_TAG, "onReceiveMessage: ScreenSharingService");

        if (msg.what == MSG_ANNOTATIONS) {
            Log.i(LOG_TAG, "onReceiveMessage MSG_ANNOTATIONS: " + msg.getData().getInt("annotations"));
            mAnnotations = msg.getData().getInt("annotations") != 0;
            enableAnnotations();
        }
    }
    private void enableAnnotations(){

        if (mAnnotations){
            WindowManager.LayoutParams windowParams2 = new WindowManager.LayoutParams(
                    WindowManager.LayoutParams.MATCH_PARENT,
                    WindowManager.LayoutParams.WRAP_CONTENT,
                    WindowManager.LayoutParams.TYPE_PHONE,
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
                            |  WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
                    PixelFormat.TRANSLUCENT);
            windowParams2.y = 600;
            windowParams2.x = 0;
            mAnnotationsToolbar = new AnnotationsToolbar(getApplicationContext());
            ((WindowManager) getSystemService(WINDOW_SERVICE)).addView(mAnnotationsToolbar, windowParams2);
        }
        else {
            if ( mAnnotationsToolbar != null )
             ((WindowManager) getSystemService(WINDOW_SERVICE)).removeView(mAnnotationsToolbar);
        }

    }

    @Override
    public void onClose() {
        try {
            this.stopSelf();
            this.onDestroy();
        } catch (Throwable throwable) {
            throwable.printStackTrace();
        }
    }
}
