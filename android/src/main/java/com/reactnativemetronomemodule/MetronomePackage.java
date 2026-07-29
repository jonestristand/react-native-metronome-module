package com.reactnativemetronomemodule;

import com.facebook.react.BaseReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.module.model.ReactModuleInfo;
import com.facebook.react.module.model.ReactModuleInfoProvider;

import java.util.HashMap;
import java.util.Map;

public class MetronomePackage extends BaseReactPackage {

  @Override
  public NativeModule getModule(String name, ReactApplicationContext reactContext) {
    if (name.equals(MetronomeModule.NAME)) {
      return new MetronomeModule(reactContext);
    } else {
      return null;
    }
  }

  @Override
  public ReactModuleInfoProvider getReactModuleInfoProvider() {
    return () -> {
      Map<String, ReactModuleInfo> moduleInfos = new HashMap<>();
      moduleInfos.put(
          MetronomeModule.NAME,
          new ReactModuleInfo(
              MetronomeModule.NAME,
              MetronomeModule.NAME,
              false, // canOverrideExistingModule
              false, // needsEagerInit
              false, // isCxxModule
              true // isTurboModule
          ));
      return moduleInfos;
    };
  }
}
