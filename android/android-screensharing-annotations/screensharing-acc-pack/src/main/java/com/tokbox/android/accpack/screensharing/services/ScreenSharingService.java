package com.tokbox.android.accpack.screensharing.services;


import android.app.Service;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.IBinder;
import android.support.annotation.Nullable;
import android.view.Gravity;
import android.view.WindowManager;
import android.widget.RelativeLayout;
import android.widget.TextView;


import com.tokbox.android.accpack.screensharing.R;

public class ScreenSharingService extends Service {

    private TextView mScreenSharingBar;
    private WindowManager wm;

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
//              WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
//                      | WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
                PixelFormat.TRANSLUCENT);
        //windowParams.height = (int)getResources().getDimension(R.dimen.screensharing_bar_height);
        windowParams.gravity = Gravity.RIGHT | Gravity.TOP;
        windowParams.setTitle("Load Average");
        ((WindowManager) getSystemService(WINDOW_SERVICE)).addView(mScreenSharingBar, windowParams);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
       // Toast.makeText(getBaseContext(),"onDestroy", Toast.LENGTH_LONG).show();
        if(mScreenSharingBar != null)
        {
            ((WindowManager) getSystemService(WINDOW_SERVICE)).removeView(mScreenSharingBar);
            //wm.removeView(mScreenSharingBar);
            mScreenSharingBar = null;
        }
    }
}
