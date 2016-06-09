package com.tokbox.android.accpack.annotations.services;

import android.app.Service;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.os.IBinder;
import android.os.Message;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.Gravity;
import android.view.WindowManager;
import android.widget.Toast;

import com.tokbox.android.accpack.annotations.AnnotationsView;
import com.tokbox.android.accpack.annotations.R;


public class AnnotationsService extends AbstractService {

    public static final int MSG_ERASE = 1;
    public static final int MSG_DONE = 2;
    public static final int MSG_UPDATE_MODE = 3;
    public static final int MSG_COLOR = 4;

    AnnotationsView mAnnotationsView;
    Intent mIntent;
    int width;
    int height;
    String mode;

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Toast.makeText(getApplicationContext(), "ANNOTATIONS SERVICE", Toast.LENGTH_SHORT).show();

        mIntent = intent;

        Bundle bundle = intent.getExtras();
        width = bundle.getInt("view_width");
        height = bundle.getInt("view_height");
        mode = bundle.getString("mode");

        mAnnotationsView = new AnnotationsView(getApplicationContext());
        mAnnotationsView.setLayoutByDefault();
        mAnnotationsView.setMode(mode);
        WindowManager.LayoutParams windowParams2 = new WindowManager.LayoutParams(
                width,
                height,
                WindowManager.LayoutParams.TYPE_PHONE,
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
                        |  WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
                PixelFormat.TRANSLUCENT);
        windowParams2.gravity = Gravity.TOP | Gravity.CENTER_HORIZONTAL;
        ((WindowManager) getSystemService(WINDOW_SERVICE)).addView(mAnnotationsView, windowParams2);
        return super.onStartCommand(intent, flags, startId);

    }

    @Override
    public void onDestroy() {
        super.onDestroy();

        if( mAnnotationsView != null ){
            ((WindowManager) getSystemService(WINDOW_SERVICE)).removeView(mAnnotationsView);
        }
    }

    @Override
    public void onStartService() {
        Log.i("MARINAS", "ON START ANNOTATIONS SERVICE ");
    }

    @Override
    public void onStopService() {
        Log.i("MARINAS", "ON STOP ANNOTATIONS SERVICE ");
    }

    @Override
    public void onReceiveMessage(Message msg) {
        Log.i("MARINAS", "ON RECEIVE MESSAGE ANNOTATIONS SERVICE ");

        switch (msg.what) {
            case AnnotationsService.MSG_ERASE:
                Log.i("MARINAS", "ON RECEIVE MESSAGE ERASE ");
                mAnnotationsView.clearCanvas();
                break;

            case AnnotationsService.MSG_DONE:
                Log.i("MARINAS", "ON RECEIVE MESSAGE DONE ");
                this.stopSelf();
                this.onDestroy();
                break;

            case AnnotationsService.MSG_UPDATE_MODE:
                Log.i("MARINAS", "ON RECEIVE MESSAGE UPDATE_MODE "+msg.getData().getString("mode"));
                mAnnotationsView.setMode(msg.getData().getString("mode"));
                break;

            case AnnotationsService.MSG_COLOR:
                Log.i("MARINAS", "ON RECEIVE MESSAGE COLOR "+msg.getData().getInt("color"));
                mAnnotationsView.setColor(msg.getData().getInt("color"));
                break;

            default:

        }
    }

}
