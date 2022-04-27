package com.rnnewarchitecturelibrary;

import androidx.annotation.NonNull;
import com.facebook.react.bridge.Promise;
import java.util.Map;
import java.util.HashMap;

public class StringBuilderModuleImpl {

    public static final String NAME = "StringBuilder";

    public static void getNewString(String str, Promise promise) {
        promise.resolve("allaallalallalal");
    }

}