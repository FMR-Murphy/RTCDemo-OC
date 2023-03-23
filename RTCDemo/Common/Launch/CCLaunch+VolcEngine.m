//
//  CCLaunch+VolcEngine.m
//  RTCDemo
//
//  Created by Murphy on 2023/3/22.
//

#import "CCLaunch+VolcEngine.h"
#import "VolcEngineService.h"
#import "CCServiceRegistryService.h"
#import "CCLazyObject.h"
#import "CCProxy.h"
#import "TYSVarariable.h"
#if __has_include(<PromisesObjC/FBLPromise.h>)
#import <PromisesObjC/FBLPromises.h>
#else
#import <FBLPromises/FBLPromises.h>
#endif

@implementation CCLaunch (VolcEngine)

+ (void)prepareVolcEngine {
    let task = [CCProxy<VolcEngineService *> lazyPromiseProxy:^FBLPromise<VolcEngineService *> * _Nonnull{
        return [FBLPromise async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
            let service = [[VolcEngineService alloc] init];
            fulfill(service);
        }];
    } valueType:[VolcEngineService class]];
    
    [(CCPromiseProxy *)task canAwaitOnMainThread];
    [CCServiceRegistryService.sharedService registerLazily:task forIdentifier:NSStringFromClass([VolcEngineService class])];
}

@end
