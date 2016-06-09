package com.tokbox.android.accpack.annotations;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PointF;
import android.graphics.Rect;
import android.text.Editable;
import android.text.TextPaint;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.opentok.android.Publisher;
import com.tokbox.android.accpack.annotations.utils.*;

import java.util.UUID;


public class AnnotationsView extends ViewGroup implements AnnotationsToolbar.ActionsListener {

    private AnnotationsPath mCurrentPath = null;
    private AnnotationsText mCurrentText = null;
    private Paint mCurrentPaint;

    private AnnotationsVideoRenderer videoRenderer;

    private int mCurrentColor = Color.BLACK;
    private AnnotationsManager mAnnotationsManager;

    private static final float TOLERANCE = 5;

    private int width;
    private int height;

    private Mode mode;

    private AnnotationsToolbar mToolbar;

    private boolean mAnnotationsActive = false;
    /**
     * Indicates if you are drawing
     */
    private boolean isDrawing = false;

    private AnnotationsListener mListener;

    public void setAnnotationsListener(AnnotationsListener listener) {
        this.mListener = listener;
    }

    public  interface AnnotationsListener {
        void onScreencaptureReady(Bitmap bmp);
        void onError(String error);
    }

    public enum Mode {
        Pen("annotation-pen"),
        Clear("annotation-clear"),
        Text("annotation-text"),
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
        if (mode.equals(Mode.Pen.toString())) {
            this.mode = Mode.Pen;
        } else {
            if (mode.equals(Mode.Text.toString())) {
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

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        Log.i("MARINAS", "key pressed: " + String.valueOf(event.getKeyCode()));

        return super.dispatchKeyEvent(event);
    }

    public void setLayoutParams(RelativeLayout.LayoutParams params) {
        this.setLayoutParams(params);

    }

    /**
     * ==== Touch Events ====
     **/

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

        if (mode == Mode.Pen) {
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
        } else {
            if (mode == Mode.Text) {
                Log.i("MARINAS", "MODE TEXT");
                final String myString;

                mAnnotationsActive = true;

                EditText editText = new EditText(getContext());
                editText.setVisibility(VISIBLE);
                editText.setImeOptions(EditorInfo.IME_ACTION_DONE);

                // Add whatever you want as size
                int editTextHeight = 70;
                int editTextWidth = 200;

                RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(editTextWidth, editTextHeight);

                //You could adjust the position
                params.topMargin = (int) (event.getRawY());
                params.leftMargin = (int) (event.getRawX());
                this.addView(editText, params);
                editText.setVisibility(VISIBLE);
                editText.setSingleLine();
                editText.setImeOptions(EditorInfo.IME_ACTION_DONE);
                editText.requestFocus();

                InputMethodManager imm = (InputMethodManager) getContext().getSystemService(getContext().INPUT_METHOD_SERVICE);
                imm.toggleSoftInput(InputMethodManager.SHOW_FORCED, InputMethodManager.HIDE_IMPLICIT_ONLY);

                createTextAnnotatable(editText, x, y);
                // mCurrentText = new AnnotationsText(editText, x, y);
                //  createAnnotatable(false);
                // invalidate();

                editText.addTextChangedListener(new TextWatcher() {

                    @Override
                    public void onTextChanged(CharSequence s, int start, int before,
                                              int count) {
                        Log.i("MARINAS", "ONTEXTCHANGED " + s.toString());
                        drawText();
                    }

                    @Override
                    public void afterTextChanged(Editable s) {
                        // TODO Auto-generated method stub

                    }

                    @Override
                    public void beforeTextChanged(CharSequence s, int start, int count,
                                                  int after) {
                        // TODO Auto-generated method stub

                    }

                });

                editText.setOnEditorActionListener(new TextView.OnEditorActionListener() {
                    @Override
                    public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                        if (actionId == EditorInfo.IME_ACTION_DONE) {
                            InputMethodManager imm = (InputMethodManager) v.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
                            imm.hideSoftInputFromWindow(v.getWindowToken(), 0);
                            //Create annotatable text and add it to the canvas
                            mAnnotationsActive = false;
                            addAnnotatable();
                            invalidate();
                            return true;
                        }
                        return false;
                    }
                });
            } else {
                if (mode == Mode.Capture) {


                }
            }

            // captureView();
        }
        return true;
    }

    private void drawText() {
        Log.i("MARINAS", "DRAW TEXT " + mCurrentText.getEditText().getText());

        invalidate();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        if (mAnnotationsActive) {
            if (mCurrentText != null && mCurrentText.getEditText() != null && !mCurrentText.getEditText().getText().toString().isEmpty()) {
                TextPaint textpaint = new TextPaint(mCurrentPaint);
                String text = mCurrentText.getEditText().getText().toString();
                Paint borderPaint = new Paint();
                borderPaint.setStyle(Paint.Style.STROKE);
                borderPaint.setStrokeWidth(5);

                Rect result = new Rect();
                mCurrentPaint.getTextBounds(text, 0, text.length(), result);

                if (text.length() > 10) {
                    String[] strings = text.split("(?<=\\G.{" + 10 + "})");

                    float x = mCurrentText.getX();
                    float y = 240;
                    canvas.drawRect(x, y - result.height() - 20 + (strings.length * 50), x + result.width() + 20, y, borderPaint);

                    for (int i = 0; i < strings.length; i++) {

                        canvas.drawText(strings[i], x, y, mCurrentPaint);

                        y = y + 50;
                    }
                } else {
                    canvas.drawRect(mCurrentText.getX(), 240 - result.height() - 20, mCurrentText.getX() + result.width() + 20, 240, borderPaint);
                    canvas.drawText(mCurrentText.getEditText().getText().toString(), mCurrentText.getX(), 240, mCurrentPaint);

                }
            }
        }


        for (Annotatable drawing : mAnnotationsManager.getAnnotatableList()) {
            if (drawing.getType().equals(Annotatable.AnnotatableType.PATH)) {
                canvas.drawPath(drawing.getPath(), drawing.getPaint());
            }

            if (drawing.getType().equals(Annotatable.AnnotatableType.TEXT)) {

                canvas.drawText(drawing.getText().getEditText().getText().toString(), drawing.getText().x, drawing.getText().y, drawing.getPaint());
            }
        }

    }

    private boolean checkTextPosition(float x, float y) {
        boolean samePosition = false;

        for (Annotatable annotatable : mAnnotationsManager.getAnnotatableList()) {
            if (annotatable.getType().equals(Annotatable.AnnotatableType.TEXT)) {
                if (x >= annotatable.getText().getX() || x <= annotatable.getText().getEditText().getWidth()) {
                    Log.i("MARINAS", "SAME POSITION");
                    samePosition = true;
                }
            }
        }
        return samePosition;
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
        if (mAnnotationsManager.getAnnotatableList().size() > 0) {
            int lastItem = mAnnotationsManager.getAnnotatableList().size() - 1;
            UUID lastId = mAnnotationsManager.getAnnotatableList().get(lastItem).getId();


            for (int i = (mAnnotationsManager.getAnnotatableList().size() - 1); i >= 0; i--) {
                Annotatable annotatable = mAnnotationsManager.getAnnotatableList().get(i);

                if (annotatable.getId().equals(lastId)) {
                    //annotatable.getPath().reset();
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


    public void setLayoutByDefault() {
        RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(
                getResources().getDisplayMetrics().widthPixels, getResources().getDisplayMetrics().heightPixels);
        this.setLayoutParams(layoutParams);
    }

    public void attachPublisher(Publisher publisher) {
        if (publisher.getView().getLayoutParams() == null) {
            RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(
                    getResources().getDisplayMetrics().widthPixels, getResources().getDisplayMetrics().heightPixels);
            this.setLayoutParams(layoutParams);
        } else {
            this.setLayoutParams(publisher.getView().getLayoutParams());
        }
        mAnnotationsManager.attachPublisher(publisher);
        //mAnnotationsManager.getSession().setSignalListener(this);
    }

    public void createTextAnnotatable(EditText editText, float x, float y) {
        Log.i("MARINAS", "Create annotatable");
        mCurrentPaint = new Paint();
        mCurrentPaint.setAntiAlias(true);
        // mCurrentPaint.setColor(incoming ? activeColor : userColor);
        mCurrentPaint.setColor(mCurrentColor);
        mCurrentPaint.setTextSize(48);
        mCurrentText = new AnnotationsText(editText, x, y);
    }

    public void createAnnotatable(boolean incoming) {
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
        if (mode == Mode.Pen) {
            mCurrentPath = new AnnotationsPath(incoming);
            //annotatable = new Annotatable(mode.toString(), mCurrentPath, mCurrentPaint, width, height);
            //annotatable.setType(Annotatable.AnnotatableType.PATH);
        } else {
            mCurrentPaint.setTextSize(48);
            //annotatable = new Annotatable(mode.toString(), mCurrentText, mCurrentPaint, width, height);
            //annotatable.setType(Annotatable.AnnotatableType.TEXT);
        }
        //mAnnotationsManager.addAnnotatable(annotatable);

        //Annotatable annotatable = new Annotatable(Mode.Pen.toString(), path, paint, width, height);
        //mAnnotationsManager.addAnnotatable(annotatable);
    }

    private void addAnnotatable() {
        Log.i("MARINAS", "ADD ANNOTATABLE");
        Annotatable annotatable = null;
        if (mode.equals(Mode.Pen)) {
            annotatable = new Annotatable(mode.toString(), mCurrentPath, mCurrentPaint, width, height);
            annotatable.setType(Annotatable.AnnotatableType.PATH);
        } else {
            annotatable = new Annotatable(mode.toString(), mCurrentText, mCurrentPaint, width, height);
            annotatable.setType(Annotatable.AnnotatableType.TEXT);
        }
        mAnnotationsManager.addAnnotatable(annotatable);
    }

    @Override
    public void onItemSelected(View v) {
        if (v.getId() == R.id.erase) {
            mode = Mode.Clear;
            clearCanvas();
        }
        if (v.getId() == R.id.type_tool) {
            //type text
            mode = Mode.Text;
        }
        if (v.getId() == R.id.draw_freehand) {
            //freehand lines
            mode = Mode.Pen;
        }
        if (v.getId() == R.id.screenshot) {
            Log.i("MARINAS", "ADD SCREENSHOT");
            //screenshot capture
            mode = Mode.Capture;
            if (videoRenderer != null){
                Log.i("MARINAS", "videoRenderer != NULL");
                Bitmap bmp = videoRenderer.captureScreenshot();
                if (mListener != null){
                    Log.i("MARINAS", "videoRendereR MLISTENER != NULL");
                    mListener.onScreencaptureReady(bmp);
                }
            }
        }
    }

    public void attachToolbar(AnnotationsToolbar toolbar) {
        mToolbar = toolbar;
        mToolbar.setActionListener(this);
    }

    public void setVideoRenderer(AnnotationsVideoRenderer videoRenderer) {
        this.videoRenderer = videoRenderer;
    }
}
