//
//  FBLPromise+BARACSignal.m
//  BAvatar
//
//  Created by Howie on 7/8/19.
//  Copyright © 2019 bitstarlight. All rights reserved.
//

#import "FBLPromise+BARACSignal.h"
#import <ReactiveObjC/ReactiveObjC.h>

NSErrorDomain const BAPromiseSignalDomain = @"BAPromiseSignalDomain";

@implementation FBLPromise (BARACSignal)

- (RACSignal<id> *)ba_signal
{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [[self then:^id _Nullable(id  _Nullable value) {
            [subscriber sendNext:value];
            [subscriber sendCompleted];
            return nil;
        }] catch:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

+ (instancetype)ba_fromSignal:(RACSignal<id> *)signal
{
    return [FBLPromise async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
        [[signal take:1] subscribeNext:^(id  _Nullable x) {
            fulfill(x);
        } error:^(NSError * _Nullable error) {
            reject(error ?: [NSError errorWithDomain:BAPromiseSignalDomain code:-1 userInfo:nil]);
        }];
    }];
}

@end

@implementation RACSignal (BAFBLPromise)

- (FBLPromise *)ba_promise
{
    return [FBLPromise ba_fromSignal:self];
}

- (FBLPromise *)ba_firstAsPromise
{
    NSError *error = nil;
    id value = [self firstOrDefault:nil success:nil error:&error];
    return [FBLPromise resolvedWith:error ?: value];
}

+ (instancetype)ba_retriableSignalFromPromiseBlock:(FBLPromise<id> * _Nonnull (^)(void))promiseBlock
{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [[promiseBlock() then:^id _Nullable(NSArray * _Nullable value) {
            [subscriber sendNext:value];
            [subscriber sendCompleted];
            return nil;
        }] catch:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

@end
