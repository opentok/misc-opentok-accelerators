package com.tokbox.android.accpack.screensharing.annotations.toolbar;


import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.util.AttributeSet;
import android.view.ViewDebug;
import android.widget.ImageButton;
import android.widget.LinearLayout;

import java.util.ArrayList;
import java.util.List;

import com.tokbox.android.accpack.screensharing.R;

public class AnnotationToolbarMenuItem extends ImageButton {
    private int imageResource;
    private Drawable mIcon;
    private int mId = -1;
    private int mMinWidth;
    // List of submenu items
    private List<AnnotationToolbarItem> items = new ArrayList<AnnotationToolbarItem>();

    String color;

    private static final int MAX_ICON_SIZE = 32; // dp
    private int mMaxIconSize;

    public AnnotationToolbarMenuItem(Context context) {
        this(null, context);
    }

    public AnnotationToolbarMenuItem(AttributeSet attrs, Context context) {
        super(context, attrs);

        final float density = context.getResources().getDisplayMetrics().density;
        mMaxIconSize = (int) (MAX_ICON_SIZE * density + 0.5f);

        LinearLayout.LayoutParams btnParams = new LinearLayout.LayoutParams(dpToPx(35), dpToPx(35));
        // INFO Margins are set in onMeasure in AnnotationMenuView
        this.setLayoutParams(btnParams);

        this.setBackgroundColor(context.getResources().getColor(android.R.color.transparent));
    }

    public AnnotationToolbarMenuItem(Context context, int resource) {
        this(context);
        imageResource = resource;

        this.setImageResource(resource);
    }

    public AnnotationToolbarMenuItem(Context context, Drawable icon) {
        this(context);
//        setIcon(icon);

        if (icon != null) {
            BitmapDrawable bitmapDrawable = (BitmapDrawable) icon;
            this.setImageBitmap(bitmapDrawable.getBitmap());
        }
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        if (MeasureSpec.getMode(heightMeasureSpec) == MeasureSpec.AT_MOST) {
            // Fill all available height.
            heightMeasureSpec = MeasureSpec.makeMeasureSpec(
                    MeasureSpec.getSize(heightMeasureSpec), MeasureSpec.EXACTLY);
        }

        super.onMeasure(widthMeasureSpec, heightMeasureSpec);

        final int widthMode = MeasureSpec.getMode(widthMeasureSpec);
        final int widthSize = MeasureSpec.getSize(widthMeasureSpec);
        final int oldMeasuredWidth = getMeasuredWidth();
        final int targetWidth = widthMode == MeasureSpec.AT_MOST ? Math.min(widthSize, 0/*mMinWidth*/)
                : 0/*mMinWidth*/;

        if (widthMode != MeasureSpec.EXACTLY && mMinWidth > 0 && oldMeasuredWidth < targetWidth) {
            // Remeasure at exactly the minimum width.
            super.onMeasure(MeasureSpec.makeMeasureSpec(targetWidth, MeasureSpec.EXACTLY),
                    heightMeasureSpec);
        }

        if (mIcon != null) {
            // TextView won't center compound drawables in both dimensions without
            // a little coercion. Pad in to center the icon after we've measured.
            final int w = getMeasuredWidth();
            final int dw = mIcon.getBounds().width();
            super.setPadding((w - dw) / 2, getPaddingTop(), getPaddingRight(), getPaddingBottom());
        }
    }

    public void setIcon(Drawable icon) {
        mIcon = icon;
        if (icon != null) {
            int width = icon.getIntrinsicWidth();
            int height = icon.getIntrinsicHeight();
            if (width > mMaxIconSize) {
                final float scale = (float) mMaxIconSize / width;
                width = mMaxIconSize;
                height *= scale;
            }
            if (height > mMaxIconSize) {
                final float scale = (float) mMaxIconSize / height;
                height = mMaxIconSize;
                width *= scale;
            }
            icon.setBounds(0, 0, width, height);
        }
//        setCompoundDrawables(icon, null, null, null);
//
//        updateTextButtonVisibility();
    }

    public void addItem(AnnotationToolbarItem item) {
        this.items.add(item);
    }

    public List<AnnotationToolbarItem> getItems() {
        return items;
    }

    void setItems(List<AnnotationToolbarItem> items) {
        this.items = items;
    }

    // TODO Extend this class to make an AnnotationToolbarColorItem (or similar)?

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
        updateColorBackground(Color.parseColor(color));
    }

    public void setColor(int color) {
        this.color = String.format("#%06X", 0xFFFFFF & color);
        updateColorBackground(color);
    }

    @ViewDebug.CapturedViewProperty
    public int getItemId() {
        return mId;
    }

    public void setItemId(int id) {
        this.mId = id;
    }

    private void updateColorBackground(int color) {
        this.setBackgroundResource(R.drawable.circle_button);
        GradientDrawable drawable = (GradientDrawable) this.getBackground();
        drawable.setColor(color);
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
