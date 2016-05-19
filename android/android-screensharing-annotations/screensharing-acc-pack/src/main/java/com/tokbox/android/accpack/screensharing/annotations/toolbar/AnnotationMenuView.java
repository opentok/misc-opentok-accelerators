package com.tokbox.android.accpack.screensharing.annotations.toolbar;


import android.content.Context;
import android.content.res.Configuration;
import android.support.v7.view.menu.MenuBuilder;
import android.support.v7.view.menu.MenuItemImpl;
import android.support.v7.view.menu.MenuView;
import android.util.AttributeSet;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewDebug;
import android.view.ViewGroup;
import android.view.accessibility.AccessibilityEvent;
import android.widget.ImageButton;
import android.widget.LinearLayout;

import java.util.ArrayList;
import java.util.List;

public class AnnotationMenuView extends LinearLayout implements MenuBuilder.ItemInvoker, MenuView {
    private static final String TAG = "AnnotationMenuView";

    private MenuBuilder mMenu;

    static final int MIN_CELL_SIZE = 56; // dips
    static final int GENERATED_ITEM_PADDING = 4; // dips

    private boolean mFormatItems;
    private int mFormatItemsWidth;
    private int mMinCellSize;
    private int mGeneratedItemPadding;
    private int mMeasuredExtraWidth;
    private int mMaxItemHeight;

    public AnnotationMenuView(Context context) {
        this(context, null);
    }

    public AnnotationMenuView(Context context, AttributeSet attrs) {
        super(context, attrs);
        setBaselineAligned(false);
        final float density = context.getResources().getDisplayMetrics().density;
        mMinCellSize = (int) (MIN_CELL_SIZE * density);
        mGeneratedItemPadding = (int) (GENERATED_ITEM_PADDING * density);

    }

//    public void setPresenter(ActionMenuPresenter presenter) {
//        mPresenter = presenter;
//    }

    public void setMaxItemHeight(int maxItemHeight) {
        mMaxItemHeight = maxItemHeight;
        requestLayout();
    }

    public void inflateMenu(int menuId, AnnotationMenuInflator.ActionListener listener) {
        AnnotationMenuInflator.inflate(getContext(), menuId, this, listener);
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
//        mPresenter.updateMenuView(false);
//
//        if (mPresenter != null && mPresenter.isOverflowMenuShowing()) {
//            mPresenter.hideOverflowMenu();
//            mPresenter.showOverflowMenu();
//        }
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        // If we've been given an exact size to match, apply special formatting during layout.
        final boolean wasFormatted = mFormatItems;
        mFormatItems = MeasureSpec.getMode(widthMeasureSpec) == MeasureSpec.EXACTLY;

        if (wasFormatted != mFormatItems) {
            mFormatItemsWidth = 0; // Reset this when switching modes
        }

        // Special formatting can change whether items can fit as action buttons.
        // Kick the menu and update presenters when this changes.
        final int widthSize = MeasureSpec.getMode(widthMeasureSpec);
        if (mFormatItems && mMenu != null && widthSize != mFormatItemsWidth) {
            mFormatItemsWidth = widthSize;
            mMenu.onItemsChanged(true);
        }

        if (mFormatItems) {
            onMeasureExactFormat(widthMeasureSpec, heightMeasureSpec);
        } else {
            // Previous measurement at exact format may have set margins - reset them.
            final int childCount = getChildCount();
            for (int i = 0; i < childCount; i++) {
                final View child = getChildAt(i);
                final LayoutParams lp = (LayoutParams) child.getLayoutParams();
                lp.gravity = Gravity.CENTER_VERTICAL;
                lp.leftMargin = lp.rightMargin = 10;
            }
            super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        }
    }

    private void onMeasureExactFormat(int widthMeasureSpec, int heightMeasureSpec) {
        // We already know the width mode is EXACTLY if we're here.
        final int heightMode = MeasureSpec.getMode(heightMeasureSpec);
        int widthSize = MeasureSpec.getSize(widthMeasureSpec);
        int heightSize = MeasureSpec.getSize(heightMeasureSpec);

        final int widthPadding = getPaddingLeft() + getPaddingRight();
        final int heightPadding = getPaddingTop() + getPaddingBottom();

        final int itemHeightSpec = heightMode == MeasureSpec.EXACTLY
                ? MeasureSpec.makeMeasureSpec(heightSize - heightPadding, MeasureSpec.EXACTLY)
                : MeasureSpec.makeMeasureSpec(
                Math.min(mMaxItemHeight, heightSize - heightPadding), MeasureSpec.AT_MOST);

        widthSize -= widthPadding;

        // Divide the view into cells.
        final int cellCount = widthSize / mMinCellSize;
        final int cellSizeRemaining = widthSize % mMinCellSize;

        if (cellCount == 0) {
            // Give up, nothing fits.
            setMeasuredDimension(widthSize, 0);
            return;
        }

        final int cellSize = mMinCellSize + cellSizeRemaining / cellCount;

        int cellsRemaining = cellCount;
        int maxChildHeight = 0;
        int maxCellsUsed = 0;
        int visibleItemCount = 0;

        // This is used as a bitfield to locate the smallest items present. Assumes childCount < 64.
        long smallestItemsAt = 0;

        final int childCount = getChildCount();
        for (int i = 0; i < childCount; i++) {
            final View child = getChildAt(i);
            if (child.getVisibility() == GONE) continue;

            final boolean isGeneratedItem = child instanceof AnnotationToolbarMenuItem;
            visibleItemCount++;

            if (isGeneratedItem) {
                // Reset padding for generated menu item views; it may change below
                // and views are recycled.
                child.setPadding(mGeneratedItemPadding, 0, mGeneratedItemPadding, 0);
            }

            final LayoutParams lp = (LayoutParams) child.getLayoutParams();
            lp.extraPixels = 0;
            lp.cellsUsed = 0;
            lp.leftMargin = 0;
            lp.rightMargin = 0;
//            lp.preventEdgeOffset = isGeneratedItem && ((AnnotationsToolbarMenuItem) child).hasText();

            final int cellsAvailable = cellsRemaining;

            final int cellsUsed = measureChildForCells(child, cellSize, cellsAvailable,
                    itemHeightSpec, heightPadding);

            maxCellsUsed = Math.max(maxCellsUsed, cellsUsed);

            cellsRemaining -= cellsUsed;
            maxChildHeight = Math.max(maxChildHeight, child.getMeasuredHeight());
            if (cellsUsed == 1) smallestItemsAt |= (1 << i);
        }

        // Divide space for remaining cells if we have items that can expand.
        // Try distributing whole leftover cells to smaller items first.

        boolean needsExpansion = false;
        while (cellsRemaining > 0) {
            int minCells = Integer.MAX_VALUE;
            long minCellsAt = 0; // Bit locations are indices of relevant child views
            int minCellsItemCount = 0;
            for (int i = 0; i < childCount; i++) {
                final View child = getChildAt(i);
                final LayoutParams lp = (LayoutParams) child.getLayoutParams();

                // Mark indices of children that can receive an extra cell.
                if (lp.cellsUsed < minCells) {
                    minCells = lp.cellsUsed;
                    minCellsAt = 1 << i;
                    minCellsItemCount = 1;
                } else if (lp.cellsUsed == minCells) {
                    minCellsAt |= 1 << i;
                    minCellsItemCount++;
                }
            }

            // Items that get expanded will always be in the set of smallest items when we're done.
            smallestItemsAt |= minCellsAt;

            if (minCellsItemCount > cellsRemaining) break; // Couldn't expand anything evenly. Stop.

            // We have enough cells, all minimum size items will be incremented.
            minCells++;

            for (int i = 0; i < childCount; i++) {
                final View child = getChildAt(i);
                final LayoutParams lp = (LayoutParams) child.getLayoutParams();
                if ((minCellsAt & (1 << i)) == 0) {
                    // If this item is already at our small item count, mark it for later.
                    if (lp.cellsUsed == minCells) smallestItemsAt |= 1 << i;
                    continue;
                }

                if (lp.preventEdgeOffset && cellsRemaining == 1) {
                    // Add padding to this item such that it centers.
                    child.setPadding(mGeneratedItemPadding + cellSize, 0, mGeneratedItemPadding, 0);
                }
                lp.cellsUsed++;
                cellsRemaining--;
            }

            needsExpansion = true;
        }

        // Divide any space left that wouldn't divide along cell boundaries
        // evenly among the smallest items

        final boolean singleItem = visibleItemCount == 1;
        if (cellsRemaining > 0 && smallestItemsAt != 0 &&
                (cellsRemaining < visibleItemCount - 1 || singleItem || maxCellsUsed > 1)) {
            float expandCount = Long.bitCount(smallestItemsAt);

            if (!singleItem) {
                // The items at the far edges may only expand by half in order to pin to either side.
                if ((smallestItemsAt & 1) != 0) {
                    LayoutParams lp = (LayoutParams) getChildAt(0).getLayoutParams();
                    if (!lp.preventEdgeOffset) expandCount -= 0.5f;
                }
                if ((smallestItemsAt & (1 << (childCount - 1))) != 0) {
                    LayoutParams lp = ((LayoutParams) getChildAt(childCount - 1).getLayoutParams());
                    if (!lp.preventEdgeOffset) expandCount -= 0.5f;
                }
            }

            final int extraPixels = expandCount > 0 ?
                    (int) (cellsRemaining * cellSize / expandCount) : 0;

            for (int i = 0; i < childCount; i++) {
                if ((smallestItemsAt & (1 << i)) == 0) continue;

                final View child = getChildAt(i);
                final LayoutParams lp = (LayoutParams) child.getLayoutParams();
                if (child instanceof AnnotationToolbarMenuItem || child instanceof AnnotationToolbarItem) {
                    // If this is one of our views, expand and measure at the larger size.
                    lp.extraPixels = extraPixels;
                    if (i == 0 && !lp.preventEdgeOffset) {
                        // First item gets part of its new padding pushed out of sight.
                        // The last item will get this implicitly from layout.
                        lp.leftMargin = -extraPixels / 2;
                    }
                    needsExpansion = true;
                } else {
                    // If we don't know what it is, give it some margins instead
                    // and let it center within its space. We still want to pin
                    // against the edges.
                    if (i != 0) {
                        lp.leftMargin = extraPixels / 2;
                    }
                    if (i != childCount - 1) {
                        lp.rightMargin = extraPixels / 2;
                    }
                }
            }

            cellsRemaining = 0;
        }

        // Remeasure any items that have had extra space allocated to them.
        if (needsExpansion) {
            for (int i = 0; i < childCount; i++) {
                final View child = getChildAt(i);
                final LayoutParams lp = (LayoutParams) child.getLayoutParams();

                final int width = lp.cellsUsed * cellSize + lp.extraPixels;
                child.measure(MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY),
                        itemHeightSpec);
            }
        }

        if (heightMode != MeasureSpec.EXACTLY) {
            heightSize = maxChildHeight;
        }

        setMeasuredDimension(widthSize, heightSize);
        mMeasuredExtraWidth = cellsRemaining * cellSize;
    }

    /**
     * Measure a child view to fit within cell-based formatting. The child's width
     * will be measured to a whole multiple of cellSize.
     *
     * <p>Sets the expandable and cellsUsed fields of LayoutParams.
     *
     * @param child Child to measure
     * @param cellSize Size of one cell
     * @param cellsRemaining Number of cells remaining that this view can expand to fill
     * @param parentHeightMeasureSpec MeasureSpec used by the parent view
     * @param parentHeightPadding Padding present in the parent view
     * @return Number of cells this child was measured to occupy
     */
    static int measureChildForCells(View child, int cellSize, int cellsRemaining,
                                    int parentHeightMeasureSpec, int parentHeightPadding) {
        final LayoutParams lp = (LayoutParams) child.getLayoutParams();

        final int childHeightSize = MeasureSpec.getSize(parentHeightMeasureSpec) -
                parentHeightPadding;
        final int childHeightMode = MeasureSpec.getMode(parentHeightMeasureSpec);
        final int childHeightSpec = MeasureSpec.makeMeasureSpec(childHeightSize, childHeightMode);

        final ImageButton itemView = child instanceof AnnotationToolbarMenuItem ?
                (AnnotationToolbarMenuItem) child : child instanceof AnnotationToolbarItem ?
                (AnnotationToolbarItem) child : null;

        int cellsUsed = 0;
        if (cellsRemaining > 0) {
            final int childWidthSpec = MeasureSpec.makeMeasureSpec(
                    cellSize * cellsRemaining, MeasureSpec.AT_MOST);
            child.measure(childWidthSpec, childHeightSpec);

            final int measuredWidth = child.getMeasuredWidth();
            cellsUsed = measuredWidth / cellSize;
            if (measuredWidth % cellSize != 0) cellsUsed++;
            if (cellsUsed < 2) cellsUsed = 2;
        }

        lp.cellsUsed = cellsUsed;
        final int targetWidth = cellsUsed * cellSize;
        child.measure(MeasureSpec.makeMeasureSpec(targetWidth, MeasureSpec.EXACTLY),
                childHeightSpec);
        return cellsUsed;
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        if (!mFormatItems) {
            super.onLayout(changed, left, top, right, bottom);
            return;
        }

        final int childCount = getChildCount();
        final int midVertical = (top + bottom) / 2;
        Log.i("AnnotationMenuView", "Dimens: " + top + ", " + midVertical + ", " + bottom);
        int itemWidth = 0;
        int count = 0;
        int widthRemaining = right - left - getPaddingRight() - getPaddingLeft();

        final boolean isLayoutRtl = false;//isLayoutRtl();
        for (int i = 0; i < childCount; i++) {
            final View v = getChildAt(i);
            if (v.getVisibility() == GONE) {
                continue;
            }

            LayoutParams p = (LayoutParams) v.getLayoutParams();
            final int size = v.getMeasuredWidth() + p.leftMargin + p.rightMargin;
            itemWidth += size;
            widthRemaining -= size;
            count++;
        }

        if (childCount == 1) {
            // Center a single child
            final View v = getChildAt(0);
            final int width = v.getMeasuredWidth();
            final int height = v.getMeasuredHeight();
            final int midHorizontal = (right - left) / 2;
            final int l = midHorizontal - width / 2;
            final int t = midVertical - height / 2;
            v.layout(l, t, l + width, t + height);
            return;
        }

        final int spacerCount = count - 1;
        final int spacerSize = Math.max(0, spacerCount > 0 ? widthRemaining / spacerCount : 0);

        if (isLayoutRtl) {
            int startRight = getWidth() - getPaddingRight();
            for (int i = 0; i < childCount; i++) {
                final View v = getChildAt(i);
                final LayoutParams lp = (LayoutParams) v.getLayoutParams();
                if (v.getVisibility() == GONE) {
                    continue;
                }

                startRight -= lp.rightMargin;
                int width = v.getMeasuredWidth();
                int height = v.getMeasuredHeight();
                int t = midVertical - height / 2;
                v.layout(startRight - width, t, startRight, t + height);
                startRight -= width + lp.leftMargin + spacerSize;
            }
        } else {
            int startLeft = getPaddingLeft();
            for (int i = 0; i < childCount; i++) {
                final View v = getChildAt(i);
                final LayoutParams lp = (LayoutParams) v.getLayoutParams();
                if (v.getVisibility() == GONE) {
                    continue;
                }

                startLeft += lp.leftMargin;
                int width = v.getMeasuredWidth();
                int height = v.getMeasuredHeight();
                int t = midVertical - height / 2;
                v.layout(startLeft, t, startLeft + width, t + height);
                startLeft += width + lp.rightMargin + spacerSize;
            }
        }
    }

    @Override
    public void onDetachedFromWindow() {
        super.onDetachedFromWindow();
//        mPresenter.dismissPopupMenus();
    }

    @Override
    protected LayoutParams generateDefaultLayoutParams() {
        LayoutParams params = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
        params.gravity = Gravity.CENTER_VERTICAL;
        return params;
    }

    @Override
    public LayoutParams generateLayoutParams(AttributeSet attrs) {
        return new LayoutParams(getContext(), attrs);
    }

    @Override
    protected LayoutParams generateLayoutParams(ViewGroup.LayoutParams p) {
        if (p != null) {
            final LayoutParams result = p instanceof LayoutParams
                    ? new LayoutParams((LayoutParams) p)
                    : new LayoutParams(p);
            if (result.gravity <= Gravity.NO_GRAVITY) {
                result.gravity = Gravity.CENTER_VERTICAL;
            }
            return result;
        }
        return generateDefaultLayoutParams();
    }

    @Override
    protected boolean checkLayoutParams(ViewGroup.LayoutParams p) {
        return p != null && p instanceof LayoutParams;
    }

    public List<AnnotationToolbarItem> getItems() {
        List<AnnotationToolbarItem> items = new ArrayList<AnnotationToolbarItem>();

        for (int i = 0; i < this.getChildCount(); i++) {
            View v = this.getChildAt(i);
            if (v instanceof AnnotationToolbarItem) {
                items.add((AnnotationToolbarItem) v);
            }
        }

        return items;
    }

    public List<AnnotationToolbarMenuItem> getMenuItems() {
        List<AnnotationToolbarMenuItem> items = new ArrayList<AnnotationToolbarMenuItem>();

        for (int i = 0; i < this.getChildCount(); i++) {
            View v = this.getChildAt(i);
            if (v instanceof AnnotationToolbarMenuItem) {
                items.add((AnnotationToolbarMenuItem) v);
            }
        }

        return items;
    }

    @Override
    public boolean invokeItem(MenuItemImpl item) {
        return mMenu.performItemAction(item, 0);
    }

    public int getWindowAnimations() {
        return 0;
    }

    public void initialize(MenuBuilder menu) {
        mMenu = menu;
    }

    public boolean dispatchPopulateAccessibilityEvent(AccessibilityEvent event) {
        return false;
    }

    public static class LayoutParams extends LinearLayout.LayoutParams {
        @ViewDebug.ExportedProperty(category = "layout")
        public int cellsUsed;
        @ViewDebug.ExportedProperty(category = "layout")
        public int extraPixels;
        @ViewDebug.ExportedProperty(category = "layout")
        public boolean preventEdgeOffset;

        public LayoutParams(Context c, AttributeSet attrs) {
            super(c, attrs);
        }

        public LayoutParams(ViewGroup.LayoutParams other) {
            super(other);
        }

        public LayoutParams(int width, int height) {
            super(width, height);
        }
    }
}
