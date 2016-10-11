package com.tokbox.android.annotations.test;

import android.graphics.Paint;
import android.widget.EditText;

import com.tokbox.android.annotations.Annotatable;
import com.tokbox.android.annotations.AnnotationsPath;
import com.tokbox.android.annotations.AnnotationsText;
import com.tokbox.android.annotations.AnnotationsView;
import com.tokbox.android.annotations.testbase.TestBase;

import junit.framework.Assert;

//import org.junit.Assert;

import java.lang.Integer;

public class AnnotatableTest extends TestBase{

    private AnnotationsView.Mode mode;
    private AnnotationsPath path;
    private AnnotationsText text;
    private Paint paint;
    private int canvasWidth = 1;
    private int canvasHeight = 1;
    private String cid;

    protected void setUp() throws Exception {
        super.setUp();

        path = new AnnotationsPath();
        paint = new Paint();
        text = new AnnotationsText(new EditText(context), 1.0f, 1.0f);
        cid = "123456789-asdfghjkl";
        mode = AnnotationsView.Mode.Pen;
    }

    protected void tearDown() throws Exception {
        super.tearDown();
    }


    public void testNewAnnotatablePath() throws Exception {
        Annotatable annotatable = new Annotatable(mode, path, paint, canvasWidth, canvasHeight, cid);

        Assert.assertNotNull(annotatable);

        Assert.assertEquals(annotatable.getMode(), mode);
        Assert.assertEquals(annotatable.getPath(), path);
        Assert.assertEquals(annotatable.getPaint(), paint);
        Assert.assertEquals(annotatable.getCanvasWidth(), canvasWidth);
        Assert.assertEquals(annotatable.getCanvasHeight(), canvasHeight);
        Assert.assertEquals(annotatable.getCId(), cid);
    }

    public void testNewAnnotatablePathWithNullPath() {
        Annotatable annotatable = null;
        path = null;
        try {
            annotatable  = new Annotatable(mode, path, paint, canvasWidth, canvasHeight, cid);
            Assert.fail("Should have thrown an exception with null path.");
        }catch (Exception e){
            Assert.assertNull(annotatable);
        }
    }

    public void testNewAnnotatablePathWithNullCid() {
        Annotatable annotatable = null;
        try {
            annotatable  = new Annotatable(mode, path, paint, canvasWidth, canvasHeight, null);
            Assert.fail("Should have thrown an exception with null connectionId.");
        }catch (Exception e){
            Assert.assertNull(annotatable);
        }
    }

    public void testNewAnnotatablePathWithNullPaint() {
        Annotatable annotatable = null;
        try {
            annotatable  = new Annotatable(mode, path, null, canvasWidth, canvasHeight, cid);
            Assert.fail("Should have thrown an exception with null paint.");
        }catch (Exception e){
            Assert.assertNull(annotatable);
        }
    }

    public void testNewAnnotatablePathWithNullMode() {
        Annotatable annotatable = null;
        try {
            annotatable  = new Annotatable(null, path, paint, canvasWidth, canvasHeight, cid);
            Assert.fail("Should have thrown an exception with null mode.");
        }catch (Exception e){
            Assert.assertNull(annotatable);
        }
    }

    public void testNewAnnotatablePathWithMaxHeight() throws Exception {

        canvasHeight = Integer.MAX_VALUE;
        Annotatable annotatable = null;
        try {
            annotatable  = new Annotatable(mode, path, paint, canvasWidth, canvasHeight, cid);
            Assert.fail("Should have thrown an exception when canvas height is higher Integer.MAX_VALUE");
        }catch (Exception e){
            Assert.assertNull(annotatable);
        }
    }

    public void testNewAnnotatablePathWithMaxWidht() throws Exception {

        canvasWidth = Integer.MAX_VALUE;
        Annotatable annotatable = null;
        try {
            annotatable  = new Annotatable(mode, path, paint, canvasWidth, canvasHeight, cid);
            Assert.fail("Should have thrown an exception when canvas height is higher Integer.MAX_VALUE");
        }catch (Exception e){
            Assert.assertNull(annotatable);
        }
    }

    public void testNewAnnotatablePathWithCanvasHeightLowerThanZero() throws Exception {

        canvasHeight = -1;

        Annotatable annotatable = null;
        try {
            annotatable  = new Annotatable(mode, path, paint, canvasWidth, canvasHeight, cid);
            Assert.fail("Should have thrown an exception when canvas height is lower than 0");
        }catch (Exception e){
            Assert.assertNull(annotatable);
        }
    }

    public void testNewAnnotatablePathWithCanvasWidthLowerThanZero() throws Exception {

        canvasWidth = -1;

        Annotatable annotatable = null;
        try {
            annotatable  = new Annotatable(mode, path, paint, canvasWidth, canvasHeight, cid);
            Assert.fail("Should have thrown an exception when canvas width is lower than 0");
        }catch (Exception e){
            Assert.assertNull(annotatable);
        }
    }

    public void testNewAnnotatableText() throws Exception {
        mode = AnnotationsView.Mode.Text;
        Annotatable annotatable = new Annotatable(mode, text, paint, canvasWidth, canvasHeight, cid);

        Assert.assertNotNull(annotatable);

        Assert.assertEquals(annotatable.getMode(), mode);
        Assert.assertEquals(annotatable.getText(), text);
        Assert.assertEquals(annotatable.getPaint(), paint);
        Assert.assertEquals(annotatable.getCanvasWidth(), canvasWidth);
        Assert.assertEquals(annotatable.getCanvasHeight(), canvasHeight);
        Assert.assertEquals(annotatable.getCId(), cid);
    }

    public void testNewAnnotatableTextWithNullPath() {
        Annotatable annotatable = null;
        path = null;
        mode = AnnotationsView.Mode.Text;
        try {
            annotatable  = new Annotatable(mode, path, paint, canvasWidth, canvasHeight, cid);
            Assert.fail("Should have thrown an exception with null path.");
        }catch (Exception e){
            Assert.assertNull(annotatable);
        }
    }

    public void testNewAnnotatableTextWithNullCid() {
        Annotatable annotatable = null;
        mode = AnnotationsView.Mode.Text;
        try {
            annotatable  = new Annotatable(mode, text, paint, canvasWidth, canvasHeight, null);
            Assert.fail("Should have thrown an exception with null connectionId.");
        }catch (Exception e){
            Assert.assertNull(annotatable);
        }
    }

    public void testNewAnnotatableTextWithNullPaint() {
        Annotatable annotatable = null;
        mode = AnnotationsView.Mode.Text;
        try {
            annotatable  = new Annotatable(mode, text, null, canvasWidth, canvasHeight, cid);
            Assert.fail("Should have thrown an exception with null paint.");
        }catch (Exception e){
            Assert.assertNull(annotatable);
        }
    }

    public void testNewAnnotatableTextWithNullMode() {
        Annotatable annotatable = null;
        mode = AnnotationsView.Mode.Text;
        try {
            annotatable  = new Annotatable(null, text, paint, canvasWidth, canvasHeight, cid);
            Assert.fail("Should have thrown an exception with null mode.");
        }catch (Exception e){
            Assert.assertNull(annotatable);
        }
    }

    public void testNewAnnotatableTextWithMaxHeight() throws Exception {
        Annotatable annotatable = null;
        canvasHeight = Integer.MAX_VALUE;
        mode = AnnotationsView.Mode.Text;
        try {
            annotatable  = new Annotatable(mode, text, paint, canvasWidth, canvasHeight, cid);
            Assert.fail("Should have thrown an exception when canvas height is higher Integer.MAX_VALUE");
        }catch (Exception e){
            Assert.assertNull(annotatable);
        }
    }

    public void testNewAnnotatableTextWithMaxWidht() throws Exception {
        Annotatable annotatable = null;
        canvasWidth = Integer.MAX_VALUE;
        mode = AnnotationsView.Mode.Text;
        try {
            annotatable  = new Annotatable(mode, text, paint, canvasWidth, canvasHeight, cid);
            Assert.fail("Should have thrown an exception when canvas height is higher Integer.MAX_VALUE");
        }catch (Exception e){
            Assert.assertNull(annotatable);
        }
    }

    public void testNewAnnotatableTextWithCanvasHeightLowerThanZero() throws Exception {

        canvasHeight = -1;
        mode = AnnotationsView.Mode.Text;
        Annotatable annotatable = null;
        try {
            annotatable  = new Annotatable(mode, text, paint, canvasWidth, canvasHeight, cid);
            Assert.fail("Should have thrown an exception when canvas height is lower than 0");
        }catch (Exception e){
            Assert.assertNull(annotatable);
        }
    }

    public void testNewAnnotatableTextWithCanvasWidthLowerThanZero() throws Exception {
        Annotatable annotatable = null;
        canvasWidth = -1;
        mode = AnnotationsView.Mode.Text;
        try {
            annotatable  = new Annotatable(mode, text, paint, canvasWidth, canvasHeight, cid);
            Assert.fail("Should have thrown an exception when canvas width is lower than 0");
        }catch (Exception e){
            Assert.assertNull(annotatable);
        }
    }

    public void testSetMode() throws Exception {
        Annotatable annotatable = new Annotatable(mode, text, paint, canvasWidth, canvasHeight, cid);
        annotatable.setMode(AnnotationsView.Mode.Capture);
    }

    public void testSetModeNull() throws Exception {
        Annotatable annotatable = null;
        try {
            annotatable  = new Annotatable(mode, text, paint, canvasWidth, canvasHeight, cid);
            annotatable.setMode(null);
            Assert.fail("Should have thrown an exception when mode is null");
        }catch (Exception e){
            Assert.assertNotNull(annotatable.getMode());
        }
    }
}
