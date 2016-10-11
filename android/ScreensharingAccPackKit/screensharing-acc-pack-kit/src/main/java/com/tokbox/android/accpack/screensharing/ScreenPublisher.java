package com.tokbox.android.accpack.screensharing;

import android.content.Context;

import com.opentok.android.BaseVideoCapturer;
import com.opentok.android.Publisher;
import com.opentok.android.PublisherKit;

import java.io.Serializable;

/**
 * Defines a Publisher of PublisherKitVideoTypeScreen to be used by the ScreenSharingFragment
 *
 */
public class ScreenPublisher extends Publisher implements Serializable {

    /**
     * Constructor
     * @param context The <a target="_top" href=
     *                   "http://developer.android.com/reference/android/content/Context.html"
     *                   >android.content.Context</a> for the Publisher.
     */
    public ScreenPublisher(Context context) {
        super(context);
    }

    /**
     * Constructor
     * @param context The <a target="_top" href=
     *                   "http://developer.android.com/reference/android/content/Context.html"
     *                   >android.content.Context</a> for the Publisher.
     * @param name  The name of the publisher.
     */
    public ScreenPublisher(Context context, String name) {
        super(context, name);
    }

    /**
     *
     * @param context The <a target="_top" href=
     *                   "http://developer.android.com/reference/android/content/Context.html"
     *                   >android.content.Context</a> for the Publisher.
     * @param name       The name of the publisher.
     * @param audioTrack Whether to include an audio track in the published stream.
     * @param videoTrack Whether to include a video track in the published stream.
     */
    public ScreenPublisher(Context context, String name, boolean audioTrack, boolean videoTrack) {
        super(context, name, audioTrack, videoTrack);
    }

    /**
     *
     * @param context The <a target="_top" href=
     *                   "http://developer.android.com/reference/android/content/Context.html"
     *                   >android.content.Context</a> for the Publisher.
     * @param name The name of the publisher.
     * @param capturer  The video capturer for this publisher to use.
     */
    public ScreenPublisher(Context context, String name, BaseVideoCapturer capturer) {
        super(context, name, capturer);
    }

    /**
     *
     * @param context The <a target="_top" href=
     *                   "http://developer.android.com/reference/android/content/Context.html"
     *                   >android.content.Context</a> for the Publisher.
     * @param name The name of the publisher.
     * @param audioTrack Whether to include an audio track in the published stream.
     * @param videoTrack Whether to include a video track in the published stream.
     * @param capturer The video capturer for this publisher to use.
     */
    public ScreenPublisher(Context context, String name, boolean audioTrack, boolean videoTrack, BaseVideoCapturer capturer) {
        super(context, name, audioTrack, videoTrack);
        this.setCapturer(capturer);
    }
}

