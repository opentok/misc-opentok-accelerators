package com.tokbox.android.annotations;


import android.graphics.Paint;

import java.util.UUID;

public class Annotatable {

    private String mode;
    private String data;

    private String cid;
    private AnnotatableType type;
    private AnnotationsPath path;

    private AnnotationsText text;
    private Paint paint;


    private int canvasWidth;
    private int canvasHeight;

    public Paint getPaint() {
        return paint;
    }

    public static enum AnnotatableType {
        PATH,
        TEXT
    }

    public Annotatable(String mode, AnnotationsPath path, Paint paint, int canvasWidth, int canvasHeight, String cid) {
        this.cid = cid;
        this.mode = mode;
        this.path = path;
        this.canvasWidth = canvasWidth;
        this.canvasHeight = canvasHeight;
        this.paint = paint;
    }

    public Annotatable(String mode, AnnotationsText text, Paint paint, int canvasWidth, int canvasHeight, String cid) {
        this.cid = cid;
        this.mode = mode;
        this.text = text;
        this.canvasWidth = canvasWidth;
        this.canvasHeight = canvasHeight;
        this.paint = paint;
    }

    public void setMode(String mode){
        this.mode = mode;
    }
    public void setData(String data){
        this.data = data;
    }

    public String getMode() {
        return mode;
    }

    public String getData() {
        return data;
    }

    public AnnotationsPath getPath() {
        return path;
    }

    public void setType(AnnotatableType type) {
        this.type = type;
    }

    public int getCanvasWidth() {
        return canvasWidth;
    }

    public int getCanvasHeight() {
        return canvasHeight;
    }

    public AnnotatableType getType() {
        return type;
    }

    public String getCId() {
        return cid;
    }

    public AnnotationsText getText() {
        return text;
    }

}

