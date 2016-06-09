package com.tokbox.android.accpack.annotations;

import android.app.Activity;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PointF;
import android.graphics.Rect;
import android.support.v4.content.ContextCompat;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.AbsoluteLayout;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.opentok.android.Connection;
import com.opentok.android.Publisher;
import com.opentok.android.Session;
import com.opentok.android.VideoUtils;
import com.tokbox.android.accpack.AccPackSession;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.UUID;


public class AnnotationsView extends ViewGroup implements AccPackSession.SignalListener, AnnotationsToolbar.AnnotationsListener{

    protected final String SIGNAL_TYPE = "annotations";

    private AnnotationsPath mCurrentPath = null;
    private AnnotationsText mCurrentText = null;
    private Paint mCurrentPaint;


    private int mCurrentColor = Color.BLACK;
    private AnnotationsManager mAnnotationsManager;

    private float mStartX, mStartY;
    private static final float TOLERANCE = 5;

    private int width;
    private int height;

    private Mode mode;

    private AnnotationsToolbar mToolbar;
    /**
     * Indicates if you are drawing
     */
    private boolean isDrawing = false;

    public enum Mode {
        Pen("annotation-pen"),
        Clear("annotation-clear"),
        Text("annotation-text"),
        Shape("annotation-shape"),
        Capture("annotation-capture");

        private String type;

        Mode(String type) {
            this.type = type;
        }

        public String toString() {
            return this.type;
        }
    }


    public void setColor(int color) {
        this.mCurrentColor = color;
    }

    public void setMode(String mode) {
        if (mode.equals(Mode.Pen.toString())){
            this.mode = Mode.Pen;
        }
        else {
            if (mode.equals(Mode.Text.toString())){
                this.mode = Mode.Text;
            }
        }

    }

    public AnnotationsView(Context context) {
        super(context);
        setWillNotDraw(false);
        mAnnotationsManager = new AnnotationsManager();
    }

    public AnnotationsView(Context context, AttributeSet attrs) {
        super(context, attrs);
        setWillNotDraw(false);
        mAnnotationsManager = new AnnotationsManager();
    }
    public void setLayoutParams(RelativeLayout.LayoutParams params){
        this.setLayoutParams(params);

    }
    /** ==== Touch Events ==== **/

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        Log.i("MARINAS", "onInterceptTouchEvent");
        return true;
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {

    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        final float x = event.getX();
        final float y = event.getY();

        if ( mode == Mode.Pen ) {
            switch (event.getAction()) {
                case MotionEvent.ACTION_DOWN: {
                    createAnnotatable(false);
                    mCurrentPath.setLastPointF(new PointF(x, y));
                    mCurrentPath.setStartPoint(true);
                    beginTouch(x, y);
                    //invalidate();
                }
                break;
                case MotionEvent.ACTION_MOVE: {
                    moveTouch(x, y, true);

                    //marinas sendUpdate(Mode.Pen.toString(), buildSignalFromPoint(x, y, isStartPoint, false));
                    mCurrentPath.setEndPoint(false);
                   // sendPathUpdate(mode.toString());
                    mCurrentPath.setStartPoint(false);
                    mCurrentPath.setLastPointF(new PointF(x, y));
                    //createAnnotatable(false);

                    //invalidate();


                }
                break;
                case MotionEvent.ACTION_UP: {
                    upTouch();
                    addAnnotatable();
                    invalidate();
                }
                break;
                }
            }
            else {
                if ( mode == Mode.Text){
                    Log.i("MARINAS", "MODE TEXT");
                    final String myString;

                   // if (mCurrentText == null ) {
                        Log.i("MARINAS", "mCurrentText != null");
                     EditText   editText = new EditText(getContext());
                    editText.setVisibility(VISIBLE);
                    //editText.setSingleLine();
                    editText.setImeOptions(EditorInfo.IME_ACTION_DONE);
                    //editText.setText();
                    editText.requestFocus();
                        editText.setWidth(180);
                        editText.setInputType(2);
                        editText.setBackgroundColor(getResources().getColor(R.color.done_btn));

                    // Add whatever you want as size
                    int editTextHeight = 70;
                    int editTextWidth = 200;

                    RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(editTextWidth, editTextHeight);

                    //You could adjust the position
                    params.topMargin = (int) (event.getRawY());
                    params.leftMargin = (int) (event.getRawX());
                    this.addView(editText, params);
                    editText.requestFocus();
                       // InputMethodManager imm = (InputMethodManager)getContext().getSystemService(getContext().INPUT_METHOD_SERVICE);
                       // imm.toggleSoftInput(InputMethodManager.SHOW_FORCED, InputMethodManager.HIDE_IMPLICIT_ONLY);

                        mCurrentText = new AnnotationsText(editText, x, y);
                        createAnnotatable(false);
                        invalidate();
                   /* }
                    else {
                        checkTextPosition(x,y);
                    }*/
                    /*editText.addTextChangedListener(new TextWatcher() {
                        @Override
                        public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                            editText.setVisibility(View.INVISIBLE); //Optional
                        }

                        @Override
                        public void onTextChanged(CharSequence s, int start, int before, int count) {
                        }

                        @Override
                        public void afterTextChanged(Editable s) {
                           //editText.getText().toString(); //Here you will get what you want
                        }

                    });*/
                    mCurrentText.getEditText().setOnClickListener(new OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            Log.i("MARINAS", "click label");
                        }
                    });
                    mCurrentText.getEditText().addTextChangedListener(new TextWatcher() {
                        public void onTextChanged(CharSequence s, int start, int before, int count) {
                            Log.i("MARINAS", "UPDATE CANVAS");
                            //updateCanvas(); // Call the canvas update
                        }
                        public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                        }
                        public void afterTextChanged(Editable s) {
                        }
                    });
                    mCurrentText.getEditText().setOnEditorActionListener(new TextView.OnEditorActionListener() {
                        @Override
                        public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                            Log.i("MARINAS", "EDITOR ACTION");

                            if (actionId == EditorInfo.IME_ACTION_DONE) {
                                InputMethodManager imm = (InputMethodManager) v.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
                                imm.hideSoftInputFromWindow(v.getWindowToken(), 0);
                                Log.i("MARINAS", "TEXT DONE: "+mCurrentText.getEditText().getText().toString());
                               // mCurrentText = new AnnotationsText(editText.getText().toString(), x, y);

                                createAnnotatable(false);
                                return true;
                            }
                            return false;
                        }
                    });
                }
                else{
                    if (mode == Mode.Capture) {


                    }else {
                        if (mode == Mode.Shape){

                        }
                    }
                }

           // captureView();
        }
        return true;
    }

    private boolean checkTextPosition(float x, float y) {
        boolean samePosition = false;

        for (Annotatable annotatable : mAnnotationsManager.getAnnotatableList()) {
            if (annotatable.getType().equals(Annotatable.AnnotatableType.TEXT)){
                if ( x >= annotatable.getText().getX() || x <= annotatable.getText().getEditText().getWidth()){
                    Log.i("MARINAS", "SAME POSITION");
                    samePosition = true;
                }
            }
        }
        return  samePosition;
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

    public void clearCanvas() {
        if ( mAnnotationsManager.getAnnotatableList().size() > 0 ) {
            int lastItem = mAnnotationsManager.getAnnotatableList().size()-1;
            UUID lastId =  mAnnotationsManager.getAnnotatableList().get(lastItem).getPath().getId();
            for (int i = (mAnnotationsManager.getAnnotatableList().size()-1); i >=0; i--) {
                Annotatable annotatable = mAnnotationsManager.getAnnotatableList().get(i);

                if (annotatable.getPath().getId().equals(lastId)){
                    annotatable.getPath().reset();
                    mAnnotationsManager.getAnnotatableList().remove(i);
                }
            }
            invalidate();
        }
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);

        this.width = w;
        this.height = h;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        Log.i("MARINAS", "annotatable list " + mAnnotationsManager.getAnnotatableList().size());

        for (Annotatable drawing: mAnnotationsManager.getAnnotatableList()){
            if (drawing.getType().equals(Annotatable.AnnotatableType.PATH)) {
                canvas.drawPath(drawing.getPath(), drawing.getPaint());
            }

            if (drawing.getType().equals(Annotatable.AnnotatableType.TEXT)){
                Log.i("MARINAS", "RECTANGLE x "+(int)drawing.getText().getX());
                Log.i("MARINAS", "RECTANGLE y "+(int)drawing.getText().getY());

                //if (drawing.getText().getEditText().getText().toString().isEmpty()){
               /*     Rect rectangle = new Rect((int)drawing.getText().getX(), (int)drawing.getText().getY(), 200, 200);
                    Paint paint = new Paint();
                    paint.setColor(Color.GRAY);
                    canvas.drawRect(rectangle, paint);
*/
                int x = 50;
                int y = 250;
                int sideLength = 200;

                // create a rectangle that we'll draw later
                Rect rectangle = new Rect(x, y, 500, 200);

                // create the Paint and set its color
                Paint paint = new Paint();
                paint.setColor(Color.GRAY);
                //canvas.drawColor(Color.BLUE);
                canvas.drawRect(rectangle, paint);
                //}
                //canvas.drawText(drawing.getText().getEditText().getText().toString(), drawing.getText().x, drawing.getText().y, drawing.getPaint());
            }
        }
        if (mAnnotationsManager.getAnnotatableList().size() == 0 ){
            canvas.drawColor(Color.TRANSPARENT);
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
        Log.i("MARINAS", "Create annotatable");
        mCurrentPaint = new Paint();
        mCurrentPaint.setAntiAlias(true);
        // mCurrentPaint.setColor(incoming ? activeColor : userColor);
        mCurrentPaint.setColor(mCurrentColor);
        mCurrentPaint.setStyle(Paint.Style.STROKE);
        mCurrentPaint.setStrokeJoin(Paint.Join.ROUND);
        //mCurrentPaint.setStrokeWidth(incoming ? activeStrokeWidth : userStrokeWidth);
        mCurrentPaint.setStrokeWidth(20);
        //TODO MODE
        Annotatable annotatable;
        if ( mode == Mode.Pen ) {
            mCurrentPath = new AnnotationsPath(incoming);
            //annotatable = new Annotatable(mode.toString(), mCurrentPath, mCurrentPaint, width, height);
            //annotatable.setType(Annotatable.AnnotatableType.PATH);
        }else {
            mCurrentPaint.setTextSize(48);
            //annotatable = new Annotatable(mode.toString(), mCurrentText, mCurrentPaint, width, height);
            //annotatable.setType(Annotatable.AnnotatableType.TEXT);
        }
        //mAnnotationsManager.addAnnotatable(annotatable);

        //Annotatable annotatable = new Annotatable(Mode.Pen.toString(), path, paint, width, height);
        //mAnnotationsManager.addAnnotatable(annotatable);
    }

    private void addAnnotatable(){
        Log.i("MARINAS", "ADD ANNOTATABLE");
        Annotatable annotatable = new Annotatable(mode.toString(), mCurrentPath, mCurrentPaint, width, height);
        annotatable.setType(Annotatable.AnnotatableType.PATH);
        mAnnotationsManager.addAnnotatable(annotatable);
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

    @Override
    public void onItemSelected(View v) {
        if (v.getId() == R.id.erase){
            clearCanvas();
        }
        if (v.getId() == R.id.done) {
            //enable view
        }
        if (v.getId() == R.id.type_tool){
            //type text
            mode = Mode.Text;


        }
        if (v.getId() == R.id.draw_freehand){
            //freehand lines
            mode = Mode.Pen;
        }
        //screenshot capture
    }


    public void attachToolbar(AnnotationsToolbar toolbar){
        mToolbar = toolbar;
        mToolbar.setListener(this);
    }
}
