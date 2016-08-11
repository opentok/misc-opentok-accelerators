package com.tokbox.android.annotations;

import android.graphics.Paint;
import android.util.Log;
import android.view.View;
import android.widget.EditText;

import java.util.UUID;

public class AnnotationsText implements View.OnClickListener{

    private UUID id;
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
        this.id = UUID.randomUUID();
        this.editText = editText;
        this.x = x;
        this.y = y;
    }

    public UUID getId() {
        return id;
    }

    @Override
    public void onClick(View v) {

    }

    public EditText getEditText() {
        return editText;
    }
}
