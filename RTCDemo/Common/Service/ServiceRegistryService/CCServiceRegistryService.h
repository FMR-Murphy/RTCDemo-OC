//
//  CCServiceRegistryService.h
//  OptimizationDemo
//
//  Created by Murphy on 2022/11/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FBLPromise<__covariant Value>;
@class CCPromiseProxy<__covariant Value>;
@class CCProxy<__covariant Value>;


@interface CCServiceRegistryService : NSObject

+ (instancetype)sharedService;
- (void)registerLazily:(id)task forIdentifier:(NSString *)identifier;
- (id)lazyServiceForIdentifier:(NSString *)identifer;

@end

#ifndef CCGetService
#define CCGetService(cls) ((cls *)[[CCServiceRegistryService sharedService] lazyServiceForIdentifier:@""#cls])
#endif

#ifndef CCGetServicePromise
#define CCGetServicePromise(cls) ((FBLPromise<cls *> *)[[CCServiceRegistryService sharedService] lazyServiceForIdentifier:@""#cls])
#endif

#ifndef CCGetServiceByClassName
#define CCGetServiceByClassName(cls) CCGetServicePromise(cls)
#endif


NS_ASSUME_NONNULL_END
