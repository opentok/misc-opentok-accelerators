package com.tokbox.android.accpack.screensharing;

import android.content.Context;

import com.opentok.android.BaseVideoCapturer;
import com.opentok.android.Publisher;
import com.opentok.android.PublisherKit;

import java.io.Serializable;

public class ScreenPublisher extends Publisher implements Serializable {
    public ScreenPublisher(Context context) {
        super(context);
    }

    public ScreenPublisher(Context context, String name) {
        super(context, name);
    }

    public ScreenPublisher(Context context, String name, boolean audioTrack, boolean videoTrack) {
        super(context, name, audioTrack, videoTrack);
    }

    public ScreenPublisher(Context context, String name, BaseVideoCapturer capturer) {
        super(context, name, capturer);
    }

    public ScreenPublisher(Context context, String name, boolean audioTrack, boolean videoTrack, BaseVideoCapturer capturer) {
        super(context, name, audioTrack, videoTrack);
        this.setCapturer(capturer);
    }
}

