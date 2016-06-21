package com.tokbox.android.accpack.textchat;


import android.content.Context;
import android.test.AndroidTestCase;

public class TestBase extends AndroidTestCase {
    protected Context context;

    protected void setUp() throws Exception {
        super.setUp();
        context = getContext();
    }

    protected void tearDown() throws Exception {
        super.tearDown();
    }

}