package com.tokbox.android.accpack.annotations;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PointF;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsoluteLayout;
import android.widget.RelativeLayout;

import com.opentok.android.Connection;
import com.opentok.android.Publisher;
import com.opentok.android.Session;
import com.tokbox.android.accpack.AccPackSession;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;


public class AnnotationsView extends View implements AccPackSession.SignalListener{

    protected final String SIGNAL_TYPE = "annotations";

    private AnnotationsPath mCurrentPath;
    private Paint mCurrentPaint;
    private AnnotationsManager mAnnotationsManager;

    private float mStartX, mStartY;
    private static final float TOLERANCE = 5;

    private int width;
    private int height;


    /**
     * Indicates if you are drawing
     */
    private boolean isDrawing = false;

    protected enum Mode {
        Pen("annotation-pen"),
        Clear("annotation-clear"),
        Text("annotation-text");

        private String type;

        Mode(String type) {
            this.type = type;
        }

        public String toString() {
            return this.type;
        }
    }

    public AnnotationsView(Context context) {
        super(context);

        mAnnotationsManager = new AnnotationsManager();
    }

    public AnnotationsView(Context context, AttributeSet attrs) {
        super(context, attrs);

        mAnnotationsManager = new AnnotationsManager();
    }



    /** ==== Touch Events ==== **/

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        float x = event.getX();
        float y = event.getY();

      //  if (selectedResourceId == R.id.ot_item_pen) {
            switch (event.getAction()) {
                case MotionEvent.ACTION_DOWN: {
                   //createPath(false, mycid);
                    createAnnotatable(false);

                    beginTouch(x, y);
                    mCurrentPath.setLastPointF(new PointF(x, y));

                    mCurrentPath.setStartPoint(true);

                    invalidate();
                }
                break;
                case MotionEvent.ACTION_MOVE: {
                    moveTouch(x, y, true);
                    invalidate();

                    //marinas sendUpdate(Mode.Pen.toString(), buildSignalFromPoint(x, y, isStartPoint, false));
                    mCurrentPath.setEndPoint(false);
                    sendPathUpdate(Mode.Pen.toString());
                    mCurrentPath.setStartPoint(false);
                    mCurrentPath.setLastPointF(new PointF(x, y));

                }
                break;
                case MotionEvent.ACTION_UP: {
                    upTouch();
                    invalidate();
                }
                break;
            }
        /*} else if (selectedResourceId == R.id.ot_item_capture) {



            captureView();
        } else {
            if (selectedItem != null && selectedItem.getPoints() != null) {
                mX = x;
                mY = y;
                onTouchEvent(event, selectedItem.getPoints());
            }
        }*/
        return true;
    }

    private void beginTouch(float x, float y) {
        mCurrentPath.moveTo(x, y);
        mCurrentPath.setCurrentPoint(new PointF(x, y));
    }

    private void moveTouch(float x, float y, boolean curved) {
        float mX = mCurrentPath.getCurrentPoint().x;
        float mY = mCurrentPath.getCurrentPoint().y;

        float dx = Math.abs(x - mX);
        float dy = Math.abs(y - mY);
        if (dx >= TOLERANCE || dy >= TOLERANCE) {
            if (curved) {
                mCurrentPath.quadTo(mX, mY, (x + mX) / 2, (y + mY) / 2);
            } else {
                mCurrentPath.lineTo(x, y);
            }
            mCurrentPath.setCurrentPoint(new PointF(x, y));
        }
    }

    private void upTouch() {
        upTouch(false);
    }

    private void upTouch(boolean curved) {
        float mLastX = mCurrentPath.getLastPointF().x;
        float mLastY = mCurrentPath.getLastPointF().y;
        float mX = mCurrentPath.getCurrentPoint().x;
        float mY = mCurrentPath.getCurrentPoint().y;

        if (curved) {
            mCurrentPath.quadTo(mLastX, mLastY, (mX + mLastX) / 2, (mY + mLastY) / 2);
        } else {
            mCurrentPath.lineTo(mX, mY);
        }
    }

    private void sendPathUpdate(String mode) {

        Annotatable annotatable = new Annotatable(mode, mCurrentPath, mCurrentPaint, width, height);
        mAnnotationsManager.addAnnotatable(annotatable);
    }

    /*private void onTouchEvent(MotionEvent event, FloatPoint[] points) {
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN: {
                createPath(false, mycid);

                isDrawing = true;
                // Last x and y for shape paths is the start touch point
                mStartX = mX;
                mStartY = mY;
                invalidate();
            }
            break;
            case MotionEvent.ACTION_MOVE: {
                invalidate();
            }
            break;
            case MotionEvent.ACTION_UP: {
                isDrawing = false;

                if (points.length == 2) {
                    // We have a line
                    getActivePath().moveTo(mStartX, mStartY);
                    mLastX = mStartX;
                    mLastY = mStartY;
                    moveTouch(mX, mY, false);
                    upTouch();
                    Log.i(TAG, "Points: (" + mStartX + ", " + mStartY + "), (" + mX + ", " + mY + ")");
                    sendUpdate(Mode.Pen.toString(), buildSignalFromPoint(mX, mY, true, true));
                } else {
                    FloatPoint scale = scaleForPoints(points);

                    for (int i = 0; i < points.length; i++) {
                        boolean startPoint = false;
                        boolean endPoint = false;

                        // Scale the points according to the difference between the start and end points
                        float pointX = mStartX + (scale.x * points[i].x);
                        float pointY = mStartY + (scale.y * points[i].y);

                        if (selectedItem.isSmoothDrawEnabled()) {
                            if (i == 0) {
                                startPoint = true;
                            } else if (i == 1) {
                                getActivePath().moveTo((pointX + mLastX) / 2, (pointY + mLastY) / 2);
                            } else {
                                getActivePath().quadTo(mLastX, mLastY, (pointX + mLastX) / 2, (pointY + mLastY) / 2);

                                if (i == points.length-1) {
                                    getActivePath().close();
                                    endPoint = true;
                                }
                            }
                        } else {
                            if (i == 0) {
                                startPoint = true;
                                mLastX = pointX;
                                mLastY = pointY;
                                startTouch(pointX, pointY);
                            } else {
                                moveTouch(pointX, pointY, false);

                                if (i == points.length-1) {
                                    getActivePath().close();
                                    endPoint = true;
                                }
                            }
                        }

                        sendUpdate(Mode.Pen.toString(), buildSignalFromPoint(pointX, pointY, startPoint, endPoint));

                        mLastX = pointX;
                        mLastY = pointY;
                    }
                }

                invalidate();


            }
            break;
        }
    }

    private void startTouch(float x, float y) {
        getActivePath().moveTo(x, y);
        mX = x;
        mY = y;
    }*/


    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);

        this.width = w;
        this.height = h;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        for (Annotatable drawing: mAnnotationsManager.getAnnotatableList()){
            if (drawing.getType().equals(Annotatable.AnnotatableType.PATH)) {
                canvas.drawPath(drawing.getPath(), drawing.getPaint());
            }
        }
        /*
        for (AnnotationText label : mLabels) {
            canvas.drawText(label.text, label.x, label.y, label.paint);
        }*/

       /* if (isDrawing) {
            if (selectedItem != null && selectedItem.getPoints() != null) {
                onDrawPoints(canvas, selectedItem.getPoints(), selectedItem.isSmoothDrawEnabled());
            }
        }*/
    }

    public void setLayoutByDefault(){
        RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(
                getResources().getDisplayMetrics().widthPixels, getResources().getDisplayMetrics().heightPixels);
        this.setLayoutParams(layoutParams);
    }

    public void attachPublisher(Publisher publisher) {
        if ( publisher.getView().getLayoutParams() == null ) {
            RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(
                    getResources().getDisplayMetrics().widthPixels, getResources().getDisplayMetrics().heightPixels);
            this.setLayoutParams(layoutParams);
        }
        else {
            this.setLayoutParams(publisher.getView().getLayoutParams());
        }
        mAnnotationsManager.attachPublisher(publisher);
        //mAnnotationsManager.getSession().setSignalListener(this);
    }


    public void createAnnotatable(boolean incoming){
        mCurrentPath = new AnnotationsPath(incoming);

        mCurrentPaint = new Paint();
        mCurrentPaint.setAntiAlias(true);
        // mCurrentPaint.setColor(incoming ? activeColor : userColor);
        mCurrentPaint.setColor(Color.RED);
        mCurrentPaint.setStyle(Paint.Style.STROKE);
        mCurrentPaint.setStrokeJoin(Paint.Join.ROUND);
        //mCurrentPaint.setStrokeWidth(incoming ? activeStrokeWidth : userStrokeWidth);
        //TODO MODE

        //Annotatable annotatable = new Annotatable(Mode.Pen.toString(), path, paint, width, height);
        //mAnnotationsManager.addAnnotatable(annotatable);
    }

    @Override
    public void onSignalReceived(Session session, String type, String data, Connection connection) {
        if (mAnnotationsManager.getPublisher() == null || mAnnotationsManager.getPublisher().getSession().getConnection().getConnectionId() != connection.getConnectionId()) {
            //remote signal
            if (type.equals(SIGNAL_TYPE)) {
                //annotations signal

                try {
                    JSONArray updatedData = new JSONArray(data);
                    for (int i = 0; i < updatedData.length(); i++) {

                        //get annotatable data
                        JSONObject json = updatedData.getJSONObject(i);
                        String mode = json.getString("mode");
                        String pathId = json.getString("pathId");
                        String id = json.getString("id");
                        float fromXX = ((Number) json.get("fromX")).floatValue();
                        float fromY = ((Number) json.get("fromY")).floatValue();
                        float toX = ((Number) json.get("toX")).floatValue();
                        float toY = ((Number) json.get("toY")).floatValue();
                        String color = json.getString("color");
                        int lineWidth = json.getInt("lineWidth");
                        float videoWidth = ((Number) json.get("videoWidth")).floatValue();
                        float videoHeight = ((Number) json.get("videoHeight")).floatValue();
                        float canvasWidth = ((Number) json.get("canvasWidth")).floatValue();
                        float canvasHeight = ((Number) json.get("canvasHeight")).floatValue();
                        boolean mirrored = (boolean) json.getBoolean("mirrored");
                        boolean smoothed = (boolean) json.getBoolean("smoothed");
                        boolean startPoint = (boolean) json.getBoolean("startPoint");
                        boolean endPoint = (boolean) json.getBoolean("endPoint");


                        if (mode.equals(AnnotationsView.Mode.Pen.toString())) {
                            //pen mode


                        } else {
                            //clear mode
                            if (mode.equals(AnnotationsView.Mode.Clear.toString())) {

                                AnnotationsVideoRenderer renderer = null;
                                //TODO REVIEW IF THERE ARE 2 RENDERS
                                if (mAnnotationsManager.getPublisher() != null) {
                                    renderer = ((AnnotationsVideoRenderer) mAnnotationsManager.getPublisher().getRenderer());
                                } else if (mAnnotationsManager.getSubscriber() != null) {
                                    renderer = ((AnnotationsVideoRenderer) mAnnotationsManager.getSubscriber().getRenderer());
                                }
                                if (renderer != null) {
                                    // Handle scale
                                    float scale = 1;

                                    Map<String, Float> canvas = new HashMap<>();
                                    canvas.put("width", (float) this.width);
                                    canvas.put("height", (float) this.height);

                                    Map<String, Float> video = new HashMap<>();
                                    video.put("width", (float) renderer.getVideoWidth());
                                    video.put("height", (float) renderer.getVideoHeight());

                                    Map<String, Float> iCanvas = new HashMap<>();
                                    iCanvas.put("width", canvasWidth);
                                    iCanvas.put("height", canvasHeight);

                                    Map<String, Float> iVideo = new HashMap<>();
                                    iVideo.put("width", videoWidth);
                                    iVideo.put("height", videoHeight);

                                    float canvasRatio = canvas.get("width") / canvas.get("height");
                                    float videoRatio = video.get("width") / video.get("height");
                                    float iCanvasRatio = iCanvas.get("width") / iCanvas.get("height");
                                    float iVideoRatio = iVideo.get("width") / iVideo.get("height");


                                }

                                /*AnnotationVideoRenderer renderer = null;

                                if (mPublisher != null) {
                                    renderer = ((AnnotationVideoRenderer) mPublisher.getRenderer());
                                } else if (mSubscriber != null) {
                                    renderer = ((AnnotationVideoRenderer) mSubscriber.getRenderer());
                                }

                                if (renderer != null) {
                                    // Handle scale
                                    float scale = 1;

                                    Map<String, Float> canvas = new HashMap<>();
                                    canvas.put("width", (float) this.width);
                                    canvas.put("height", (float) this.height);

                                    Map<String, Float> video = new HashMap<>();
                                    video.put("width", (float) renderer.getVideoWidth());
                                    video.put("height", (float) renderer.getVideoHeight());

                                    Map<String, Float> iCanvas = new HashMap<>();
                                    iCanvas.put("width", ((Number) json.get("canvasWidth")).floatValue());
                                    iCanvas.put("height", ((Number) json.get("canvasHeight")).floatValue());

                                    Map<String, Float> iVideo = new HashMap<>();
                                    iVideo.put("width", ((Number) json.get("videoWidth")).floatValue());
                                    iVideo.put("height", ((Number) json.get("videoHeight")).floatValue());

//                                    Log.i("CanvasOffset", "Sizes ["
//                                            + " Canvas: " + canvas.get("width") + ", " + canvas.get("height")
//                                            + " Video: " + video.get("width") + ", " + video.get("height")
//                                            + " iCanvas: " + iCanvas.get("width") + ", " + iCanvas.get("height")
//                                            + " iVideo: " + iVideo.get("width") + ", " + iVideo.get("height") + " ]");

                                    float canvasRatio = canvas.get("width") / canvas.get("height");
                                    float videoRatio = video.get("width") / video.get("height");
                                    float iCanvasRatio = iCanvas.get("width") / iCanvas.get("height");
                                    float iVideoRatio = iVideo.get("width") / iVideo.get("height");

                                    /**
                                     * This assumes that if the width is the greater value, video frames
                                     * can be scaled so that they have equal widths, which can be used to
                                     * find the offset in the y axis. Therefore, the offset on the x axis
                                     * will be 0. If the height is the greater value, the offset on the y
                                     * axis will be 0.
                                     */
                             /*       if (canvasRatio < 0) {
                                        scale = canvas.get("width") / iCanvas.get("width");
                                    } else {
                                        scale = canvas.get("height") / iCanvas.get("height");
                                    }

                                    Log.i("CanvasOffset", "Scale: " + scale);

                                    // FIXME If possible, the scale should also scale the line width (use a min width value?)

                                    float centerX = canvas.get("width") / 2;
                                    float centerY = canvas.get("height") / 2;

                                    float iCenterX = iCanvas.get("width") / 2;
                                    float iCenterY = iCanvas.get("height") / 2;

                                    float fromX = centerX - (scale * (iCenterX - ((Number) json.get("fromX")).floatValue()));
                                    float fromY = centerY - (scale * (iCenterY - ((Number) json.get("fromY")).floatValue()));

                                    float toX = centerX - (scale * (iCenterX - ((Number) json.get("toX")).floatValue()));
                                    float toY = centerY - (scale * (iCenterY - ((Number) json.get("toY")).floatValue()));

                                    Log.i("CanvasOffset", "From: " + fromX + ", " + fromY);
                                    Log.i("CanvasOffset", "To: " + toX + ", " + toY);

                                    if (mSignalMirrored) {
                                        Log.i("CanvasOffset", "Signal is mirrored");
                                        fromX = this.width - fromX;
                                        toX = this.width - toX;
                                    }

                                    if (mMirrored) {
                                        Log.i("CanvasOffset", "Feed is mirrored");
                                        // Revert (Double negative)
                                        fromX = this.width - fromX;
                                        toX = this.width - toX;
                                    }

                                    boolean smoothed = false;

                                    Log.i("CanvasOffset", isStartPoint ? "Start point found" : "Other point found");

                                    if (json.get("smoothed") != null) {
                                        if (json.get("smoothed") instanceof Number) {
                                            Number value = (Number) json.get("smoothed");
                                            smoothed = value.intValue() == 1;
                                        } else {
                                            smoothed = (boolean) json.get("smoothed");
                                        }
                                    }

                                    if (smoothed) {
                                        if (isStartPoint) {
                                            mLastX = toX;
                                            mLastY = toY;
                                        } else if (secondPoint) {
                                            startTouch((toX + mLastX) / 2, (toY + mLastY) / 2);
                                        } else {
                                            mX = fromX;
                                            mY = fromY;
                                            moveTouch(toX, toY, true);
                                        }
                                    } else {
                                        if (isStartPoint && endPoint) {
                                            // We have a straight line
                                            startTouch(fromX, fromY);
                                            moveTouch(toX, toY, false);
                                            upTouch();
                                        } else if (isStartPoint) {
                                            startTouch(fromX, fromY);
                                        } else if (endPoint) {
                                            getActivePath().close();
                                        } else {
                                            moveTouch(toX, toY, false);
                                            upTouch();
                                        }
                                    }

                                    invalidate(); // Need this to finalize the drawing on the screen
                                }
                            }*/

                            }
                        }
                    }//for

                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
