package com.tokbox.android.textchatsample;

import android.content.Context;

import com.tokbox.android.textchatsample.OneToOneCommunication;
import com.tokbox.android.textchatsample.config.OpenTokConfig;

import org.junit.Test;
import 	android.test.mock.MockContext;

import java.lang.reflect.Field;
import java.lang.reflect.Modifier;

public class OneToOneCommunicationTest{

    //Assert init
    @Test
    public void init_Test_When_OK() throws Exception {

        Field modifiersField = Field.class.getDeclaredField("modifiers");
        modifiersField.setAccessible(true);
        modifiersField.setInt(OpenTokConfig.class.getField("SESSION_ID"), OpenTokConfig.class.getField("SESSION_ID").getModifiers() & ~Modifier.FINAL);

        OpenTokConfig.class.getField("SESSION_ID").set(null, "here the session  ID");

        MockContext context = new MockContext();

        OneToOneCommunication oneToOneCommunication = new OneToOneCommunication(context);


    }

    @Test
    public void init_Test_When_API_Key_Null() throws Exception {

        MockContext context = new MockContext();

        OneToOneCommunication oneToOneCommunication = new OneToOneCommunication(context);


    }

    @Test
    public void init_Test_When_Session_ID_Null() throws Exception {

        MockContext context = new MockContext();

        OneToOneCommunication oneToOneCommunication = new OneToOneCommunication(context);


    }

    @Test
    public void init_Test_When_Token_Null() throws Exception {

        MockContext context = new MockContext();

        OneToOneCommunication oneToOneCommunication = new OneToOneCommunication(context);


    }

    @Test
    public void init_Test_When_API_Key_Empty() throws Exception {

        MockContext context = new MockContext();

        OneToOneCommunication oneToOneCommunication = new OneToOneCommunication(context);


    }

    @Test
    public void init_Test_When_Session_ID_Empty() throws Exception {

        MockContext context = new MockContext();

        OneToOneCommunication oneToOneCommunication = new OneToOneCommunication(context);


    }

    @Test
    public void init_Test_When_Token_Empty() throws Exception {

        MockContext context = new MockContext();

        OneToOneCommunication oneToOneCommunication = new OneToOneCommunication(context);


    }

    @Test
    public void init_Test_When_API_Key_Not_Valid() throws Exception {

        MockContext context = new MockContext();

        OneToOneCommunication oneToOneCommunication = new OneToOneCommunication(context);


    }

    @Test
    public void init_Test_When_Session_ID_Not_Valid() throws Exception {

        MockContext context = new MockContext();

        OneToOneCommunication oneToOneCommunication = new OneToOneCommunication(context);


    }

    @Test
    public void init_Test_When_Token_Not_Valid() throws Exception {

        MockContext context = new MockContext();

        OneToOneCommunication oneToOneCommunication = new OneToOneCommunication(context);


    }

    //Assert start
    //Assert end
    //Assert destroy
    //Assert enable local media
    //Assert enable remote media
    //Assert swap camera
    //
    //getters and setters

}