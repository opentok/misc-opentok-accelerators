package com.tokbox.android.accpack.screensharing;


import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PathMeasure;
import android.graphics.Point;
import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.ColorDrawable;
import android.os.Handler;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.opentok.android.Connection;
import com.opentok.android.Publisher;
import com.opentok.android.Session;
import com.opentok.android.Subscriber;
import com.tokbox.android.accpack.screensharing.annotations.toolbar.AnnotationMenuView;
import com.tokbox.android.accpack.screensharing.annotations.toolbar.AnnotationPath;
import com.tokbox.android.accpack.screensharing.annotations.toolbar.AnnotationText;
import com.tokbox.android.accpack.screensharing.annotations.toolbar.AnnotationToolbar;
import com.tokbox.android.accpack.screensharing.annotations.toolbar.AnnotationToolbarItem;
import com.tokbox.android.accpack.screensharing.annotations.toolbar.AnnotationToolbarMenuItem;
import com.tokbox.android.accpack.screensharing.annotations.toolbar.FloatPoint;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class AnnotationView extends View implements AnnotationToolbar.SignalListener, AnnotationToolbar.ActionListener {

    private static final String TAG = "ot-annotations-canvas";

    private String mycid;
    private String canvascid;

    private String mSessionId;
    private String mPartnerId;

    public int width;
    public int height;
    private Bitmap mBitmap;
    // TODO Merge these lists so that they can be used for history (undo)
    private List<AnnotationPath> mPaths;
    private List<AnnotationText> mLabels;
    private float mX, mY;
    private float mLastX, mLastY;
    private float mStartX, mStartY;
    private static final float TOLERANCE = 5;

    boolean isStartPoint = false;

    private boolean mMirrored = false;
    private boolean mSignalMirrored = false;

    /**
     * Indicates if you are drawing
     */
    private boolean isDrawing = false;

    // TODO May include this as optional ability to control whether shapes can be scaled or should be "stamped" as is
    private boolean allowsSizing = false;

    private AnnotationToolbar toolbar;

    private int selectedResourceId = -1;
    private AnnotationToolbarItem selectedItem;


    @Override
    public void onAnnotationItemSelected(AnnotationToolbarItem item) {
        // TODO Include a boolean as part of the AnnotationToolbarItem class to handle persistent selection state?
        // TODO If the item is not persistent (they should be persistent by default), the user is responsible for handling
        // TODO the click event and selectedItem is never updated to retain the selection
        if (item.getColor() != null) {
            int color = Color.parseColor(item.getColor());
            setAnnotationColor(color);
        } else {
            // We don't have a color selection
            if (item.getItemId() == R.id.ot_item_clear) {
                clearCanvas(false, mycid);
                if (mSubscriber != null) {
                    mSubscriber.getSession().sendSignal(Mode.Clear.toString(), null);
                } else if (mPublisher != null) {
                    mPublisher.getSession().sendSignal(Mode.Clear.toString(), null);
                } else {
                    throw new IllegalStateException("A publisher or subscriber must be passed into the class. " +
                            "See attachSubscriber() or attachPublisher().");
                }
            } else if (item.getTag() != null && item.getTag() instanceof Float) {
                setAnnotationSize((Float) item.getTag());
            } else {
                selectedItem = item;
                selectedResourceId = item.getItemId();
            }
        }
    }

    @Override
    public boolean onCreateAnnotationMenu(AnnotationMenuView menu) {
        return false;
    }

    @Override
    public void onAnnotationMenuItemSelected(AnnotationToolbarMenuItem menuItem) {

    }

    private enum Mode {
        Pen("otAnnotation_pen"),
        Clear("otAnnotation_clear"),
        Text("otAnnotation_text");

        private String type;

        Mode(String type) {
            this.type = type;
        }

        public String toString() {
            return this.type;
        }
    }

    private Subscriber mSubscriber;
    private Publisher mPublisher;

    // Color and stroke associated with incoming annotations
    private int activeColor;
    private float activeStrokeWidth;

    // Color and stroke selected by the current user
    private int userColor;
    private float userStrokeWidth;

    /** ==== Constructors ==== **/

    public AnnotationView(Context c) {
        this(c, null);
    }

    public AnnotationView(Context c, AttributeSet attrs) {
        super(c, attrs);

        mPaths = new ArrayList<AnnotationPath>();
        mLabels = new ArrayList<AnnotationText>();

        // Default stroke and color
        userColor = activeColor = Color.RED;
        userStrokeWidth = activeStrokeWidth = 6f;
    }

    /** ==== Linkers ==== **/

    // INFO We pass in a subscriber or publisher so that the canvas can be auto scaled to match the video frame

    /**
     * Attaches an annotation canvas to the provided {@code Subscriber}.
     * @param subscriber The OpenTok {@code Subscriber}.
     */
    public void attachSubscriber(Subscriber subscriber) {
        this.setLayoutParams(subscriber.getView().getLayoutParams());
        mSubscriber = subscriber;

        new Thread() {
            @Override
            public void run() {
                while (mSubscriber.getStream() == null) { /* Wait */ }
                while (mSubscriber.getStream().getConnection() == null) { /* Wait */ }
                canvascid = mSubscriber.getStream().getConnection().getConnectionId();

                Log.i("Canvas Signal", "Subscriber: " + canvascid);

                while (mSubscriber.getSession() == null) { /* Wait */ }
                mSessionId = mSubscriber.getSession().getSessionId();
                mycid = mSubscriber.getSession().getConnection().getConnectionId();

                try {
                    Field field = mSubscriber.getSession().getClass().getDeclaredField("apiKey");
                    field.setAccessible(true);

                    mPartnerId = (String) field.get(mSubscriber.getSession());
                } catch (NoSuchFieldException e) {
                    e.printStackTrace();
                } catch (IllegalAccessException e) {
                    e.printStackTrace();
                }

                // TODO Make sure this also gets called onSizeChanged
                if (mSubscriber.getRenderer() instanceof AnnotationVideoRenderer) {
                    mMirrored = ((AnnotationVideoRenderer) mSubscriber.getRenderer()).isMirrored();
                }

                // Force a dummy signal so that we can grab the current user's cid
                Log.i("AnnotationTest", "Getting connection ID");
                sendUpdate("otAnnotationConnect", "");

                // Initialize a default path
                Log.i("AnnotationTest", "Got connection ID!");
                createPath(false, mycid);
            }
        }.start();
    }

    /**
     * Attaches an annotation canvas to the provided {@code Publisher}.
     * @param publisher The OpenTok {@code Publisher}.
     */
    public void attachPublisher(Publisher publisher) {
        if ( publisher.getView().getLayoutParams() == null ) {
            RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(
                    getResources().getDisplayMetrics().widthPixels, getResources().getDisplayMetrics().heightPixels);
            this.setLayoutParams(layoutParams);
        }
        else {
            this.setLayoutParams(publisher.getView().getLayoutParams());
        }

        mPublisher = publisher;

        new Thread() {
            @Override
            public void run() {
                while (mPublisher.getStream() == null) { /* Wait */ }
                while (mPublisher.getStream().getConnection() == null) { /* Wait */ }
                canvascid = mPublisher.getStream().getConnection().getConnectionId();

                Log.i("Canvas Signal", "Publisher: " + canvascid);

//                // TODO Make sure this also gets called onSizeChanged
                if (mPublisher.getRenderer() instanceof AnnotationVideoRenderer) {
                    mMirrored = ((AnnotationVideoRenderer) mPublisher.getRenderer()).isMirrored();
                }

                // Initialize a default path
                createPath(false, canvascid);
            }
        }.start();

//        mPublisher.setRenderer(new AnnotationVideoRenderer(getContext()));
    }

    /**
     * Attaches an {@code AnnotationToolbar} to the current {@code AnnotationView}.
     * Note: The same {@code AnnotationToolbar} should be reused for all {@code AnnotationView}s in
     * a visible view.
     * @param toolbar The {@code AnnotationToolbar} to be attached.
     */
    public void attachToolbar(AnnotationToolbar toolbar) {
        Log.i(TAG, "Attaching toolbar");
        this.toolbar = toolbar;
        this.toolbar.addSignalListener(this);
        this.toolbar.addActionListener(this);
        this.toolbar.bringToFront();

        if (this.toolbar.getSelectedItem() != null) {
            this.selectedItem = this.toolbar.getSelectedItem();
        }
    }

    /** ==== Public Getters/Setters ==== **/

    /**
     * Allows the color of the annotations to be manually changed.
     * @param color The integer representation of the color.
     */
    public void setAnnotationColor(int color) {
        userColor = color;
        createPath(false, mycid); // Create a new paint object to allow for color change
    }

    /**
     * Sets the line width for annotations.
     * @param width The line width (dp).
     */
    public void setAnnotationSize(float width) {
        userStrokeWidth = width;
        createPath(false, mycid); // Create a new paint object to allow for new stroke size
    }

    /** ==== Private Getters/Setters ==== **/

    /**
     * Changes the color of incoming annotations (set by the signal string).
     * @param color The integer representation of the color.
     */
    private void changeColor(int color, String cid) {
        activeColor = color;
        createPath(true, cid); // Create a new path/paint object to allow for color change
    }

    /**
     * Sets the line width for incoming annotations (set by the signal string).
     * @param width The line width (dp).
     */
    private void changeStrokeWidth(float width, String cid) {
        activeStrokeWidth = width;
        createPath(true, cid); // Create a new path/paint object to allow for new stroke size
    }

    /**
     * Gets the active paint object from the list.
     * @return The active {@code Paint}.
     */
    private Paint getActivePaint() {
        return mPaths.get(mPaths.size()-1).paint;
    }

    /**
     * Gets the active path from the list.
     * @return The active {@code Path}.
     */
    private Path getActivePath() {
        return mPaths.get(mPaths.size()-1).path;
    }

    /** ==== Signal Handling ==== **/

    @Override
    public void signalReceived(Session session, String type, String data, Connection connection) {
//        Log.i("Canvas Signal", type + ": " + data);

        mycid = session.getConnection().getConnectionId();
        String cid = connection.getConnectionId();

//        Log.i("Canvas Signal", cid);
        if (!cid.equals(mycid)) { // Ensure that we only handle signals from other users on the current canvas
            if (type.contains("otAnnotation")) {
                if (type.equalsIgnoreCase(Mode.Pen.toString())) {
//                    Log.i(TAG, data);

                    // Build object from JSON array
                    try {
                        JSONArray updates = new JSONArray(data);

                        for(int i = 0; i < updates.length(); i++) {
                            JSONObject json = updates.getJSONObject(i);

                            String id = (String) json.get("id");
                            if (canvascid.equals(id)) {
                                if (json.get("mirrored") instanceof Number) {
                                    Number value = (Number) json.get("mirrored");
                                    mSignalMirrored = value.intValue() == 1;
                                } else {
                                    mSignalMirrored = (boolean) json.get("mirrored");
                                }

                                boolean initialPoint = false;
                                boolean secondPoint = false;
                                boolean endPoint = false;

                                if (json.get("endPoint") != null) {
                                    if (json.get("endPoint") instanceof Number) {
                                        Number value = (Number) json.get("endPoint");
                                        endPoint = value.intValue() == 1;
                                    } else {
                                        endPoint = (boolean) json.get("endPoint");
                                    }
                                }

                                if (json.get("startPoint") != null) {
                                    if (json.get("startPoint") instanceof Number) {
                                        Number value = (Number) json.get("startPoint");
                                        initialPoint = value.intValue() == 1;
                                    } else {
                                        initialPoint = (boolean) json.get("startPoint");
                                    }

                                    if (initialPoint) {
                                        changeColor(Color.parseColor(((String) json.get("color")).toLowerCase()), cid);
                                        changeStrokeWidth(((Number) json.get("lineWidth")).floatValue(), cid);
                                        isStartPoint = true;
                                    } else {
                                        // If the start point flag was already set, we received the next point in the sequence
                                        if (isStartPoint) {
                                            secondPoint = true;
                                            isStartPoint = false;
                                        }
                                    }
                                } else {
                                    changeColor(Color.parseColor(((String) json.get("color")).toLowerCase()), cid);
                                    changeStrokeWidth(((Number) json.get("lineWidth")).floatValue(), cid);
                                }

                                AnnotationVideoRenderer renderer = null;

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
                                    if (canvasRatio < 0) {
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
                            }
                        }
                    } catch (JSONException e) {
                        Log.e(TAG, e.getMessage());
                    }
                } else if (type.equalsIgnoreCase(Mode.Clear.toString())) {
                    Log.i(TAG, "Clearing canvas");
                    this.clearCanvas(true, cid);
                }
            }
        }
    }

    private String buildSignalFromPoint(float x, float y, boolean startPoint, boolean endPoint) {
        JSONArray jsonArray = new JSONArray();
        JSONObject jsonObject = new JSONObject();

        boolean mirrored = false;

        int videoWidth = 0;
        int videoHeight = 0;

        AnnotationVideoRenderer renderer = null;

        if (mPublisher != null) {
            renderer = ((AnnotationVideoRenderer) mPublisher.getRenderer());
        } else if (mSubscriber != null) {
            renderer = ((AnnotationVideoRenderer) mSubscriber.getRenderer());
        }

        if (renderer != null) {
            mirrored = renderer.isMirrored();
            videoWidth = renderer.getVideoWidth();
            videoHeight = renderer.getVideoHeight();
        }

        // TODO Include a unique ID for the path?
        try {
            jsonObject.put("id", canvascid);
            jsonObject.put("fromId", mycid);
            jsonObject.put("fromX", mLastX);
            jsonObject.put("fromY", mLastY);
            jsonObject.put("toX", x);
            jsonObject.put("toY", y);
            jsonObject.put("color", String.format("#%06X", (0xFFFFFF & userColor)));
            jsonObject.put("lineWidth", userStrokeWidth);
            jsonObject.put("videoWidth", videoWidth);
            jsonObject.put("videoHeight", videoHeight);
            jsonObject.put("canvasWidth", this.width);
            jsonObject.put("canvasHeight", this.height);
            jsonObject.put("mirrored", mirrored);
            jsonObject.put("smoothed", selectedItem.isSmoothDrawEnabled());
            jsonObject.put("startPoint", startPoint);
            jsonObject.put("endPoint", endPoint);

            // TODO These need to be batched
            jsonArray.put(jsonObject);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return jsonArray.toString();
    }

    private void sendUpdate(String type, String update) {
        // Pass this through signal
        if (mSubscriber != null) {
            mSubscriber.getSession().sendSignal(type, update);
        } else if (mPublisher != null) {
            mPublisher.getSession().sendSignal(type, update);
        } else {
            throw new IllegalStateException("A publisher or subscriber must be passed into the class. " +
                    "See attachSubscriber() or attachPublisher().");
        }
    }

    /** ==== Touch Events ==== **/

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        float x = event.getX();
        float y = event.getY();

        if (selectedResourceId == R.id.ot_item_pen) {
            switch (event.getAction()) {
                case MotionEvent.ACTION_DOWN: {
                    createPath(false, mycid);
                    startTouch(x, y);
                    mLastX = x;
                    mLastY = y;

                    isStartPoint = true;

                    invalidate();
                }
                break;
                case MotionEvent.ACTION_MOVE: {
                    moveTouch(x, y, true);
                    invalidate();

                    sendUpdate(Mode.Pen.toString(), buildSignalFromPoint(x, y, isStartPoint, false));

                    isStartPoint = false;

                    mLastX = x;
                    mLastY = y;
                }
                break;
                case MotionEvent.ACTION_UP: {
                    upTouch();
                    invalidate();
                }
                break;
            }
        } else if (selectedResourceId == R.id.ot_item_capture) {

            captureView();
        } else {
            if (selectedItem != null && selectedItem.getPoints() != null) {
                mX = x;
                mY = y;
                onTouchEvent(event, selectedItem.getPoints());
            }
        }
        return true;
    }

    private void onTouchEvent(MotionEvent event, FloatPoint[] points) {
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
    }

    private void moveTouch(float x, float y, boolean curved) {
        float dx = Math.abs(x - mX);
        float dy = Math.abs(y - mY);
        if (dx >= TOLERANCE || dy >= TOLERANCE) {
            if (curved) {
                getActivePath().quadTo(mX, mY, (x + mX) / 2, (y + mY) / 2);
            } else {
                getActivePath().lineTo(x, y);
            }
            mX = x;
            mY = y;
        }
    }

    private void upTouch() {
        upTouch(false);
    }

    private void upTouch(boolean curved) {
        if (curved) {
            getActivePath().quadTo(mLastX, mLastY, (mX + mLastX) / 2, (mY + mLastY) / 2);
        } else {
            getActivePath().lineTo(mX, mY);
        }
    }

    /** ==== Canvas Events ==== **/

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);

        this.width = w;
        this.height = h;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        for (AnnotationPath drawing : mPaths) {
            canvas.drawPath(drawing.path, drawing.paint);
        }

        for (AnnotationText label : mLabels) {
            canvas.drawText(label.text, label.x, label.y, label.paint);
        }

        if (isDrawing) {
            if (selectedItem != null && selectedItem.getPoints() != null) {
                onDrawPoints(canvas, selectedItem.getPoints(), selectedItem.isSmoothDrawEnabled());
            }
        }
    }

    private void onDrawPoints(Canvas canvas, FloatPoint[] points, boolean curved) {
        float dx = Math.abs(mX - mLastX);
        float dy = Math.abs(mY - mLastY);
        if (dx >= TOLERANCE || dy >= TOLERANCE) {
            FloatPoint scale = scaleForPoints(points);
            Path path = new Path();

            if (points.length == 2) {
                // We have a line
                path.moveTo(mStartX, mStartY);
                path.lineTo(mX, mY);
            } else {
                float lastX = -1;
                float lastY = -1;
                for (int i = 0; i < points.length; i++) {
                    // Scale the points according to the difference between the start and end points
                    float pointX = mStartX + (scale.x * points[i].x);
                    float pointY = mStartY + (scale.y * points[i].y);

                    if (curved) {
                        if (i == 0) {
                            // Do nothing
                        } else if (i == 1) {
                            path.moveTo((pointX + lastX) / 2, (pointY + lastY) / 2);
                        } else {
                            path.quadTo(lastX, lastY, (pointX + lastX) / 2, (pointY + lastY) / 2);

                            if (i == points.length-1) {
                                path.close();
                            }
                        }
                    } else {
                        if (i == 0) {
                            path.moveTo(pointX, pointY);
                        } else {
                            path.lineTo(pointX, pointY);

                            if (i == points.length-1) {
                                path.close();
                            }
                        }
                    }

                    lastX = pointX;
                    lastY = pointY;
                }
            }

            canvas.drawPath(path, getActivePaint());
        }
    }

    /**
     * Scales a path (defined by its points) based on the drag gesture by the user.
     * @param points The base points to be scaled.
     * @return A {@code FloatPoint} indicating the scales in both the x and y directions.
     */
    private FloatPoint scaleForPoints(FloatPoint[] points) {
        // mX and mY refer to the end point of the enclosing rectangle (touch up)
        float minX = Float.MAX_VALUE;
        float minY = Float.MAX_VALUE;
        float maxX = 0;
        float maxY = 0;
        for (int i = 0; i < points.length; i++) {
            if (points[i].x < minX) {
                minX = points[i].x;
            } else if (points[i].x > maxX) {
                maxX = points[i].x;
            }

            if (points[i].y < minY) {
                minY = points[i].y;
            } else if (points[i].y > maxY) {
                maxY = points[i].y;
            }
        }
        float dx = Math.abs(maxX - minX);
        float dy = Math.abs(maxY - minY);

        Log.i("AnnotationView", "Delta: " + dx + ", " + dy);

        float scaleX = (mX - mStartX) / dx;
        float scaleY = (mY - mStartY) / dy;

        Log.i("AnnotationView", "Scale: " + scaleX + ", " + scaleY);

        return new FloatPoint(scaleX, scaleY);
    }

    public void clearCanvas(boolean incoming, String cid) {
        Iterator<AnnotationPath> iter = mPaths.iterator();

        while (iter.hasNext()) {
            AnnotationPath path = iter.next();

            if (path.connectionId.equals(cid)) {
                iter.remove();
            }
        }

        if (!incoming) {
            // Send signal to clear paths with connection ID
            sendUpdate(Mode.Clear.toString(), null);
        }

        invalidate();
        createPath(false, mycid);
    }

    private void createPath(boolean incoming, String cid) {
        Paint paint = new Paint();
        paint.setAntiAlias(true);
        paint.setColor(incoming ? activeColor : userColor);
        paint.setStyle(Paint.Style.STROKE);
        paint.setStrokeJoin(Paint.Join.ROUND);
        paint.setStrokeWidth(incoming ? activeStrokeWidth : userStrokeWidth);

        if (mPublisher == null && mSubscriber == null) {
            throw new IllegalStateException("An OpenTok Publisher or Subscriber must be passed into the class. " +
                    "See AnnotationView.attachSubscriber() or AnnotationView.attachPublisher().");
        }

        mPaths.add(new AnnotationPath(new Path(), paint, cid)); // Generate a new drawing path
    }

    /** ==== View capture (screenshots) ==== **/

    public void captureView() {
        // Adds a "flash" animation to indicate the screenshot was captured
        final LinearLayout layout = new LinearLayout(getContext());
        // INFO I'm not sure how well this will always work grabbing the first child for the params...
        layout.setLayoutParams(((ViewGroup) AnnotationView.this.getParent()).getChildAt(0).getLayoutParams());
        final AnimationDrawable drawable = new AnimationDrawable();
        final Handler handler = new Handler();

        drawable.addFrame(new ColorDrawable(Color.WHITE), 150);
        drawable.addFrame(new ColorDrawable(Color.TRANSPARENT), 400);
        drawable.setExitFadeDuration(400);
        drawable.setOneShot(true);

        layout.setBackgroundDrawable(drawable);
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                drawable.start();

                // Destroy the animation
                ((ViewGroup) AnnotationView.this.getParent()).removeView(layout);
            }
        }, 100);

        ((ViewGroup) this.getParent()).addView(layout);

        try {
            boolean notSupported = false;
            // Use custom renderer to get screenshot from publisher/subscriber
            Bitmap videoFrame = null;
            if (mPublisher != null) {
                if (mPublisher.getRenderer() instanceof  AnnotationVideoRenderer) {
                    videoFrame = ((AnnotationVideoRenderer) mPublisher.getRenderer()).captureScreenshot();
                } else {
                    notSupported = true;
                }
            } else if (mSubscriber != null) {
                if (mSubscriber.getRenderer() instanceof  AnnotationVideoRenderer) {
                    videoFrame = ((AnnotationVideoRenderer) mSubscriber.getRenderer()).captureScreenshot();
                } else {
                    notSupported = true;
                }
            } else {
                Log.e("AnnotationView", "The AnnotationView is not attached to a subscriber or " +
                        "publisher. See AnnotationView.attachSubscriber() or AnnotationView.attachPublisher().");
                return;
            }

            if (notSupported) {
                Log.e("AnnotationView", "Screen capturing is not supported without using an " +
                        "AnnotationVideoRender. See the docs for details.");
                return;
            }

            if (videoFrame != null) {
                View v = ((View) this.getParent());
                v.setDrawingCacheEnabled(true);
                Bitmap annotations = v.getDrawingCache(true).copy(Bitmap.Config.ARGB_8888, false);
                v.setDrawingCacheEnabled(false);

                // Overlay the annotations on top of the video capture and store a final bitmap
                Bitmap screenshot = overlay(annotations, videoFrame);

                // Pass the screenshot bitmap through callback
                toolbar.didCaptureScreen(screenshot, canvascid);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Allows the annotations to be overlaid on top of the video frame.
     * @param overlay The annotation overlay.
     * @param underlay The annotation video frame.
     * @return The "merged" bitmap of the images.
     */
    private Bitmap overlay(Bitmap overlay, Bitmap underlay) {
        Bitmap bmOverlay = Bitmap.createBitmap(overlay.getWidth(), overlay.getHeight(), overlay.getConfig());

        // TODO Make sure the scaling is handled correctly
        double ratio;
        if (overlay.getWidth() > overlay.getHeight()) {
            ratio = (double) overlay.getWidth() / (double) underlay.getWidth();
        } else {
            ratio = (double) overlay.getHeight() / (double) underlay.getHeight();
        }

        int scaledWidth = (int) (underlay.getWidth() * ratio);
        int scaledHeight = (int) (underlay.getHeight() * ratio);

        Bitmap scaledBitmap = Bitmap.createScaledBitmap(underlay, scaledWidth, scaledHeight, false);
        Canvas canvas = new Canvas(bmOverlay);
        canvas.drawBitmap(scaledBitmap, 0, 0, null);
        canvas.drawBitmap(overlay, 0, 0, null);
        return bmOverlay;
    }

    /** ==== Misc. ==== **/

    // INFO This method shouldn't be necessary, but in case we need it...
    private Point[] getPoints(Path path) {
        Point[] pointArray = new Point[20];
        PathMeasure pm = new PathMeasure(path, false);
        float length = pm.getLength();
        float distance = 0f;
        float speed = length / 20;
        int counter = 0;
        float[] aCoordinates = new float[2];

        while ((distance < length) && (counter < 20)) {
            // get point from the path
            pm.getPosTan(distance, aCoordinates, null);
            pointArray[counter] = new Point((int)aCoordinates[0],
                    (int)aCoordinates[1]);
            counter++;
            distance = distance + speed;
        }

        return pointArray;
    }



    private String getUUID() {
        return UUID.randomUUID().toString();
    }
}