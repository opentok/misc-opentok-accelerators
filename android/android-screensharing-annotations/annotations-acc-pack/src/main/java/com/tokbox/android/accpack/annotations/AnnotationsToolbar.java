package com.tokbox.android.accpack.annotations;


import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.RemoteException;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Display;
import android.view.KeyEvent;
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
    private View mainToolbar;
    private LinearLayout colortToolbar;

    private AnnotationsListener mListener;

    public  interface AnnotationsListener {

        void onItemSelected(View v);

    }

    public void setListener(AnnotationsListener listener) {
        this.mListener = listener;
    }


    private OnClickListener colorClickListener = new OnClickListener() {
        @Override
        public void onClick(View v) {
            int color = getResources().getColor(R.color.picker_color_orange);

            if (v.getId() == R.id.picker_purple){
                Log.i("MARINAS", "on pickerColor PURPLE");
                color = getResources().getColor(R.color.picker_color_purple);
            }
            if (v.getId() == R.id.picker_red){
                color = getResources().getColor(R.color.picker_color_red);
                Log.i("MARINAS", "on pickerColor RED "+color);
            }
            if (v.getId() == R.id.picker_orange){
                color = getResources().getColor(R.color.picker_color_orange);
                Log.i("MARINAS", "on pickerColor ORANGE");
            }
            if (v.getId() == R.id.picker_blue){
                color = getResources().getColor(R.color.picker_color_blue);
                Log.i("MARINAS", "on pickerColor BLUE");
            }
            if (v.getId() == R.id.picker_green){
                color = getResources().getColor(R.color.picker_color_green);
                Log.i("MARINAS", "on pickerColor GREEN");
            }
            if (v.getId() == R.id.picker_white){
                color = getResources().getColor(R.color.picker_color_white);
                Log.i("MARINAS", "on pickerColor WHITE");
            }
            if (v.getId() == R.id.picker_black){
                color = getResources().getColor(R.color.picker_color_black);
                Log.i("MARINAS", "on pickerColor BLACK");
            }
            if (v.getId() == R.id.picker_yellow){
                color = getResources().getColor(R.color.picker_color_yellow);
                Log.i("MARINAS", "on pickerColor YELLOW");
            }


            /*if ( mService == null ) {
                Bundle bundle = new Bundle();
                bundle.putInt("view_width", viewWidth);
                bundle.putInt("view_height", viewHeight);
                bundle.putString("mode", AnnotationsView.Mode.Text.toString());
                mService = new ServiceManager(getContext(), AnnotationsService.class, bundle, mToolbarHandler);

                mService.start();
            }*/
        }
    };
    public AnnotationsToolbar(Context context) {
        super(context);
        mContext = context;

        WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        Display display = wm.getDefaultDisplay();

        init();
    }

    public AnnotationsToolbar(Context context, AttributeSet attrs) {
        super(context, attrs);
        mContext = context;

        WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        Display display = wm.getDefaultDisplay();

        init();
    }

    public void init() {
        rootView = inflate(mContext, R.layout.annotations_toolbar, this);
        mainToolbar = (View) rootView.findViewById(R.id.main_toolbar);

        colortToolbar = (LinearLayout) rootView.findViewById(R.id.color_toolbar);

        mFreeHandBtn = (ImageButton) mainToolbar.findViewById(R.id.draw_freehand);
        mPickerColorBtn = (ImageButton) mainToolbar.findViewById(R.id.picker_color);
        mTypeBtn = (ImageButton) mainToolbar.findViewById(R.id.type_tool);
        mEraseBtn = (ImageButton) mainToolbar.findViewById(R.id.erase);
        mDoneBtn = (TextView) mainToolbar.findViewById(R.id.done);

        final int mCount = colortToolbar.getChildCount();

        // Loop through all of the children.
        for (int i = 0; i < mCount; ++i) {
            colortToolbar.getChildAt(i).setOnClickListener(colorClickListener);
        }

        //Init actions
        mFreeHandBtn.setOnClickListener(mActionListener);
        mTypeBtn.setOnClickListener(mActionListener);
        mEraseBtn.setOnClickListener(mActionListener);
        mDoneBtn.setOnClickListener(mActionListener);
    }

    private OnClickListener mActionListener = new OnClickListener() {
        @Override
        public void onClick(View v) {
            Log.i("MARINAS", "ONCLICK BUTTON TOOLBAR");
            if ( mListener != null ){
                Log.i("MARINAS", "ONCLICK BUTTON TOOLBAR LISTENER !=NULL");

                mListener.onItemSelected(v);
            }
        }
    };

}
