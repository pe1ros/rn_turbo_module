# For integration turbomodules on Android platform, we need to do these steps:

### 1) In `build.gradle` file on module level add these lines:

```

// Add this block
def isNewArchitectureEnabled() {
    return project.hasProperty("newArchEnabled") && project.newArchEnabled == "true"
}

apply plugin: 'com.android.library'

// Add this block
if (isNewArchitectureEnabled()) {
    apply plugin: 'com.facebook.react'
}

android {
    //...
    defaultConfig {
      //...
      // Add this line
      buildConfigField "boolean", "IS_NEW_ARCHITECTURE_ENABLED", isNewArchitectureEnabled().toString()
    }

    // Add this block
    sourceSets {
        main {
            if (isNewArchitectureEnabled()) {
                java.srcDirs += ['src/newarch']
            } else {
                java.srcDirs += ['src/oldarch']
            }
        }
    }
}

// Add this block
if (isNewArchitectureEnabled()) {
    react {
        jsRootDir = file("../src/")
        libraryName = "turbomodule" // this is name your main package
        codegenJavaPackageName = "com.voximplantreactnativecore"
    }
}
```

### 2) Change your `TurboModulePackage.java` like this, source `android/src/main/java/com/turbomodule/TurboModulePackage.java`

```java
package com.turbomodule;

import androidx.annotation.Nullable;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.module.model.ReactModuleInfo;
import com.facebook.react.module.model.ReactModuleInfoProvider;
import com.facebook.react.TurboReactPackage;
import com.facebook.react.uimanager.ViewManager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

public class TurboModulePackage extends TurboReactPackage {
    @Nullable
    @Override
    public NativeModule getModule(String name, ReactApplicationContext reactContext) {
        if (name.equals(TurboModuleImpl.NAME)) {
            return new RNTurboModule(reactContext); // This is name your module returned getName() method
        } else {
            return null;
        }
    }

    @Override
    public ReactModuleInfoProvider getReactModuleInfoProvider() {
        return () -> {
            final Map<String, ReactModuleInfo> moduleInfos = new HashMap<>();
            boolean isTurboModule = BuildConfig.IS_NEW_ARCHITECTURE_ENABLED;
            moduleInfos.put(
                    TurboModuleImpl.NAME,
                    new ReactModuleInfo(
                            TurboModuleImpl.NAME,
                            TurboModuleImpl.NAME,
                            false, // canOverrideExistingModule
                            false, // needsEagerInit
                            true, // hasConstants
                            false, // isCxxModule
                            isTurboModule // isTurboModule
            ));
            return moduleInfos;
        };
    }
}
```

### 3) Create your `TurboModuleImpl.java` file, in  `android/src/main/java/com/turbomodule/TurboModuleImpl.java` directory. This class will be contain main your module logic.

```java
public class TurboModuleImpl {
    public static final String NAME = "RNTurboModule";

    public static void add(double a, double b, Promise promise) {
        promise.resolve(a + b);
    }
}
```

### 4) Create directory and file inside there `android/src/newarch/java/com/turbomodule/TurboModule.java`

```java
package com.turbomodule;

import androidx.annotation.NonNull;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import java.util.Map;
import java.util.HashMap;

// NativeTurboModuleSpec interface name need to change with according you NativeTurboModule.js file
public class TurboModule extends NativeTurboModuleSpec {

    TurboModule(ReactApplicationContext context) {
        super(context);
    }

    @Override
    @NonNull
    public String getName() {
        return TurboModuleImpl.NAME;
    }

    @Override
    public void add(double a, double b, Promise promise) {
        TurboModuleImpl.add(a, b, promise);
    }
}
```

### 5) Create directory and file inside there `android/src/oldarch/java/com/turbomodule/TurboModule.java`

```java
package com.turbomodule;

import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import java.util.Map;
import java.util.HashMap;

public class TurboModule extends ReactContextBaseJavaModule {

    TurboModule(ReactApplicationContext context) {
        super(context);
    }

    @Override
    public String getName() {
        return TurboModuleImpl.NAME;
    }

    @ReactMethod
    public void add(int a, int b, Promise promise) {
        TurboModuleImpl.add(a, b, promise);
    }
}
```

# For integration turbomodules on iOS platform, we need to do these steps:

### 1) Add codegen config in the end your `package.json` file

```json
"codegenConfig": {
      "libraries": [
        {
          "name": "RNTurboModuleSpec",
          "type": "modules",
          "jsSrcsDir": "src"
        }
      ]
  }
```

### 2) Update your podfile like this:

```ruby

package = JSON.parse(File.read(File.join(__dir__, "package.json")))
# Add this lines
folly_version = '2021.06.28.00-v2'
folly_compiler_flags = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -Wno-comma -Wno-shorten-64-to-32'

# Add this block before end keyword your podspec
  if ENV['RCT_NEW_ARCH_ENABLED'] == '1' then
    s.compiler_flags = folly_compiler_flags + " -DRCT_NEW_ARCH_ENABLED=1"
    s.pod_target_xcconfig    = {
        "HEADER_SEARCH_PATHS" => "\"$(PODS_ROOT)/boost\"",
        "CLANG_CXX_LANGUAGE_STANDARD" => "c++17"
    }

    s.dependency "React-RCTFabric" # This is for fabric component
    s.dependency "React-Codegen"
    s.dependency "RCT-Folly", folly_version
    s.dependency "RCTRequired"
    s.dependency "RCTTypeSafety"
    s.dependency "ReactCommon/turbomodule/core"
  end
```

### 3) Change extension your file `RNTurboModule.m` to `RNTurboModule.mm`

### 4) Update your `RNTurboModule.mm` file

```obj-c
#import "RNTurboModule.h"

// Add this block, imported header file need to  be equal with name inside codeGen package.json file
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNTurboModuleSpec.h" 
#endif

@implementation RNCalculator

RCT_EXPORT_MODULE(Calculator)

RCT_REMAP_METHOD(add, addA:(NSInteger)a
                        andB:(NSInteger)b
                 withResolver:(RCTPromiseResolveBlock) resolve
                 withRejecter:(RCTPromiseRejectBlock) reject)
{
    NSNumber *result = [[NSNumber alloc] initWithInteger:a+b];
    resolve(result);
}

// Add this block before end keyword your RNTurboModule.mm
// NativeTurboModuleSpecJSI interface need to change with according you NativeTurboModule.js file
#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeTurboModuleSpecJSI>(params);
}
#endif

@end
```

# Create TS Spec file and update index.ts for using with new/old architecture

### 1) Update your `index.ts` file

```js
import { NativeModules } from 'react-native';

const isTurboModuleEnabled = global.__turboModuleProxy != null;

const TurboModule = isTurboModuleEnabled
  ? require('./NativeTurboModule').default
  : NativeModules.RNTurboModule;
```

### 2) Create `NativeTurboModule.ts` file with content like this

```ts
import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  add(a: number, b: number): Promise<number>;
}

export default TurboModuleRegistry.get<Spec>('RNTurboModule');
```



# Enable your iOS application for support turbomodules
### 1) Install React Native >= 0.68.0, or keep doing steps from official [docs](https://reactnative.dev/docs/new-architecture-app-intro) if you have below version.

### 2) Add RCTEnableTurboModule(YES); in AppDelegate => didFinishLaunchingWithOptions method.

```obj-c
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // Add this line
  RCTEnableTurboModule(YES);
  //...
```
### 3) Run from root example-library folder 

```bash
  cd ios && RCT_NEW_ARCH_ENABLED=1 pod install
```

# Enable your Android application for support turbomodules
### 1) Install React Native >= 0.68.0, or keep doing steps from official [docs](https://reactnative.dev/docs/new-architecture-app-intro) if you have below version.

### 2) Move to `example-library/android/gradle.properties` file and change `newArchEnabled` flag

  newArchEnabled=true

## While Autolinking doesn’t work with the new architecture out of the box

### 3) Open the `example-library/android/app/build.gradle` file and update the file as it follows:

```diff
    "PROJECT_BUILD_DIR=$buildDir",
    "REACT_ANDROID_DIR=$rootDir/../node_modules/react-native/ReactAndroid",
-   "REACT_ANDROID_BUILD_DIR=$rootDir/../node_modules/react-native/ReactAndroid/build"
+   "REACT_ANDROID_BUILD_DIR=$rootDir/../node_modules/react-native/ReactAndroid/build",
+   "NODE_MODULES_DIR=$rootDir/../node_modules/"
    cFlags "-Wall", "-Werror", "-fexceptions", "-frtti", "-DWITH_INSPECTOR=1"
    cppFlags "-std=c++17"
```

### 4) Open the `example-library/android/app/src/main/jni/Android.mk` file and update the file as it follows:

```diff
    # If you wish to add a custom TurboModule or Fabric component in your app you
    # will have to include the following autogenerated makefile.
    # include $(GENERATED_SRC_DIR)/codegen/jni/Android.mk
+
+   # Includes the MK file for `example-library`
+   include $(NODE_MODULES_DIR)/example-library/android/build/generated/source/codegen/jni/Android.mk
    include $(CLEAR_VARS)
```

### 5) In the same file above, go to the `LOCAL_SHARED_LIBRARIES` setting and add the following line:
```diff
    libreact_codegen_rncore \
+   libreact_codegen_turbomodule \
    libreact_debug \
```

### 6) Open the `App/android/app/src/main/jni/MainApplicationModuleProvider.cpp` file and update the file as it follows:
a. Add the import for the turbomodule:
```diff
    #include <answersolver.h>
+   #include <turbomodule.h>
```
b.Add the following check in the `MainApplicationModuleProvider` constructor:
```diff
    // auto module = samplelibrary_ModuleProvider(moduleName, params);
    // if (module != nullptr) {
    //    return module;
    // }

+    auto module = turbomodule_ModuleProvider(moduleName, params);
+    if (module != nullptr) {
+        return module;
+    }

    return rncore_ModuleProvider(moduleName, params);
}
```
