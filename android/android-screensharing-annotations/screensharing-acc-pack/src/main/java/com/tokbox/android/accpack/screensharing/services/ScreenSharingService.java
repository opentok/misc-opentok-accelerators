package com.tokbox.android.accpack.screensharing.services;


import android.app.Service;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.os.IBinder;
import android.support.annotation.Nullable;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;


import com.opentok.android.BaseVideoRenderer;
import com.opentok.android.Publisher;
import com.opentok.android.PublisherKit;
import com.tokbox.android.accpack.annotations.AnnotationsToolbar;
import com.tokbox.android.accpack.annotations.AnnotationsView;
import com.tokbox.android.accpack.screensharing.R;
import com.tokbox.android.accpack.screensharing.ScreenPublisher;

public class ScreenSharingService extends Service {

    private Intent mIntent;
    private TextView mScreenSharingBar;
    private WindowManager wm;

    private ScreenPublisher mScreenPublisher;
    private  AnnotationsView mAnnotationView;
    TextView tv1;

    private boolean mAnnotations;
    //private AnnotationsView mAnnotationsView;
    private AnnotationsToolbar mAnnotationsToolbar;

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        mScreenSharingBar = new TextView(this);
        mScreenSharingBar.setText(R.string.screensharing_text);
        mScreenSharingBar.setGravity(Gravity.CENTER_HORIZONTAL);
        mScreenSharingBar.setBackgroundColor(getResources().getColor(R.color.screensharing_bar));

        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT);
        params.height= (int)getResources().getDimension(R.dimen.screensharing_bar_height);
        params.addRule(RelativeLayout.ALIGN_PARENT_TOP);

        mScreenSharingBar.setLayoutParams(params);


        super.onCreate();
        //Toast.makeText(getBaseContext(),"onCreate", Toast.LENGTH_LONG).show();
        WindowManager.LayoutParams windowParams = new WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.TYPE_SYSTEM_OVERLAY,
                0,
                PixelFormat.TRANSLUCENT);
        windowParams.gravity = Gravity.RIGHT | Gravity.TOP;
        ((WindowManager) getSystemService(WINDOW_SERVICE)).addView(mScreenSharingBar, windowParams);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {

        mIntent = intent;

        Bundle bundle = intent.getExtras();
        mAnnotations = bundle.getBoolean("annotations");

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
           // mAnnotationsToolbar.setOnClickListener(new AnnotationsClick());
            ((WindowManager) getSystemService(WINDOW_SERVICE)).addView(mAnnotationsToolbar, windowParams2);
        }
        return super.onStartCommand(intent, flags, startId);
    }
/*
    public class AnnotationsClick implements View.OnClickListener {

        @Override
        public void onClick(View v) {
            Intent mIntent = new Intent(getApplicationContext(), AnnotationsService.class);
            getApplicationContext().startService(mIntent);
        }
    }*/
    @Override
    public void onDestroy() {
        super.onDestroy();
       // Toast.makeText(getBaseContext(),"onDestroy", Toast.LENGTH_LONG).show();
        if(mScreenSharingBar != null)
        {
            ((WindowManager) getSystemService(WINDOW_SERVICE)).removeView(mScreenSharingBar);
            mScreenSharingBar = null;
        }
        if (mAnnotations) {
            ((WindowManager) getSystemService(WINDOW_SERVICE)).removeView(mAnnotationsToolbar);
        }
    }
}
