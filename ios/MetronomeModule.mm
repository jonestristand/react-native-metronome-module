#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import "MetronomeModuleSpec/MetronomeModuleSpec.h"

#if __has_include("react_native_metronome_module-Swift.h")
#import "react_native_metronome_module-Swift.h"
#else
#import <react_native_metronome_module/react_native_metronome_module-Swift.h>
#endif

@interface MetronomeModule (TurboModuleProvider) <NativeMetronomeModuleSpec>
@end

@implementation MetronomeModule (TurboModuleProvider)

RCT_EXPORT_MODULE(MetronomeModule)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
  return std::make_shared<facebook::react::NativeMetronomeModuleSpecJSI>(params);
}

@end
