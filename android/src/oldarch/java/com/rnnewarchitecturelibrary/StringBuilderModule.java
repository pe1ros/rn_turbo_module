package com.rnnewarchitecturelibrary;

import androidx.annotation.NonNull;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import java.util.Map;
import java.util.HashMap;

public class StringBuilderModule extends ReactContextBaseJavaModule {

    StringBuilderModule(ReactApplicationContext context) {
        super(context);
    }

    @Override
    public String getName() {
        return StringBuilderModuleImpl.NAME;
    }

    @ReactMethod
    public void getNewString(String str, Promise promise) {
        StringBuilderModuleImpl.getNewString(str, promise);
    }
}