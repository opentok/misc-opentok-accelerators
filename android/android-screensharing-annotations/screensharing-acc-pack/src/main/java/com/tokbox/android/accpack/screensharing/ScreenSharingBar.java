package com.tokbox.android.accpack.screensharing;

import android.content.Context;
import android.graphics.drawable.GradientDrawable;
import android.media.Image;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

/**
 * Created by mserrano on 25/05/16.
 */
public class ScreenSharingBar extends RelativeLayout{

    private TextView mTextView;
    private ImageButton mCloseBtn;
    private ImageButton mScreenSharingInfo;
    private ScreenSharingBarListener mListener;

    public ScreenSharingBar(Context context, ScreenSharingBarListener listener) {
        super(context);

        this.mListener = listener;
        this.setBackgroundColor(getResources().getColor(R.color.screensharing_bar));

        /* TODO: Add screensharing icon to the ss status bar
        mScreenSharingInfo = new ImageButton(context);
        mScreenSharingInfo.setImageDrawable(getResources().getDrawable(R.drawable.screensharing_info));
        mScreenSharingInfo.setBackground(null);
        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(
                LayoutParams.WRAP_CONTENT,
                LayoutParams.WRAP_CONTENT);

        params.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
        this.addView(mScreenSharingInfo, params);*/

        mCloseBtn = new ImageButton(context);
        mCloseBtn.setImageDrawable(getResources().getDrawable(R.drawable.close));

        mCloseBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.i("Marinas", "onClose in bar");
                mListener.onClose();

            }
        });
        mCloseBtn.setBackground(null);
        mCloseBtn.setClickable(true);

        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(
                LayoutParams.WRAP_CONTENT,
                LayoutParams.WRAP_CONTENT);

        params.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        this.addView(mCloseBtn, params);

        mTextView = new TextView(context);
        mTextView.setText(R.string.screensharing_text);

        params = new RelativeLayout.LayoutParams(
                LayoutParams.WRAP_CONTENT,
                LayoutParams.WRAP_CONTENT);
        params.addRule(CENTER_HORIZONTAL);
        params.addRule(CENTER_VERTICAL);

        this.addView(mTextView, params);
    }

    public static interface ScreenSharingBarListener {
        public void onClose();
    }

}
