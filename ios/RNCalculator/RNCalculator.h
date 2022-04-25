//
//  RNCalculator.h
//  RNCalculator
//
//  Created by Ilya Petrosyan on 25.04.2022.
//

#import <React/RCTBridgeModule.h>

// Thanks to this guard, we won't import this header when we build for the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNCalculatorSpec.h"
#endif

@interface RNCalculator : NSObject <RCTBridgeModule>

// Thanks to this guard, we won't compile this code when we build for the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeCalculatorSpecJSI>(params);
}
#endif

@end
