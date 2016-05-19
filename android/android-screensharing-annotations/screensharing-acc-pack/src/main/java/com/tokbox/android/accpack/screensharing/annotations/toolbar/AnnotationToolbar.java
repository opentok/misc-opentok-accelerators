package com.tokbox.android.accpack.screensharing.annotations.toolbar;

import android.app.ActionBar;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.os.Parcel;
import android.os.Parcelable;
import android.support.v4.view.GravityCompat;
import android.support.v7.widget.Toolbar;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.HorizontalScrollView;

import com.opentok.android.*;

import junit.framework.Assert;

import java.util.ArrayList;
import java.util.List;

import com.tokbox.android.accpack.screensharing.R;

public class AnnotationToolbar extends ViewGroup implements AnnotationMenuInflator.ActionListener {

    private int mGravity;
    private int mWidth;
    private int mHeight;
    private List<SignalListener> signalListeners = new ArrayList<SignalListener>();
    private List<ActionListener> actionListeners = new ArrayList<ActionListener>();
    private List<ScreenCaptureListener> captureListeners = new ArrayList<ScreenCaptureListener>();

    private AnnotationMenuView menu;

    private List<Integer> colors = new ArrayList<Integer>();
    private List<Integer> lineWidths = new ArrayList<Integer>();

    private AnnotationToolbarItem selectedItem;

    public AnnotationToolbar(Context context) {
        this(context, null);
    }

    public AnnotationToolbar(Context context, AttributeSet attrs) {
        super(context, attrs);

        initDefaultColors();
        initDefaultLineWidths();

        if (this.getBackground() == null) {
            this.setBackgroundColor(getResources().getColor(R.color.TransparentBlack));
        }

        int[] systemAttrs = new int[] {
                android.R.attr.id,
                android.R.attr.background,
                android.R.attr.layout_width,
                android.R.attr.layout_height
        };

        TypedArray android_ta = context.obtainStyledAttributes(attrs, systemAttrs, 0, 0);
        TypedArray ta = context.obtainStyledAttributes(attrs, R.styleable.AnnotationToolbar, 0, 0);
        try {
            int tintColor = ta.getColor(R.styleable.AnnotationToolbar_tint_color, Color.WHITE);

            mGravity = ta.getInt(R.styleable.LinearLayoutCompat_android_gravity, Gravity.CENTER_HORIZONTAL);
            // FIXME If match_parent or wrap_content is used, these will throw UnsupportedOperationException: Can't convert to dimension: type=0x10
            mWidth = android_ta.getInt(2, ViewGroup.LayoutParams.MATCH_PARENT);
            mHeight = android_ta.getLayoutDimension(3, dpToPx(48));
        } finally {
            ta.recycle();
            android_ta.recycle();
        }
    }

    private void initDefaultColors() {
        colors.add(Color.BLACK);
        colors.add(Color.BLUE);
        colors.add(Color.RED);
        colors.add(Color.GREEN);
        colors.add(getResources().getColor(R.color.Orange));
        colors.add(Color.YELLOW);
        colors.add(getResources().getColor(R.color.Purple));
        colors.add(getResources().getColor(R.color.Brown));
    }

    private void initDefaultLineWidths() {
        lineWidths.add(4);
        lineWidths.add(6);
        lineWidths.add(8);
        lineWidths.add(10);
        lineWidths.add(12);
        lineWidths.add(14);
    }

    public void addColorChoice(int color) {
        colors.add(color);
    }

    public void setColorChoices(int[] colors) {
        this.colors.clear();
        for (int i = 0; i < colors.length; i++) {
            this.colors.add(colors[i]);
        }
    }

    public AnnotationToolbarItem getSelectedItem() {
        return this.selectedItem;
    }

    public void setSelectedItem(AnnotationToolbarItem item) {
        this.selectedItem = item;

        for (ActionListener listener : actionListeners) {
            listener.onAnnotationItemSelected(item);
        }
    }

    @Override
    protected LayoutParams generateDefaultLayoutParams() {
        return new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();

        if (menu == null) {
            menu = new AnnotationMenuView(getContext());
            menu.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, mHeight));
            menu.inflateMenu(R.xml.ot_main, this);

            HorizontalScrollView scrollView = new HorizontalScrollView(getContext());
            scrollView.setLayoutParams(new ViewGroup.LayoutParams(mWidth, mHeight));
            scrollView.setHorizontalScrollBarEnabled(false);
            scrollView.addView(menu);

            this.addView(scrollView);

            for (ActionListener listener : actionListeners) {
                listener.onCreateAnnotationMenu(menu);
            }

            ViewGroup.LayoutParams p = menu.getLayoutParams();
            p.height = mHeight; // Match the value passed in by the user
            menu.setLayoutParams(p);
        }
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        final int count = getChildCount();
        int curWidth, curHeight, curLeft, curTop, maxHeight;

        //get the available size of child view
        int childLeft = this.getPaddingLeft();
        int childTop = this.getPaddingTop();
        int childRight = this.getMeasuredWidth() - this.getPaddingRight();
        int childBottom = this.getMeasuredHeight() - this.getPaddingBottom();
        int childWidth = childRight - childLeft;
        int childHeight = childBottom - childTop;

        maxHeight = 0;
        curLeft = childLeft;
        curTop = childTop;
        //walk through each child, and arrange it from left to right
        for (int i = 0; i < count; i++) {
            View child = getChildAt(i);
            if (child.getVisibility() != GONE) {
                //Get the maximum size of the child
                child.measure(MeasureSpec.makeMeasureSpec(childWidth, MeasureSpec.AT_MOST),
                        MeasureSpec.makeMeasureSpec(childHeight, MeasureSpec.AT_MOST));
                curWidth = child.getMeasuredWidth();
                curHeight = child.getMeasuredHeight();
                //wrap is reach to the end
                if (curLeft + curWidth >= childRight) {
                    curLeft = childLeft;
                    curTop += maxHeight;
                    maxHeight = 0;
                }
                //do the layout
                child.layout(curLeft, curTop, curLeft + curWidth, curTop + curHeight);
                //store the max height
                if (maxHeight < curHeight)
                    maxHeight = curHeight;
                curLeft += curWidth;
            }
        }
    }

    public void addSignalListener(SignalListener listener) {
        this.signalListeners.add(listener);
    }

    public void addActionListener(ActionListener listener) {
        this.actionListeners.add(listener);
    }

    public void addScreenCaptureListener(ScreenCaptureListener listener) {
        this.captureListeners.add(listener);
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

    @Override
    public void didTapMenuItem(AnnotationToolbarMenuItem menuItem) {
        int id = menuItem.getItemId();

        if (id == R.id.ot_menu_colors) {
            Color.parseColor(menuItem.getColor());
            showColorSubmenu();
        } else if (id == R.id.ot_menu_line_width) {
            showLineWidthSubmenu();
        } else {
            showSubmenu(menuItem);
        }

        for (ActionListener listener : actionListeners) {
            listener.onAnnotationMenuItemSelected(menuItem);
        }
    }

    @Override
    public void didTapItem(AnnotationToolbarItem item) {
        hideSubmenu(); // If the submenu is visible
        this.selectedItem = item;
        for (ActionListener listener : actionListeners) {
            listener.onAnnotationItemSelected(item);
        }
    }

    public void didCaptureScreen(Bitmap capture, String connId) {
        for (ScreenCaptureListener listener : captureListeners) {
            listener.onScreenCapture(capture, connId);
        }
    }

    public interface ActionListener {
        public void onAnnotationMenuItemSelected(AnnotationToolbarMenuItem menuItem);
        public void onAnnotationItemSelected(AnnotationToolbarItem item);
        public boolean onCreateAnnotationMenu(AnnotationMenuView menu);
    }

    public interface ScreenCaptureListener {
        public void onScreenCapture(Bitmap screenCapture, String connectionId);
    }

    public interface SignalListener {
        void signalReceived(Session session, String type, String data, Connection connection);
    }

    void showColorSubmenu() {
        hideSubmenu();

        // Show color picker
        AnnotationMenuView colorToolbar = new AnnotationMenuView(getContext());
        colorToolbar.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, mHeight));
        HorizontalScrollView scrollView = new HorizontalScrollView(getContext());
        scrollView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        scrollView.setHorizontalScrollBarEnabled(false);
        scrollView.addView(colorToolbar);

        for (Integer dColor : colors) {
            final String color = String.format("#%06X", 0xFFFFFF & dColor);
            final AnnotationToolbarItem item = new AnnotationToolbarItem(getContext(), color);
            item.setColor(color);
            item.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    for (ActionListener listener : actionListeners) {
                        listener.onAnnotationItemSelected(item);
                    }

                    hideSubmenu();

                    // Update the main button color
                    for (int i = 0; i < menu.getChildCount(); i++) {
                        View itemView = menu.getChildAt(i);
                        if (itemView instanceof AnnotationToolbarMenuItem) {
                            AnnotationToolbarMenuItem menuItem = ((AnnotationToolbarMenuItem) itemView);
                            if (menuItem.getItemId() == R.id.ot_menu_colors) {
                                menuItem.setColor(color);
                            }
                        }
                    }
                }
            });
            colorToolbar.addView(item);
        }

        ViewGroup.LayoutParams p = this.getLayoutParams();
        p.height = 2*mHeight;
        this.setLayoutParams(p);

        this.addView(scrollView);
    }

    void showLineWidthSubmenu() {
        hideSubmenu();

        // Show color picker
        AnnotationMenuView colorToolbar = new AnnotationMenuView(getContext());
        colorToolbar.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, mHeight));
        HorizontalScrollView scrollView = new HorizontalScrollView(getContext());
        scrollView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        scrollView.setHorizontalScrollBarEnabled(false);
        scrollView.addView(colorToolbar);

        for (Integer width : lineWidths) {
            float tag = (float) width;
            String iconName = "line_" + width + "px";
            final AnnotationToolbarItem item = new AnnotationToolbarItem(getContext(), null, getDrawable(iconName));
            item.setTag(tag);
            item.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    for (ActionListener listener : actionListeners) {
                        listener.onAnnotationItemSelected(item);
                    }

                    hideSubmenu();
                }
            });
            colorToolbar.addView(item);
        }

        ViewGroup.LayoutParams p = this.getLayoutParams();
        p.height = 2 * mHeight;
        this.setLayoutParams(p);

        this.addView(scrollView);
    }

    private void showSubmenu(AnnotationToolbarMenuItem menuItem) {
        hideSubmenu();

        // Only add the submenu if it has items (menuItem.getItems().size() > 0)
        if (menuItem.getItems().size() > 0) {
            AnnotationMenuView subToolbar = new AnnotationMenuView(getContext());
            subToolbar.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, mHeight));
            HorizontalScrollView scrollView = new HorizontalScrollView(getContext());
            scrollView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
            scrollView.setHorizontalScrollBarEnabled(false);
            scrollView.addView(subToolbar);

            for (final AnnotationToolbarItem item : menuItem.getItems()) {
                item.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        for (ActionListener listener : actionListeners) {
                            listener.onAnnotationItemSelected(item);
                        }

                        hideSubmenu();
                    }
                });

                if (item.getParent() != null ) {
                    ((ViewGroup)item.getParent()).removeView(item);
                }
                subToolbar.addView(item);
            }

            ViewGroup.LayoutParams p = this.getLayoutParams();
            p.height = 2 * mHeight;
            this.setLayoutParams(p);

            this.addView(scrollView);
        }
    }

    private void hideSubmenu() {
        if (this.getChildCount() > 1) {
            // TODO Add an id to the submenu to ensure we remove the correct view?
            AnnotationToolbar.this.removeViewAt(AnnotationToolbar.this.getChildCount() - 1);

            ViewGroup.LayoutParams p = AnnotationToolbar.this.getLayoutParams();
            p.height = mHeight;
            AnnotationToolbar.this.setLayoutParams(p);
        }
    }

    public void attachSignal(Session session, String type, String data, Connection connection) {
        for (SignalListener listener : signalListeners) {
            listener.signalReceived(session, type, data, connection);
        }
    }

    public int getDrawable(String name) {
        Assert.assertNotNull(getContext());
        Assert.assertNotNull(name);

        return getContext().getResources().getIdentifier(name,
                "drawable", getContext().getPackageName());
    }

    /**
     * Layout information for child views of AnnotationToolbars.
     *
     * <p>AnnotationToolbar.LayoutParams extends Toolbar.LayoutParams for compatibility with existing
     * Toolbar API.
     */
    public static class LayoutParams extends Toolbar.LayoutParams {
        public LayoutParams(Context c, AttributeSet attrs) {
            super(c, attrs);
        }

        public LayoutParams(int width, int height) {
            super(width, height);
            this.gravity = Gravity.CENTER_VERTICAL | GravityCompat.START;
        }

        public LayoutParams(int width, int height, int gravity) {
            super(width, height);
            this.gravity = gravity;
        }

        public LayoutParams(int gravity) {
            this(WRAP_CONTENT, MATCH_PARENT, gravity);
        }

        public LayoutParams(LayoutParams source) {
            super(source);
        }

        public LayoutParams(ActionBar.LayoutParams source) {
            super(source);
        }

        public LayoutParams(MarginLayoutParams source) {
            super(source);
            // ActionBar.LayoutParams doesn't have a MarginLayoutParams constructor.
            // Fake it here and copy over the relevant data.
            copyMarginsFromCompat(source);
        }

        public LayoutParams(ViewGroup.LayoutParams source) {
            super(source);
        }

        void copyMarginsFromCompat(MarginLayoutParams source) {
            this.leftMargin = source.leftMargin;
            this.topMargin = source.topMargin;
            this.rightMargin = source.rightMargin;
            this.bottomMargin = source.bottomMargin;
        }
    }

    static class SavedState extends BaseSavedState {
        public int expandedMenuItemId;
        public boolean isOverflowOpen;

        public SavedState(Parcel source) {
            super(source);
            expandedMenuItemId = source.readInt();
            isOverflowOpen = source.readInt() != 0;
        }

        public SavedState(Parcelable superState) {
            super(superState);
        }

        @Override
        public void writeToParcel(Parcel out, int flags) {
            super.writeToParcel(out, flags);
            out.writeInt(expandedMenuItemId);
            out.writeInt(isOverflowOpen ? 1 : 0);
        }

        public static final Creator<SavedState> CREATOR = new Creator<SavedState>() {

            @Override
            public SavedState createFromParcel(Parcel source) {
                return new SavedState(source);
            }

            @Override
            public SavedState[] newArray(int size) {
                return new SavedState[size];
            }
        };
    }
}
