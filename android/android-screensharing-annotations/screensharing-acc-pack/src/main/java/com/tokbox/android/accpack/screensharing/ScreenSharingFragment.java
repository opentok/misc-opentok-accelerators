package com.tokbox.android.accpack.screensharing;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.graphics.Point;
import android.hardware.display.DisplayManager;
import android.hardware.display.VirtualDisplay;
import android.media.ImageReader;
import android.media.projection.MediaProjection;
import android.media.projection.MediaProjectionManager;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.content.Context;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.opentok.android.BaseVideoRenderer;
import com.opentok.android.Connection;
import com.opentok.android.OpentokError;
import com.opentok.android.Publisher;
import com.opentok.android.PublisherKit;
import com.opentok.android.Session;
import com.opentok.android.Stream;
import com.tokbox.android.accpack.AccPackSession;


import com.tokbox.android.accpack.annotations.AnnotationsToolbar;
import com.tokbox.android.accpack.annotations.AnnotationsView;
import com.tokbox.android.accpack.annotations.utils.AnnotationsVideoRenderer;


public class ScreenSharingFragment extends Fragment implements AccPackSession.SessionListener, PublisherKit.PublisherListener, AccPackSession.SignalListener{

    private static final String LOG_TAG = ScreenSharingFragment.class.getSimpleName();
    private static final String STATE_RESULT_CODE = "result_code";
    private static final String STATE_RESULT_DATA = "result_data";

    private static final int REQUEST_MEDIA_PROJECTION = 1;

    private AccPackSession mSession;
    private ScreenPublisher mScreenPublisher;
    private String mApiKey;
    private boolean isConnected;

    private ScreenSharingListener mListener;

    private VirtualDisplay mVirtualDisplay;
    private int mDensity;
    private int mWidth;
    private int mHeight;

    private MediaProjectionManager mMediaProjectionManager;
    private MediaProjection mMediaProjection;
    private ImageReader mImageReader;


    private int mResultCode;
    private Intent mResultData;

    private RelativeLayout mScreenView;

    private AnnotationsView mAnnotationsView;
    private AnnotationsToolbar mAnnotationsToolbar;

    private RelativeLayout mScreensharingBar;
    private View mScreensharingLeftView;
    private View mScreensharingRightView;
    private View mScreensharingBottomView;
    private ImageButton mCloseBtn;

    private boolean isStarted = false;
    private boolean isAnnotationsEnabled = false;

    @Override
    public void onSignalReceived(Session session, String type, String data, Connection connection) {
        if (type.equals("annotations")){
            Log.i(LOG_TAG, "New annotation received");
        }
    }

    /**
     * Monitors state changes in the TextChatFragment.
     *
     */
    public interface ScreenSharingListener {

        /**
         * Invoked when screensharing started.
         *
         */
        void onScreenSharingStarted();

        /**
         * Invoked when screensharing stopped.
         *
         */
        void onScreenSharingStopped();


        /**
         * Invoked when a screen sharing error occurs.
         *
         * @param error The error message.
         */
        void onScreenSharingError(String error);


        void onAnnotationsViewReady(AnnotationsView view);
        /**
         * Invoked when the close button is clicked.
         *
         */
        void onClosed();

    }

    /*
  * Constructor.
  */
    public ScreenSharingFragment(){

    }

    public static ScreenSharingFragment newInstance(AccPackSession session, String apiKey) {
        ScreenSharingFragment fragment = new ScreenSharingFragment();

        fragment.mSession = session;
        fragment.mSession.setSessionListener(fragment);
        fragment.mApiKey = apiKey;

        return fragment;
    }

    public void setListener(ScreenSharingListener mListener) {
        this.mListener = mListener;
    }

    public void start(){
        if (isConnected) {

            if (mVirtualDisplay == null) {
                startScreenCapture();
            }
        }
    }

    public void stop(){
        stopScreenCapture();
        mSession.unpublish(mScreenPublisher);
    }

    @Override
    public void onPause() {
        super.onPause();
        //stopScreenCapture();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        tearDownMediaProjection();

    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (savedInstanceState != null) {
            mResultCode = savedInstanceState.getInt(STATE_RESULT_CODE);
            mResultData = savedInstanceState.getParcelable(STATE_RESULT_DATA);
        }
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.main_layout, container, false);

        mScreenView = (RelativeLayout) rootView.findViewById(R.id.screen_view);
        mAnnotationsToolbar = (AnnotationsToolbar) rootView.findViewById(R.id.annotations_bar);

        mScreensharingBar = (RelativeLayout) rootView.findViewById(R.id.screnesharing_bar);
        mScreensharingLeftView = (View) rootView.findViewById(R.id.left_line);
        mScreensharingRightView = (View) rootView.findViewById(R.id.right_line);
        mScreensharingBottomView = (View) rootView.findViewById(R.id.bottom_line);
        mCloseBtn = (ImageButton) rootView.findViewById(R.id.screensharing_close);

        mCloseBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (isStarted)
                    stop();
            }
        });
        return rootView;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        Activity activity = getActivity();
        DisplayMetrics metrics = new DisplayMetrics();
        activity.getWindowManager().getDefaultDisplay().getMetrics(metrics);
        mDensity = metrics.densityDpi;
        mMediaProjectionManager = (MediaProjectionManager)
                activity.getSystemService(Context.MEDIA_PROJECTION_SERVICE);
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        if (mResultData != null) {
            outState.putInt(STATE_RESULT_CODE, mResultCode);
            outState.putParcelable(STATE_RESULT_DATA, mResultData);
        }
    }


    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {

        if (requestCode == REQUEST_MEDIA_PROJECTION) {
            if (resultCode != Activity.RESULT_OK) {
                Log.i(LOG_TAG, "User cancelled");
                //Toast.makeText(getActivity(), R.string.user_cancelled, Toast.LENGTH_SHORT).show();
                return;
            }
            Activity activity = getActivity();
            if (activity == null) {
                return;
            }
            Log.i(LOG_TAG, "Starting screen capture");
            mResultCode = resultCode;
            mResultData = data;
            setUpMediaProjection();
            setUpVirtualDisplay();

        }
    }


    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private void setUpMediaProjection() {
        mMediaProjection = mMediaProjectionManager.getMediaProjection(mResultCode, mResultData);
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private void setUpVirtualDisplay() {

        // display metrics
        DisplayMetrics metrics = getResources().getDisplayMetrics();
        mDensity = metrics.densityDpi;
        Display mDisplay = getActivity().getWindowManager().getDefaultDisplay();

        // get width and height
        Point size = new Point();
        mDisplay.getSize(size);
        mWidth = size.x;
        mHeight = size.y;

        // start capture reader
        mImageReader = ImageReader.newInstance(mWidth, mHeight, PixelFormat.RGBA_8888, 2);
        mVirtualDisplay = mMediaProjection.createVirtualDisplay("ScreenCapture", mWidth, mHeight, mDensity, DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR, mImageReader.getSurface(), null, null);

        size.set(mWidth, mHeight);

        //create ScreenCapturer
        ScreenSharingCapturer capturer = new ScreenSharingCapturer(getContext(), mScreenView, mImageReader, size);
        mScreenPublisher = new ScreenPublisher(getContext(), "screenPublisher", capturer);
        mScreenPublisher.setPublisherVideoType(PublisherKit.PublisherKitVideoType.PublisherKitVideoTypeScreen);
        mScreenPublisher.setPublisherListener(this);

        mAnnotationsView = new AnnotationsView(getContext());
        mAnnotationsView.attachToolbar(mAnnotationsToolbar);
        mAnnotationsView.setLayoutParams(mScreenView.getLayoutParams());

        AnnotationsVideoRenderer annotationsRenderer = new AnnotationsVideoRenderer(getContext());
        mScreenPublisher.setRenderer(annotationsRenderer);
        mAnnotationsView.setVideoRenderer(annotationsRenderer); //to use screencapture

        onAnnotationsViewReady(mAnnotationsView);

        mScreenView.addView(mAnnotationsView);
        mSession.publish(mScreenPublisher);

    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private void tearDownMediaProjection() {
        if (mMediaProjection != null) {
            mMediaProjection.stop();
            mMediaProjection = null;
        }
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private void startScreenCapture() {

        if (mMediaProjection != null) {
            Log.i(LOG_TAG, "mMediaProjection != null");

            setUpVirtualDisplay();
        } else if (mResultCode != 0 && mResultData != null) {
            Log.i(LOG_TAG, "mResultCode != 0 && mResultData != null");
            setUpMediaProjection();
            setUpVirtualDisplay();
        } else {
            Log.i(LOG_TAG, "Requesting confirmation");
            startActivityForResult(
                    mMediaProjectionManager.createScreenCaptureIntent(),
                    REQUEST_MEDIA_PROJECTION);
        }
    }

    @TargetApi(Build.VERSION_CODES.KITKAT)
    private void stopScreenCapture() {
        if (mVirtualDisplay == null) {
            return;
        }
        mVirtualDisplay.release();
        mVirtualDisplay = null;

        tearDownMediaProjection();
    }

    protected void onScreenSharingStarted(){
        isStarted = true;
        if ( mListener != null ){
           mListener.onScreenSharingStarted();
        }
    }

    protected void onScreenSharingStopped(){
        isStarted = false;
        //checkAnnotations();
        if ( mListener != null ){
            mListener.onScreenSharingStopped();
        }
    }

    protected void onScreenSharingError(String error){
        if ( mListener != null ){
            mListener.onScreenSharingError(error);
        }
    }

    protected void onClosed(){
        if ( mListener != null ){
            mListener.onClosed();
        }
    }

    protected void onAnnotationsViewReady(AnnotationsView view){
        if ( mListener != null ){
            mListener.onAnnotationsViewReady(view);
        }
    }

    @Override
    public void onConnected(Session session) {
        isConnected = true;
    }

    @Override
    public void onDisconnected(Session session) {
        isConnected = false;
    }

    @Override
    public void onStreamReceived(Session session, Stream stream) {

    }

    @Override
    public void onStreamDropped(Session session, Stream stream) {

    }

    @Override
    public void onError(Session session, OpentokError opentokError) {

    }

    @Override
    public void onStreamCreated(PublisherKit publisherKit, Stream stream) {
        Log.i("MARINAS", "ONSTREAMCREATED PUBLISHER SCREEN");
        enableScreensharingBar(true);
        onScreenSharingStarted();
        checkAnnotations();


    }

    private void enableScreensharingBar(boolean visible){
        if (visible) {
            mScreensharingBar.setVisibility(View.VISIBLE);
            mScreensharingBottomView.setVisibility(View.VISIBLE);
            mScreensharingRightView.setVisibility(View.VISIBLE);
            mScreensharingLeftView.setVisibility(View.VISIBLE);
        }
        else {
            mScreensharingBar.setVisibility(View.GONE);
            mScreensharingBottomView.setVisibility(View.GONE);
            mScreensharingRightView.setVisibility(View.GONE);
            mScreensharingLeftView.setVisibility(View.GONE);
        }
    }

    private void checkAnnotations() {
        if (isAnnotationsEnabled) {
            if (mAnnotationsToolbar.getVisibility() == View.VISIBLE) {
                mAnnotationsToolbar.setVisibility(View.GONE);
            } else {
                //VISIBLE TOOLBAR
                mAnnotationsToolbar.setVisibility(View.VISIBLE);

                //Add annotations view
                //mScreenView.addView(mAnnotationView);
            }
        }
    }
    @Override
    public void onStreamDestroyed(PublisherKit publisherKit, Stream stream) {
        mScreenPublisher = null;
        enableScreensharingBar(false);
        onScreenSharingStopped();
        mScreenView.removeView(mAnnotationsView);
        onClosed();
    }

    @Override
    public void onError(PublisherKit publisherKit, OpentokError opentokError) {
        onScreenSharingError(opentokError.getMessage());
    }

    public boolean isStarted() {
        return isStarted;
    }

    public void setAnnotationsEnabled(boolean annotationsEnabled) {
        isAnnotationsEnabled = annotationsEnabled;
    }

    public AnnotationsView getAnnotationsView() {
        return mAnnotationsView;
    }
}
