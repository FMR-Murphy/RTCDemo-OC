//
//  CCProxy.m
//  OptimizationDemo
//
//  Created by Murphy on 2022/11/20.
//  Copyright © 2022 Murphy. All rights reserved.
//

#import "CCProxy.h"

@implementation CCProxy

+ (id)lazyProxy:(id(^)(void))constructor {
    return [[CCLazyProxy alloc] initWithConstructor:constructor];
}

+ (id)promiseProxy:(FBLPromise<id> *)promise valueType:(Class)type {
    return  [[CCPromiseProxy alloc] initWithPromise:promise valueType:type];
}

+ (id)lazyPromiseProxy:(FBLPromise<id> * _Nonnull (^)(void))constructor valueType:(Class)type {
    return [self promiseProxy:[self lazyProxy:constructor] valueType:type];
}

@end
