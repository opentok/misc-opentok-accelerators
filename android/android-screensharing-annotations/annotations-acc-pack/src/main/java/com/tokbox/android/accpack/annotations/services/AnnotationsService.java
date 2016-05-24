package com.tokbox.android.accpack.annotations.services;

import android.app.Service;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.os.IBinder;
import android.support.annotation.Nullable;
import android.view.Gravity;
import android.view.WindowManager;
import android.widget.Toast;

import com.tokbox.android.accpack.annotations.AnnotationsView;
import com.tokbox.android.accpack.annotations.R;


public class AnnotationsService extends Service {

    AnnotationsView mAnnotationsView;
    Intent mIntent;
    int width;
    int height;

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {

    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Toast.makeText(getApplicationContext(), "ANNOTATIONS SERVICE", Toast.LENGTH_SHORT).show();

        mIntent = intent;

        Bundle bundle = intent.getExtras();
        width = bundle.getInt("view_width");
        height = bundle.getInt("view_height");

        mAnnotationsView = new AnnotationsView(getApplicationContext());
        mAnnotationsView.setLayoutByDefault();
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

}
