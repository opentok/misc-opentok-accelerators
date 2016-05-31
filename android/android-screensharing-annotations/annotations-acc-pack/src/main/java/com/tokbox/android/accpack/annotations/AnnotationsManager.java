package com.tokbox.android.accpack.annotations;


import com.opentok.android.Connection;
import com.opentok.android.Publisher;
import com.opentok.android.Session;
import com.opentok.android.Subscriber;
import com.tokbox.android.accpack.AccPackSession;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

public class AnnotationsManager {

    private ArrayList<Annotatable> mAnnotatableList;
    protected final String SIGNAL_TYPE = "annotations";

    private Publisher mPublisher;

    public Subscriber getSubscriber() {
        return mSubscriber;
    }

    private Subscriber mSubscriber;


    private AccPackSession mSession;

    public AnnotationsManager(){
      //  mAnnotationsPathList = new ArrayList<AnnotationsPath>();
        mAnnotatableList = new ArrayList<Annotatable>();
    }
    public Publisher getPublisher() {
        return mPublisher;
    }
    public void addAnnotatable(Annotatable annotatable){
        mAnnotatableList.add(annotatable);
        if ( annotatable.getPath() != null){
            annotatable.setType (Annotatable.AnnotatableType.PATH);
            //String updatedSignal = buildSignal(annotatable);
           // mAnnotationsPathList.add(annotatable.getPath());

            // Pass this through signal
           /* if (mSubscriber != null) {
                mSubscriber.getSession().sendSignal(SIGNAL_TYPE, updatedSignal);
            } else if (mPublisher != null) {
                mPublisher.getSession().sendSignal(SIGNAL_TYPE, updatedSignal);
            }*/

        }
    }

    public void removeAnnotatable(Annotatable annotatable){

    }

    public ArrayList<Annotatable> getAnnotatableList() {
        return mAnnotatableList;
    }


    //private String buildSignalFromPoint(float x, float y, boolean startPoint, boolean endPoint) {
    private String buildSignal(Annotatable annotatable) {
        JSONArray jsonArray = new JSONArray();
        JSONObject jsonObject = new JSONObject();

        boolean mirrored = false;

        int videoWidth = 0;
        int videoHeight = 0;
        String id = null;

        AnnotationsVideoRenderer renderer = null;

        if (mPublisher != null) {
            renderer = ((AnnotationsVideoRenderer) mPublisher.getRenderer());
            id = mPublisher.getSession().getConnection().getConnectionId();
        } else if (mSubscriber != null) {
            renderer = ((AnnotationsVideoRenderer) mSubscriber.getRenderer());
            id = mSubscriber.getSession().getConnection().getConnectionId();
        }

        if (renderer != null) {
            mirrored = renderer.isMirrored();
            videoWidth = renderer.getVideoWidth();
            videoHeight = renderer.getVideoHeight();
        }

        // TODO Include a unique ID for the path?
        try {
            jsonObject.put("mode", annotatable.getMode());
            jsonObject.put("pathId", annotatable.getPath().getId());
            jsonObject.put("id", id);
            //jsonObject.put("fromId", mycid); --> marinas: connectionId from signal callback
            jsonObject.put("fromX", annotatable.getPath().getLastPointF().x);
            jsonObject.put("fromY", annotatable.getPath().getLastPointF().y);
            jsonObject.put("toX", annotatable.getPath().getCurrentPoint().x);
            jsonObject.put("toY", annotatable.getPath().getCurrentPoint().y);
           // jsonObject.put("color", String.format("#%06X", (0xFFFFFF & userColor)));
           // jsonObject.put("lineWidth", userStrokeWidth);
            jsonObject.put("videoWidth", videoWidth);
            jsonObject.put("videoHeight", videoHeight);
            jsonObject.put("canvasWidth", annotatable.getCanvasWidth());
            jsonObject.put("canvasHeight", annotatable.getCanvasHeight());
            jsonObject.put("mirrored", mirrored);
            //jsonObject.put("smoothed", selectedItem.isSmoothDrawEnabled());
            jsonObject.put("startPoint", annotatable.getPath().isStartPoint());
            jsonObject.put("endPoint", annotatable.getPath().isEndPoint());

            // TODO These need to be batched
            jsonArray.put(jsonObject);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return jsonArray.toString();
    }

    public void attachPublisher(Publisher publisher){
        mPublisher = publisher;
        mSession = (AccPackSession) mPublisher.getSession();
    }

    public void attachSubscriber(Subscriber subscriber){
        mSubscriber = subscriber;
        mSession = (AccPackSession) mSubscriber.getSession();
    }

    public AccPackSession getSession() {
        return mSession;
    }

}
