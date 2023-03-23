//
//  CCProxy.h
//  OptimizationDemo
//
//  Created by Murphy on 2022/11/20.
//  Copyright © 2022 Murphy. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FBLPromise <__covariant Value>;
#import "CCProxiesHeaders.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCProxy <__covariant Value> : NSObject

#if LAZY_ENABLED
+ (Value)lazyProxy:(Value(^)(void))constructor;
#endif

#if PROMISE_ENABLED
+ (Value)promiseProxy:(FBLPromise<Value> *)promise valueType:(Class)type;
#if LAZY_ENABLED
+ (Value)lazyPromiseProxy:(FBLPromise<Value> *(^)(void))constructor valueType:(Class)type;
#endif
#endif

@end

NS_ASSUME_NONNULL_END
