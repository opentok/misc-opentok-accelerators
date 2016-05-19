package com.tokbox.android.accpack.screensharing.annotations.toolbar;


import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.util.AttributeSet;
import android.util.Log;
import android.view.ViewDebug;
import android.widget.ImageButton;
import android.widget.LinearLayout;

import com.tokbox.android.accpack.screensharing.R;

public class AnnotationToolbarItem extends ImageButton {

    int imageResource;
    FloatPoint[] points;
    boolean smoothDrawEnabled = false;
    String color;
    int mId = -1;

    public AnnotationToolbarItem(Context context) {
        this(null, context);
    }

    public AnnotationToolbarItem(AttributeSet attrs, Context context) {
        super(context, attrs);

        LinearLayout.LayoutParams btnParams = new LinearLayout.LayoutParams(dpToPx(35), dpToPx(35));
        // INFO Margins are set in onMeasure in AnnotationMenuView
        this.setLayoutParams(btnParams);

        this.setBackgroundColor(context.getResources().getColor(android.R.color.transparent));
    }

    /**
     *
     * @param context
     * @param points
     * @param resource
     */
    public AnnotationToolbarItem(Context context, FloatPoint[] points, int resource) {
        this(context);
        imageResource = resource;
        this.points = points;

        this.setImageResource(resource);
    }

    /**
     *
     * @param context
     * @param points
     * @param icon
     */
    public AnnotationToolbarItem(Context context, FloatPoint[] points, Drawable icon) {
        this(context);
        this.points = points;

        if (icon != null) {
            BitmapDrawable bitmapDrawable = (BitmapDrawable) icon;
            this.setImageBitmap(bitmapDrawable.getBitmap());
        } else {
            Log.e("AnnotationToolbarItem", "Icon is null");
        }
    }

    /**
     *
     * @param context
     * @param colorString
     */
    AnnotationToolbarItem(Context context, String colorString) {
        this(context);

        try {
            int color = Color.parseColor(colorString);
            this.setBackgroundResource(R.drawable.circle_button);
            GradientDrawable drawable = (GradientDrawable) this.getBackground();
            drawable.setColor(color);
        } catch (Exception e) {
            // The action wasn't a color, so we should have an icon passed in
        }
    }

    /**
     * Sets a list of points that will be used to describe an annotation path.
     * @param points The points representing the annotation path.
     */
    public void setPoints(FloatPoint[] points) {
        this.points = points;
    }

    /**
     * Retrieves the array of points representing the annotation path.
     * @return The list of annotation points.
     */
    public FloatPoint[] getPoints() {
        return points;
    }

    // TODO Extend this class to make an AnnotationToolbarColorItem (or similar)?

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public void setColor(int color) {
        this.color = String.format("#%06X", 0xFFFFFF & color);
    }

    @ViewDebug.CapturedViewProperty
    public int getItemId() {
        return mId;
    }

    public void setItemId(int id) {
        this.mId = id;
    }

    public void setSmoothDrawEnabled(boolean enabled) {
        smoothDrawEnabled = enabled;
    }

    public boolean isSmoothDrawEnabled() {
        return smoothDrawEnabled;
    }

    /**
     * Converts dp to real pixels, according to the screen density.
     *
     * @param dp A number of density-independent pixels.
     * @return The equivalent number of real pixels.
     */
    private int dpToPx(int dp) {
        double screenDensity = this.getResources().getDisplayMetrics().density;
        return (int) (screenDensity * (double) dp);
    }
}
