//
//  CCPromiseProxy.h
//  OptimizationDemo
//
//  Created by Murphy on 2022/11/20.
//  Copyright © 2022 Murphy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FBLPromise <__covariant Value>;

NS_ASSUME_NONNULL_BEGIN

@interface CCPromiseProxy<__covariant Value> : NSProxy

- (instancetype)initWithPromise:(FBLPromise<Value> *)promise valueType:(Class)type;

- (instancetype)canAwaitOnMainThread;

@end

NS_ASSUME_NONNULL_END
