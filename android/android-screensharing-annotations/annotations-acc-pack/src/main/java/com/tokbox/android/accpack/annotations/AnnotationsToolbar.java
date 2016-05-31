package com.tokbox.android.accpack.annotations;


import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.RemoteException;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Display;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.tokbox.android.accpack.annotations.services.AnnotationsService;
import com.tokbox.android.accpack.annotations.services.ServiceManager;

public class AnnotationsToolbar extends LinearLayout {

    private View rootView;
    private ImageButton mFreeHandBtn;
    private ImageButton mEraseBtn;
    private ImageButton mTypeBtn;
    private ImageButton mPickerColorBtn;
    private TextView mDoneBtn;
    private Context mContext;
    private Intent mIntent;
    private int viewWidth = 300;
    private int viewHeight = 400;

    private ServiceManager mService = null;

    public AnnotationsToolbar(Context context) {
        super(context);
        mContext = context;

        WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        Display display = wm.getDefaultDisplay();

        viewWidth = display.getWidth();
        viewHeight = display.getHeight() - 400;

        init();
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if ( mService != null ) {
            //stop annotationsservice
            try {
                mService.send(Message.obtain(null, AnnotationsService.MSG_DONE));
            } catch (RemoteException e) {
                e.printStackTrace();
            }
            mService = null;
        }
    }

    public void init(){
        rootView = inflate(mContext, R.layout.annotations_toolbar, this);
        mFreeHandBtn = (ImageButton) rootView.findViewById(R.id.draw_freehand);
        mPickerColorBtn = (ImageButton) rootView.findViewById(R.id.picker_color);
        mTypeBtn = (ImageButton) rootView.findViewById(R.id.type_tool);
        mEraseBtn = (ImageButton) rootView.findViewById(R.id.erase);
        mDoneBtn = (TextView) rootView.findViewById(R.id.done);

        mFreeHandBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.i("Marinas", "on click freehand button");

                if ( mService == null ) {

                    Bundle bundle = new Bundle();
                    bundle.putInt("view_width", viewWidth);
                    bundle.putInt("view_height", viewHeight);
                    mService = new ServiceManager(getContext(), AnnotationsService.class, bundle, new Handler() {
                        @Override
                        public void handleMessage(Message msg) {

                        }
                    });

                   mService.start();

                }
            }
        });

        mDoneBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.i("Marinas", "on click done button");
                if ( mService != null ) {
                    Toast.makeText(mContext, "DONE", Toast.LENGTH_SHORT).show();

                    try {
                        mService.send(Message.obtain(null, AnnotationsService.MSG_DONE));
                    } catch (RemoteException e) {
                        e.printStackTrace();
                    }
                    mService = null;
                }
            }
        });

        mEraseBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.i("Marinas", "on click erase button");
                Toast.makeText(mContext, "ERASE ITEM", Toast.LENGTH_SHORT).show();
                if ( mService != null ) {
                    try {
                        mService.send(Message.obtain(null, AnnotationsService.MSG_ERASE));
                    } catch (RemoteException e) {
                        e.printStackTrace();
                    }
                }
            }
        });
    }
}
