package com.tokbox.android.accpack.screensharing.annotations.toolbar;


import android.graphics.Paint;
import android.graphics.Path;

public class AnnotationPath {
    public String connectionId;
    public Paint paint;
    public Path path;

    public AnnotationPath(Path path, Paint paint, String connectionId) {
        this.path = path;
        this.paint = paint;
        this.connectionId = connectionId;
    }

    public String getConnectionId() {
        return connectionId;
    }

    public Paint getPaint() {
        return paint;
    }

    public Path getPath() {
        return path;
    }
}
