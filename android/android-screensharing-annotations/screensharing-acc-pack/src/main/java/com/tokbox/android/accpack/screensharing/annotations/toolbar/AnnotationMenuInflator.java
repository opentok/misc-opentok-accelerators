package com.tokbox.android.accpack.screensharing.annotations.toolbar;

import android.content.Context;
import android.content.res.TypedArray;
import android.content.res.XmlResourceParser;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.util.Xml;
import android.view.InflateException;
import android.view.View;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.tokbox.android.accpack.screensharing.R;

class AnnotationMenuInflator {
    /** MenuItem tag name in XML. */
    private static final String XML_MENU = "menu-item";

    /** Item tag name in XML. */
    private static final String XML_ITEM = "item";

    private static Context mContext;
    private static ActionListener mListener;

    public interface ActionListener {
        public void didTapMenuItem(AnnotationToolbarMenuItem menuItem);
        public void didTapItem(AnnotationToolbarItem item);
    }

    public static void inflate(Context context, int menuRes, AnnotationMenuView menu, ActionListener listener) {
        // Make sure we remove all previous menu items
        menu.removeAllViews();

        mContext = context;
        mListener = listener;

        XmlResourceParser parser = null;
        try {
            parser = context.getResources().getLayout(menuRes);
            AttributeSet attrs = Xml.asAttributeSet(parser);

            parseMenu(parser, attrs, menu);
        } catch (XmlPullParserException e) {
            throw new InflateException("Error inflating annotation menu XML", e);
        } catch (IOException e) {
            throw new InflateException("Error inflating annotation menu XML", e);
        } finally {
            if (parser != null) parser.close();
        }
    }

    private static void parseMenu(XmlResourceParser xrp, AttributeSet attrs, AnnotationMenuView menu) throws XmlPullParserException, IOException {
        int[] attrsArray = new int[]{
                android.R.attr.id,
                R.attr.icon
        };

        TypedArray a = mContext.obtainStyledAttributes(attrs, attrsArray, 0, 0);

        xrp.next();
        int eventType = xrp.getEventType();
        while (eventType != XmlPullParser.END_DOCUMENT) {
            if (eventType == XmlPullParser.START_TAG) {
                if (xrp.getName().equalsIgnoreCase(XML_MENU)) {
                    AnnotationToolbarMenuItem menuItem = null;
                    List<AnnotationToolbarItem> items = new ArrayList<AnnotationToolbarItem>();

                    attrs = Xml.asAttributeSet(xrp);
                    a = mContext.obtainStyledAttributes(attrs, attrsArray, 0, 0);

                    int id = a.getResourceId(0, -1);
                    Drawable icon = a.getDrawable(1);

//                    Log.i("AnnotationsToolbar", "Found menu item: " + id);

                    // Iterate through the <item>s until we reach an end tag
                    do {
                        eventType = xrp.next();

                        if (eventType == XmlPullParser.START_TAG && xrp.getName().equalsIgnoreCase(XML_ITEM)) {
                            attrs = Xml.asAttributeSet(xrp);
                            a = mContext.obtainStyledAttributes(attrs, attrsArray, 0, 0);

                            int itemId = a.getResourceId(0, -1);
                            Drawable itemIcon = a.getDrawable(1);

//                            Log.i("AnnotationsToolbar", "Found submenu item: " + itemId);

                            FloatPoint[] points = null;
                            boolean curved = false;

                            if (itemId == R.id.ot_item_arrow) {
                                points = AnnotationShapes.arrowPoints;
                            } else if (itemId == R.id.ot_item_rectangle) {
                                points = AnnotationShapes.rectanglePoints;
                            } else if (itemId == R.id.ot_item_oval) {
                                points = AnnotationShapes.circlePoints;
                                curved = true;
                            }

                            AnnotationToolbarItem item = new AnnotationToolbarItem(mContext, points, itemIcon);
                            item.setItemId(itemId);
                            item.setSmoothDrawEnabled(curved);
                            items.add(item);
                        } else if (eventType == XmlPullParser.START_TAG && xrp.getName().equalsIgnoreCase(XML_MENU)) {
                            // TODO Handle submenu items (we only want to handle a single level of
                            // TODO menu items, so notify the dev that this isn't supported and convert
                            // TODO this to an AnnotationToolbarItem, ignoring any inner items
                        }
                    } while (xrp.getName().equalsIgnoreCase(XML_ITEM)); // FIXME Should be !XML_MENU end tag without running into an inner menu_item

                    if (id == R.id.ot_menu_colors) {
                        // TODO Use tintColor to handle this?
                        final AnnotationToolbarMenuItem item = menuItem = new AnnotationToolbarMenuItem(mContext, null);
                        menuItem.setColor("#ff0000");
                        menuItem.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                if (mListener != null) {
                                    mListener.didTapMenuItem(item);
                                }
                            }
                        });
                        menuItem.setItemId(id);
                        menuItem.setItems(items);
                        menu.addView(menuItem);
                    } else {
                        final AnnotationToolbarMenuItem item = menuItem = new AnnotationToolbarMenuItem(mContext, icon);
                        menuItem.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                if (mListener != null) {
                                    mListener.didTapMenuItem(item);
                                }
                            }
                        });
                        menuItem.setItemId(id);
                        menuItem.setItems(items);
                        menu.addView(menuItem);
                    }
                } else if (xrp.getName().equalsIgnoreCase("item")) {
                    attrs = Xml.asAttributeSet(xrp);
                    a = mContext.obtainStyledAttributes(attrs, attrsArray, 0, 0);

                    int id = a.getResourceId(0, -1);
                    Drawable icon = a.getDrawable(1);

//                    Log.i("AnnotationsToolbar", "Found item: " + id);

                    if (id == R.id.ot_item_line) {
                        final AnnotationToolbarItem item = new AnnotationToolbarItem(mContext, AnnotationShapes.linePoints, icon);
                        item.setItemId(id);
                        item.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                if (mListener != null) {
                                    mListener.didTapItem(item);
                                }
                            }
                        });
                        menu.addView(item);
                    } else {
                        final AnnotationToolbarItem item = new AnnotationToolbarItem(mContext, null, icon);
                        item.setItemId(id);
                        item.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                if (mListener != null) {
                                    mListener.didTapItem(item);
                                }
                            }
                        });
                        menu.addView(item);
                    }
                }
            }
            eventType = xrp.next();
        }

        a.recycle();
    }
}
