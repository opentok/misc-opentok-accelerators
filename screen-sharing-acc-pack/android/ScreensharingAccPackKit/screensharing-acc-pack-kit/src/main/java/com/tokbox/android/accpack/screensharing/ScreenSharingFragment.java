package com.tokbox.android.accpack.screensharing;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.PixelFormat;
import android.graphics.Point;
import android.hardware.display.DisplayManager;
import android.hardware.display.VirtualDisplay;
import android.media.ImageReader;
import android.media.projection.MediaProjection;
import android.media.projection.MediaProjectionManager;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.content.Context;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Display;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.RelativeLayout;

import com.opentok.android.Connection;
import com.opentok.android.OpentokError;
import com.opentok.android.PublisherKit;
import com.opentok.android.Session;
import com.opentok.android.Stream;
import com.opentok.android.Subscriber;
import com.tokbox.android.accpack.AccPackSession;


import com.tokbox.android.annotations.AnnotationsToolbar;
import com.tokbox.android.annotations.AnnotationsView;
import com.tokbox.android.accpack.screensharing.config.OpenTokConfig;
import com.tokbox.android.annotations.utils.AnnotationsVideoRenderer;
import com.tokbox.android.logging.OTKAnalytics;
import com.tokbox.android.logging.OTKAnalyticsData;

import java.util.UUID;


/**
 * Defines a fragment to represent the ScreenSharing acc-pack
 *
 */
public class ScreenSharingFragment extends Fragment implements AccPackSession.SessionListener, PublisherKit.PublisherListener, AccPackSession.SignalListener, ScreenSharingBar.ScreenSharingBarListener{

    private static final String LOG_TAG = ScreenSharingFragment.class.getSimpleName();

    private static final String STATE_RESULT_CODE = "result_code";
    private static final String STATE_RESULT_DATA = "result_data";
    private static final String ERROR = "ScreenSharing error";
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
    private AnnotationsToolbar mRemoteAnnotationsToolbar;

    private ScreenSharingBar mScreensharingBar;

    private boolean isStarted = false;
    private boolean isAnnotationsEnabled = false;
    private boolean isRemoteAnnotationsEnabled = false;
    private boolean isAudioEnabled = true;

    private ViewGroup mScreen;

    private AnnotationsVideoRenderer mRenderer;
    private View rootView;

    private OTKAnalyticsData mAnalyticsData;
    private OTKAnalytics mAnalytics;


    @Override
    public void onSignalReceived(Session session, String type, String data, Connection connection) {
        if (type.equals("annotations")){
            Log.i(LOG_TAG, "New annotation received");
        }
    }

    @Override
    public void onClose() {
        addLogEvent(OpenTokConfig.LOG_ACTION_CLOSE, OpenTokConfig.LOG_VARIATION_ATTEMPT);
        if (isStarted) {
            mAnnotationsView.restart();
            mAnnotationsView = null;
            stop();
            removeScreensharingBar();
            mListener.onClosed();
        }
        addLogEvent(OpenTokConfig.LOG_ACTION_CLOSE, OpenTokConfig.LOG_VARIATION_SUCCESS);
    }

    /**
     * Monitors state changes in the ScreenSharingFragment.
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


        /**
         * Invoked when the annotations view has been added to the screensharing view.
         *
         * @param view The annotations view.
         */
        void onAnnotationsViewReady(AnnotationsView view);

        /**
         * Invoked when the screensharing has been closed.
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

    private void init(){
        //Analytics logging
        String source = getContext().getPackageName();

        SharedPreferences prefs = getContext().getSharedPreferences("opentok", Context.MODE_PRIVATE);
        String guidVSol = prefs.getString("guidVSol", null);
        if (null == guidVSol) {
            guidVSol = UUID.randomUUID().toString();
            prefs.edit().putString("guidVSol", guidVSol).commit();
        }

        mAnalyticsData = new OTKAnalyticsData.Builder(OpenTokConfig.LOG_CLIENT_VERSION, source, OpenTokConfig.LOG_COMPONENTID, guidVSol).build();
        mAnalytics = new OTKAnalytics(mAnalyticsData);

        checkSessionInfo();

        addLogEvent(OpenTokConfig.LOG_ACTION_INITIALIZE, OpenTokConfig.LOG_VARIATION_SUCCESS);
    }

    private void checkSessionInfo(){
        if ( mAnalytics != null ){
            if ( mSession != null ) {
                mAnalyticsData.setSessionId(mSession.getSessionId());
                mAnalyticsData.setConnectionId(mSession.getConnection().getConnectionId());
            }
            if ( mApiKey != null ) {
                mAnalyticsData.setPartnerId(mApiKey);
            }
            mAnalytics. setData(mAnalyticsData);
        }
    }

    private void removeScreensharingBar(){
        if(mScreensharingBar != null ){
            WindowManager wm = (WindowManager) getContext().getSystemService(Context.WINDOW_SERVICE);
            wm.removeView(mScreensharingBar);
            mScreensharingBar = null;
        }
    }

    private void checkAnnotations() {
        if ( isAnnotationsEnabled || isRemoteAnnotationsEnabled ) {
            mAnnotationsToolbar.restart();
        }
    }

    private int dpToPx(int dp) {
        double screenDensity = this.getResources().getDisplayMetrics().density;
        return (int) (screenDensity * (double) dp);
    }

    //add log events
    private void addLogEvent(String action, String variation){
        if ( mAnalytics!= null ) {
            mAnalytics.logEvent(action, variation);
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

        Point size = new Point();
        mDisplay.getRealSize(size);
        mWidth = size.x;
        mHeight = size.y;

        // start capture reader
        mImageReader = ImageReader.newInstance(mWidth, mHeight, PixelFormat.RGBA_8888, 2);
        int flags = DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR;

        mVirtualDisplay = mMediaProjection.createVirtualDisplay("ScreenCapture", mWidth, mHeight, mDensity, flags, mImageReader.getSurface(), null, null);

        size.set(mWidth, mHeight);

        //create ScreenCapturer
        ScreenSharingCapturer capturer = new ScreenSharingCapturer(getContext(), mScreen, mImageReader);

        mScreenPublisher = new ScreenPublisher(getContext(), "screenPublisher", isAudioEnabled, true, capturer);
        mScreenPublisher.setPublisherVideoType(PublisherKit.PublisherKitVideoType.PublisherKitVideoTypeScreen);
        mScreenPublisher.setPublisherListener(this);

        mRenderer = new AnnotationsVideoRenderer(getContext());
        mScreenPublisher.setRenderer(mRenderer);

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

    /*
     * Set the screen sharing listener.
     * @param mListener The screen sharing listener.
     */
    public void setListener(ScreenSharingListener mListener) {
        this.mListener = mListener;
    }

    /*
    * Start sharing the screen.
    */
    public void start(){
        init();
        if (isConnected) {
            checkSessionInfo(); //add session info to the logging

            if (mVirtualDisplay == null) {
                addLogEvent(OpenTokConfig.LOG_ACTION_START, OpenTokConfig.LOG_VARIATION_ATTEMPT);
                startScreenCapture();
            }
        }
    }

    /*
    * Stop sharing the screen.
    */
    public void stop(){
        addLogEvent(OpenTokConfig.LOG_ACTION_END, OpenTokConfig.LOG_VARIATION_ATTEMPT);
        stopScreenCapture();
        if (mScreenPublisher != null) {
            mSession.unpublish(mScreenPublisher);
        }
        removeScreensharingBar();
    }

    /*
    * Check whether screensharing has started.
    * @return <code>true</code> if screensharing started; <code>false</code> otherwise.
    */
    public boolean isStarted() {
        return isStarted;
    }

    /*
    * Enable or disable the annotations in the screensharing.
    * @param annotationsEnabled <code>true</code> if annotations are enabled; <code>false</code> otherwise.
    * @param toolbar The annotations toolbar.
    */
    public void enableAnnotations(boolean annotationsEnabled, AnnotationsToolbar toolbar) {
        isAnnotationsEnabled = annotationsEnabled;
        mAnnotationsToolbar = toolbar;

        //add logging info
        if (annotationsEnabled){
            addLogEvent(OpenTokConfig.LOG_ACTION_ENABLE_ANNOTATIONS, OpenTokConfig.LOG_VARIATION_SUCCESS);
        }
        else {
            addLogEvent(OpenTokConfig.LOG_ACTION_DISABLE_ANNOTATIONS, OpenTokConfig.LOG_VARIATION_SUCCESS);
        }
    }

    /*
    * Enable or disable the audio in the screensharing.
    * @param enabled <code>true</code> if  the audio is enabled; <code>false</code> otherwise.
    */
    public void enableAudioScreensharing(boolean enabled) {
        isAudioEnabled = enabled;

        //add logging info
        if (enabled){
            addLogEvent(OpenTokConfig.LOG_ACTION_ENABLE_SCREENSHARING_AUDIO, OpenTokConfig.LOG_VARIATION_SUCCESS);
        }
        else {
            addLogEvent(OpenTokConfig.LOG_ACTION_DISABLE_SCREENSHARING_AUDIO, OpenTokConfig.LOG_VARIATION_SUCCESS);
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        if (isStarted) {
            stop();
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        if (isStarted) {
            start();
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        tearDownMediaProjection();
        removeScreensharingBar();
        addLogEvent(OpenTokConfig.LOG_ACTION_DESTROY, OpenTokConfig.LOG_VARIATION_SUCCESS);
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
        rootView = inflater.inflate(R.layout.main_layout, container, false);
        mScreen = container;

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
                Log.i(LOG_TAG, "User cancelled screensharing permission");
                onScreenSharingError(ERROR + ": User cancelled screensharing permission");
                return;
            }
            Activity activity = getActivity();
            if (activity == null) {
                onScreenSharingError(ERROR + ": Activity is null");
                return;
            }
            Log.i(LOG_TAG, "Starting screen capture");
            mResultCode = resultCode;
            mResultData = data;
            setUpMediaProjection();
            setUpVirtualDisplay();

        }
    }

    protected void onScreenSharingStarted(){
        if ( mListener != null ){
            mListener.onScreenSharingStarted();
            addLogEvent(OpenTokConfig.LOG_ACTION_START, OpenTokConfig.LOG_VARIATION_SUCCESS);
        }
    }

    protected void onScreenSharingStopped(){
        if ( mListener != null ){
            mListener.onScreenSharingStopped();
            addLogEvent(OpenTokConfig.LOG_ACTION_END, OpenTokConfig.LOG_VARIATION_SUCCESS);
        }
    }

    protected void onScreenSharingError(String error){
        if ( mListener != null ){
            mListener.onScreenSharingError(error);
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
        stop();
        onScreenSharingError(ERROR + ": "+ opentokError.toString());
    }

    @Override
    public void onStreamCreated(PublisherKit publisherKit, Stream stream) {
        onScreenSharingStarted();
        checkAnnotations();
        isStarted = true;
        try {
            if ( isAnnotationsEnabled ) {
                if (mAnnotationsView == null) {
                    mAnnotationsView = new AnnotationsView(getContext(), mSession, mApiKey, true, mScreenPublisher);
                    mAnnotationsView.attachToolbar(mAnnotationsToolbar);
                    mAnnotationsView.setVideoRenderer(mRenderer); //to use screencapture
                }
                onAnnotationsViewReady(mAnnotationsView);
                mScreen.addView(mAnnotationsView);
            }
            mScreensharingBar = new ScreenSharingBar(getContext(), this);

            //add screensharing bar on top of the screen
            WindowManager.LayoutParams params = new WindowManager.LayoutParams(
                    WindowManager.LayoutParams.MATCH_PARENT,
                    WindowManager.LayoutParams.WRAP_CONTENT,
                    WindowManager.LayoutParams.TYPE_APPLICATION_PANEL,
                    0 | WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
                    PixelFormat.TRANSLUCENT);
            params.gravity = Gravity.LEFT | Gravity.TOP;
            params.x = 0;
            params.y = 0;

            WindowManager wm = (WindowManager) getContext().getSystemService(Context.WINDOW_SERVICE);
            wm.addView(mScreensharingBar, params);
        }catch(Exception e){
            Log.i(LOG_TAG, "Exception - onStreamCreated "+e);
        }
    }

    @Override
    public void onStreamDestroyed(PublisherKit publisherKit, Stream stream) {
        mScreenPublisher = null;
        mScreen.removeView(mScreensharingBar);
        mScreen.removeView(mAnnotationsView);
        checkAnnotations();
        onScreenSharingStopped();
        isStarted = false;
        mAnnotationsView = null;
    }

    @Override
    public void onError(PublisherKit publisherKit, OpentokError opentokError) {
        onScreenSharingError(ERROR + ": "+opentokError.getMessage());
        if (isStarted()){
            addLogEvent(OpenTokConfig.LOG_ACTION_END, OpenTokConfig.LOG_VARIATION_ERROR);
        }
        else {
            addLogEvent(OpenTokConfig.LOG_ACTION_START, OpenTokConfig.LOG_VARIATION_ERROR);
        }
    }

}
