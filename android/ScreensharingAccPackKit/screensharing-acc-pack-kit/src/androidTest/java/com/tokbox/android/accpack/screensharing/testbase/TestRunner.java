package com.tokbox.android.accpack.screensharing.testbase;


import android.os.Bundle;

import com.tokbox.android.accpack.screensharing.config.APIConfig;
import com.zutubi.android.junitreport.JUnitReportTestRunner;



public class TestRunner extends JUnitReportTestRunner {
    private final String FLAG_API_KEY = "api_key";
    private final String FLAG_API_SECRET = "api_secret";
    private final String FLAG_API_URL = "api_url";
    private final String FLAG_API_SESSION_ID = "api_session_id";
    private final String FLAG_API_TOKEN = "api_token";

    @Override
    public void onCreate(Bundle arguments) {

        APIConfig.API_KEY = arguments.getString(FLAG_API_KEY, APIConfig.API_KEY);
        APIConfig.API_SECRET = arguments.getString(FLAG_API_SECRET, APIConfig.API_SECRET);
        APIConfig.API_URL = arguments.getString(FLAG_API_URL, APIConfig.API_URL);
        APIConfig.SESSION_ID = arguments.getString(FLAG_API_SESSION_ID, APIConfig.SESSION_ID);
        APIConfig.TOKEN = arguments.getString(FLAG_API_TOKEN, APIConfig.TOKEN);

        super.onCreate(arguments);
    }
}