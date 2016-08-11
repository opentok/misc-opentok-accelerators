package com.tokbox.android.annotations;


import com.opentok.android.Connection;
import com.opentok.android.Publisher;
import com.opentok.android.Session;
import com.opentok.android.Subscriber;
import com.tokbox.android.accpack.AccPackSession;
import com.tokbox.android.annotations.utils.AnnotationsVideoRenderer;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

public class AnnotationsManager {

    private ArrayList<Annotatable> mAnnotatableList;
    protected final String SIGNAL_TYPE = "annotations";

    public AnnotationsManager(){
        mAnnotatableList = new ArrayList<Annotatable>();
    }

    public void addAnnotatable(Annotatable annotatable){
        mAnnotatableList.add(annotatable);
        if ( annotatable.getPath() != null){
            annotatable.setType (Annotatable.AnnotatableType.PATH);
        }
        else  {
            if ( annotatable.getText() != null ){
                annotatable.setType(Annotatable.AnnotatableType.TEXT);
            }
        }
    }

    public ArrayList<Annotatable> getAnnotatableList() {
        return mAnnotatableList;
    }

}