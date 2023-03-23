//
//  CCPromiseProxy.m
//  OptimizationDemo
//
//  Created by Murphy on 2022/11/20.
//  Copyright © 2022 Murphy. All rights reserved.
//

#import "CCPromiseProxy.h"

#import <objc/runtime.h>
#if __has_include(<PromisesObjC/FBLPromise.h>)
#import <PromisesObjC/FBLPromises.h>
#import <PromisesObjC/FBLPromise+Testing.h>
#else
#import <FBLPromises/FBLPromises.h>
#import <FBLPromises/FBLPromise+Testing.h>
#endif

@interface CCPromiseProxy <__covariant Value> ()

@property (nonatomic) FBLPromise<Value> *hh_promise;
@property (nonatomic, unsafe_unretained) Class hh_type;

@end

@implementation CCPromiseProxy
{
    BOOL _hh_canAwait;
}

- (instancetype)initWithPromise:(FBLPromise<id> *)promise valueType:(Class)type {
    _hh_promise = promise;
    _hh_type = type;
    _hh_canAwait = false;
    return self;
}

- (instancetype)canAwaitOnMainThread {
    _hh_canAwait = true;
    return self;
}

- (BOOL)isKindOfClass:(Class)aClass {
    return aClass == [FBLPromise class] ||
    [self.hh_type isSubclassOfClass:aClass] ||
    [super isKindOfClass:aClass];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.hh_type instanceMethodSignatureForSelector:sel] ?:
    [FBLPromise instanceMethodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSMethodSignature *methodSignature = invocation.methodSignature;
    if ([self.hh_type instancesRespondToSelector:invocation.selector]) {
        if (methodSignature.isOneway) {
            [invocation retainArguments];
            [self.hh_promise then:^id _Nullable(id  _Nullable value) {
                [invocation invokeWithTarget:value];
                return  nil;
            }];
        } else {
#if DEBUG
            if (!_hh_canAwait) {
                NSCAssert(!(self.hh_promise.isPending && [NSThread isMainThread]), @"Shouldn't await on main thread! You can try-catch for DEBUG.");
            }
#endif
            if (invocation.selector == @selector(valueForKey:) ||
                invocation.selector == @selector(valueForKeyPath:)) {
                // KVC special handler
                NSString *keyOrKeyPath = nil;
                [invocation getArgument:&keyOrKeyPath atIndex:2];
                BOOL promiseCanHandler = NO;
                id value = nil;
                NSError *error = nil;
                if (invocation.selector == @selector(valueForKey:)) {
                    promiseCanHandler = [self.hh_promise validateValue:&value forKey:keyOrKeyPath error:&error];
                } else {
                    promiseCanHandler = [self.hh_promise validateValue:&value forKeyPath:keyOrKeyPath error:&error];
                }
                if (promiseCanHandler) {
                    [invocation invokeWithTarget:self.hh_promise];
                    return;
                }
            }
            id object = FBLPromiseAwait(self.hh_promise, nil);
            [invocation invokeWithTarget:object];
        }
    } else {
        NSCAssert([FBLPromise instancesRespondToSelector:invocation.selector], @"%@ doesn't responds toselector %s", self.hh_promise, sel_getName(invocation.selector));
        [invocation invokeWithTarget:self.hh_promise];
    }
}


@end
