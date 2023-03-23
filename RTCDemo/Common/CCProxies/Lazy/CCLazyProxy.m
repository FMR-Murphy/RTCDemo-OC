//
//  CCLazyProxy.m
//  OptimizationDemo
//
//  Created by Murphy on 2022/11/20.
//  Copyright © 2022 Murphy. All rights reserved.
//

#import "CCLazyProxy.h"
#import <pthread/pthread.h>

@interface CCLazyProxy <__covariant Value> ()

@property (nonatomic) Value(^hh_constructor)(void);
@property (nonatomic) pthread_mutex_t hh_lock;
@property (nonatomic) Value hh_value;

@end

@implementation CCLazyProxy

+ (id)lazyProxy:(id(^)(void))constructor {
    return [[self alloc] initWithConstructor:constructor];
}

- (instancetype)initWithConstructor:(id _Nonnull (^)(void))constructor {
    pthread_mutex_init(&_hh_lock, nil);
    _hh_constructor = constructor;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.hh_value methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.hh_value];
}

- (id)hh_value {
    if (!_hh_value) {
        pthread_mutex_lock(&_hh_lock);
        if (!_hh_value) {
            _hh_value = self.hh_constructor();
        }
        pthread_mutex_unlock(&_hh_lock);
    }
    return _hh_value;
}

@end
