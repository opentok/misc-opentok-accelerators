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
 * Defines a view to represent the ScreenSharingBar.
 *
 */
public class ScreenSharingBar extends RelativeLayout{

    private TextView mTextView;
    private ImageButton mCloseBtn;
    private ScreenSharingBarListener mListener;

    /*
     * Constructor.
     * @param context Application context
     * @param listener ScreenSharingBarListener
     */
    public ScreenSharingBar(Context context, ScreenSharingBarListener listener) {
        super(context);

        this.mListener = listener;
        this.setBackgroundColor(getResources().getColor(R.color.screensharing_bar));

        mCloseBtn = new ImageButton(context);
        mCloseBtn.setImageDrawable(getResources().getDrawable(R.drawable.close));

        mCloseBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
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

    /**
     * Monitors state changes in the Screensharing Bar.
     *
     */
    public static interface ScreenSharingBarListener {

        /**
         * Invoked when Close button is clicked.
         *
         */
        public void onClose();
    }

}
