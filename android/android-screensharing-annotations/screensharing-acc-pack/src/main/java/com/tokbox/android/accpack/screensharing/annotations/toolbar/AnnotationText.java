package com.tokbox.android.accpack.screensharing.annotations.toolbar;


import android.graphics.Paint;

public class AnnotationText {
    public String text;
    public float x, y;
    public Paint paint;

    public AnnotationText(String text, float x, float y, Paint paint) {
        this.paint = paint;
        this.text = text;
        this.x = x;
        this.y = y;
    }
}
