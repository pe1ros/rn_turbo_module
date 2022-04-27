#import "RNStringBuilder.h"

// Thanks to this guard, we won't import this header when we build for the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNSpec.h"
#endif

@implementation RNStringBuilder

RCT_EXPORT_MODULE(StringBuilder)

RCT_REMAP_METHOD(getNewString, getStr:(NSString *)string
        withResolver:(RCTPromiseResolveBlock) resolve
        withRejecter:(RCTPromiseRejectBlock) reject)
{
    resolve(@"allallaalalalala");
}

// Thanks to this guard, we won't compile this code when we build for the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeStringBuilderSpecJSI>(params);
}
#endif

@end
