package com.tokbox.android.accpack.annotations;

import android.graphics.Paint;
import android.util.Log;
import android.view.View;
import android.widget.EditText;

public class AnnotationsText implements View.OnClickListener{


    EditText editText;

    public float getX() {
        return x;
    }

    public float getY() {
        return y;
    }

    //String text;
    float x, y;

    AnnotationsText(EditText editText, float x, float y) {
        this.editText = editText;
        this.x = x;
        this.y = y;
    }

    @Override
    public void onClick(View v) {
        Log.i("MARINAS", "ONCLICK ANNOTATIONSTEXT");
    }

    public EditText getEditText() {
        return editText;
    }
}
