package com.tokbox.android.annotations;

import android.graphics.Path;
import android.graphics.Point;
import android.graphics.PointF;

import java.util.ArrayList;
import java.util.UUID;

public class AnnotationsPath extends Path {

    private UUID id;

    private PointF currentPoint;
    private PointF startPoint;
    private PointF endPoint;
    private ArrayList<PointF> points; private PointF lastPoint;

    public PointF getLastPointF() {
        return lastPoint;
    }

    public void setLastPointF(PointF lastPoint) {
        this.lastPoint = lastPoint;
    }

    public AnnotationsPath() {
        this.id = UUID.randomUUID();
        this.points = new ArrayList<PointF>();
    }

    public void setStartPoint(PointF startPoint) {
        this.startPoint = startPoint;
    }

    public void setEndPoint(PointF endPoint) {
        this.endPoint = endPoint;
    }

    public UUID getId() {
        return id;
    }

    public PointF getStartPoint() {
        return startPoint;
    }

    public PointF getEndPoint() {
        return endPoint;
    }

    public void addPoint(PointF point) {
        if ( points.size() == 0 ){
            startPoint = point;
        }
        points.add(point);
        endPoint = point;
    }

    public ArrayList<PointF> getPoints() {
        return points;
    }
}

