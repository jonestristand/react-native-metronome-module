#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(MetronomeModule, NSObject)

RCT_EXTERN_METHOD(start)
RCT_EXTERN_METHOD(stop)

RCT_EXTERN_METHOD(setBPM:(int)newBPM)
RCT_EXTERN_METHOD(getBPM:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(setShouldPauseOnLostFocus:(BOOL)shouldPause)
RCT_EXTERN_METHOD(getShouldPauseOnLostFocus:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(isPlaying:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(isPaused:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

@end
