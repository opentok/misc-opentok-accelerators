package com.tokbox.android.accpack.screensharing.annotations.toolbar;


class AnnotationShapes {

    public static FloatPoint[] linePoints = {
            new FloatPoint(0, 0),
            new FloatPoint(0, 1)
    };

    public static FloatPoint[] arrowPoints = {
            new FloatPoint(0, 1),
            new FloatPoint(3, 1),
            new FloatPoint(3, 0),
            new FloatPoint(5, 2),
            new FloatPoint(3, 4),
            new FloatPoint(3, 3),
            new FloatPoint(0, 3),
            new FloatPoint(0, 1) // Reconnect point
    };

    public static FloatPoint[] rectanglePoints = {
            new FloatPoint(0, 0),
            new FloatPoint(1, 0),
            new FloatPoint(1, 1),
            new FloatPoint(0, 1),
            new FloatPoint(0, 0)
    };

    public static FloatPoint[] circlePoints = {
            new FloatPoint(0, 0.5f),
            new FloatPoint(0.5f + 0.5f*(float)Math.cos(5*Math.PI/4), 0.5f + 0.5f*(float)Math.sin(5*Math.PI/4)),
            new FloatPoint(0.5f, 0),
            new FloatPoint(0.5f + 0.5f*(float)Math.cos(7*Math.PI/4), 0.5f + 0.5f*(float)Math.sin(7*Math.PI/4)),
            new FloatPoint(1, 0.5f),
            new FloatPoint(0.5f + 0.5f*(float)Math.cos(Math.PI/4), 0.5f + 0.5f*(float)Math.sin(Math.PI/4)),
            new FloatPoint(0.5f, 1),
            new FloatPoint(0.5f + 0.5f*(float)Math.cos(3*Math.PI/4), 0.5f + 0.5f*(float)Math.sin(3*Math.PI/4)),
            new FloatPoint(0, 0.5f),
            // We need one extra to close this loop
            new FloatPoint(0.5f + 0.5f*(float)Math.cos(5*Math.PI/4), 0.5f + 0.5f*(float)Math.sin(5*Math.PI/4))
    };
}
