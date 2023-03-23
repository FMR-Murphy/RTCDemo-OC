//
//  FBLPromise+BARACSignal.h
//  BAvatar
//
//  Created by Howie on 7/8/19.
//  Copyright © 2019 bitstarlight. All rights reserved.
//

#if __has_include(<PromisesObjC/FBLPromise.h>)
#import <PromisesObjC/FBLPromises.h>
#else
#import <FBLPromises/FBLPromises.h>
#endif
#import <ReactiveObjC/ReactiveObjC.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const BAPromiseSignalDomain;

@class RACSignal <__covariant ValueType>;

@interface FBLPromise<__covariant Value> (BARACSignal)

- (RACSignal<Value> *)ba_signal;
+ (FBLPromise<Value> *)ba_fromSignal:(RACSignal<Value> *)signal;

@end

@interface RACSignal <__covariant Value> (BAFBLPromise)

- (FBLPromise<Value> *)ba_promise;
- (FBLPromise<Value> *)ba_firstAsPromise;
+ (instancetype)ba_retriableSignalFromPromiseBlock:(FBLPromise<Value> *(^)(void))promiseBlock;

@end

NS_ASSUME_NONNULL_END
