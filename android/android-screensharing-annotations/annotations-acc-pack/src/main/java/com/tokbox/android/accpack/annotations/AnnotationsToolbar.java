package com.tokbox.android.accpack.annotations;


import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
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

import org.w3c.dom.Text;

public class AnnotationsToolbar extends LinearLayout {

    private View rootView;
    private ImageButton mFreeHandBtn;
    private TextView mDoneBtn;
    private Context mContext;
    private Intent mIntent;
    private int viewWidth = 300;
    private int viewHeight = 400;

    public AnnotationsToolbar(Context context) {
        super(context);
        mContext = context;

        WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        Display display = wm.getDefaultDisplay();

        viewWidth = display.getWidth();
        viewHeight = display.getHeight() - 400;

        init();
    }

    public void init(){
        rootView = inflate(mContext, R.layout.annotations_toolbar, this);
        mFreeHandBtn = (ImageButton) rootView.findViewById(R.id.draw_freehand);
        mDoneBtn = (TextView) rootView.findViewById(R.id.done);

        mFreeHandBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.i("Marinas", "on click freehand button");
                Toast.makeText(mContext, "HOLA HOLA", Toast.LENGTH_SHORT).show();

                if ( mIntent == null ) {
                    Bundle bundle = new Bundle();
                    bundle.putInt("view_width", viewWidth);
                    bundle.putInt("view_height", viewHeight);
                    mIntent = new Intent(mContext, AnnotationsService.class);
                    mIntent.putExtras(bundle);
                    mContext.startService(mIntent);
                }
            }
        });

        mDoneBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.i("Marinas", "on click done button");
                if ( mIntent != null ) {
                    Toast.makeText(mContext, "DONE", Toast.LENGTH_SHORT).show();

                    mContext.stopService(mIntent);
                    mIntent = null;
                }
            }
        });
    }
}
