// Copyright 2015-present 650 Industries. All rights reserved.

#import "ABI22_0_0EXDeviceMotion.h"
#import "ABI22_0_0EXUnversioned.h"
#import "ABI22_0_0EXScopedModuleRegistry.h"

@interface ABI22_0_0EXDeviceMotion ()

@property (nonatomic, weak) id kernelSensorServiceDelegate;
@property (nonatomic, assign, getter=isWatching) BOOL watching;

@end

@implementation ABI22_0_0EXDeviceMotion

ABI22_0_0EX_EXPORT_SCOPED_MODULE(ExponentDeviceMotion, SensorManager);

- (instancetype)initWithExperienceId:(NSString *)experienceId kernelServiceDelegate:(id)kernelServiceInstance params:(NSDictionary *)params
{
  if (self = [super initWithExperienceId:experienceId kernelServiceDelegate:kernelServiceInstance params:params]) {
    _kernelSensorServiceDelegate = kernelServiceInstance;
  }
  return self;
}

- (void)setBridge:(ABI22_0_0RCTBridge *)bridge
{
  [super setBridge:bridge];
  _watching = NO;
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(bridgeDidForeground:)
                                               name:@"EXKernelBridgeDidForegroundNotification"
                                             object:self.bridge];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(bridgeDidBackground:)
                                               name:@"EXKernelBridgeDidBackgroundNotification"
                                             object:self.bridge];
}

- (NSDictionary *)constantsToExport
{
  return @{ @"Gravity" : @(ABI22_0_0EXGravity) };
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"deviceMotionDidUpdate"];
}

- (void)startObserving {
  [self setWatching:YES];
  __weak typeof(self) weakSelf = self;
  [_kernelSensorServiceDelegate sensorModuleDidSubscribeForDeviceMotionUpdates:self withHandler:^(NSDictionary *event) {
    [weakSelf sendEventWithName:@"deviceMotionDidUpdate" body:event];
  }];
}

- (void)stopObserving {
  [self setWatching:NO];
  [_kernelSensorServiceDelegate sensorModuleDidUnsubscribeForDeviceMotionUpdates:self];
}

ABI22_0_0RCT_EXPORT_METHOD(setUpdateInterval:(nonnull NSNumber *)intervalMs) {
  [_kernelSensorServiceDelegate setDeviceMotionUpdateInterval:[intervalMs doubleValue] / 1000];
}

- (void)bridgeDidForeground:(NSNotification *)notification
{
  if ([self isWatching]) {
    [self startObserving];
  }
}

- (void)bridgeDidBackground:(NSNotification *)notification
{
  if ([self isWatching]) {
    [_kernelSensorServiceDelegate sensorModuleDidUnsubscribeForDeviceMotionUpdates:self];
  }
}

@end
