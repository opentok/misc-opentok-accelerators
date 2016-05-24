package com.tokbox.android.accpack.annotations;


import android.content.Context;
import android.view.View;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.Toast;

public class AnnotationsToolbar extends LinearLayout {

    View rootView;
    ImageButton mFreeHandBtn;
    Context mContext;

    public AnnotationsToolbar(Context context) {
        super(context);
        mContext = context;
        init();
    }

    public void init(){
        rootView = inflate(mContext, R.layout.annotations_toolbar, this);
        mFreeHandBtn = (ImageButton) rootView.findViewById(R.id.draw_freehand);

        mFreeHandBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Toast.makeText(mContext, "HOLA HOLA", Toast.LENGTH_SHORT).show();
            }
        });
    }
}
