//
//  RACSignal+BAExt.m
//  BAvatar
//
//  Created by Howie on 7/8/19.
//  Copyright © 2019 bitstarlight. All rights reserved.
//

#import "RACSignal+BAExt.h"

// Subscribes to the given signal with the given blocks.
//
// If the signal errors or completes, the corresponding block is invoked. If the
// disposable passed to the block is _not_ disposed, then the signal is
// subscribed to again.
static RACDisposable * ba_subscribeForever(RACSignal *signal, void (^next)(id), RACDisposable * (^error)(NSError *, RACDisposable *, void (^recurse)(void)), void (^completed)(RACDisposable *, void (^recurse)(void)))
{
    next = [next copy];
    error = [error copy];
    completed = [completed copy];

    RACCompoundDisposable *compoundDisposable = [RACCompoundDisposable compoundDisposable];

    RACSchedulerRecursiveBlock recursiveBlock = ^(void (^recurse)(void)) {
        RACCompoundDisposable *selfDisposable = [RACCompoundDisposable compoundDisposable];
        [compoundDisposable addDisposable:selfDisposable];

        __weak RACDisposable *weakSelfDisposable = selfDisposable;

        RACDisposable *subscriptionDisposable = [signal subscribeNext:next error:^(NSError *e) {
            @autoreleasepool {
                [compoundDisposable addDisposable:error(e, compoundDisposable, recurse)];
                [compoundDisposable removeDisposable:weakSelfDisposable];
            }
        } completed:^{
            @autoreleasepool {
                completed(compoundDisposable, recurse);
                [compoundDisposable removeDisposable:weakSelfDisposable];
            }
        }];

        [selfDisposable addDisposable:subscriptionDisposable];
    };

    // Subscribe once immediately, and then use recursive scheduling for any
    // further resubscriptions.
    recursiveBlock(^{
        RACScheduler *recursiveScheduler = RACScheduler.currentScheduler ? : [RACScheduler scheduler];

        RACDisposable *schedulingDisposable = [recursiveScheduler scheduleRecursiveBlock:recursiveBlock];
        [compoundDisposable addDisposable:schedulingDisposable];
    });

    return compoundDisposable;
}

@implementation RACSignal (BAExt)

- (RACSignal<id> *)ba_retry:(RACSignal *(^)(NSError *error))retry
{
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        return ba_subscribeForever(self,
                                ^(id x) {
                                    [subscriber sendNext:x];
                                },
                                ^(NSError *error, RACDisposable *disposable, void (^recurse)(void)) {
                                    RACSignal *retrySignal = retry(error);
                                    return [[retrySignal take:1] subscribeNext:^(id  _Nullable x) {
                                        recurse();
                                    } error:^(NSError * _Nullable error) {
                                        [disposable dispose];
                                        [subscriber sendError:error];
                                    }];
                                },
                                ^(RACDisposable *disposable, void (^recurse)(void)) {
                                    [disposable dispose];
                                    [subscriber sendCompleted];
                                });
    }] setNameWithFormat:@"[%@] -ba_retry", self.name];
}

- (RACSignal *)ba_flattenRecursivelyWithPaths:(NSArray<NSString *> *)paths
{
    return [self ba_flattenRecursivelyWithPaths:paths lastCanBeNil:NO];
}

- (RACSignal *)ba_flattenRecursivelyWithPaths:(NSArray<NSString *> *)paths lastCanBeNil:(BOOL)lastCanBeNil
{
    NSString *path = [paths firstObject];
    if (!path) {
        return self;
    }
    
    RACSignal * flatten = [[self map:^id _Nullable(id  _Nullable value) {
        RACSignal *observedValue = [value rac_valuesForKeyPath:path observer:value];
        if (lastCanBeNil && paths.count == 1) {
            return observedValue;
        } else return [observedValue filter:^BOOL(id  _Nullable value) {
            return value != nil;
        }];
    }] switchToLatest];
    
    NSUInteger count = paths.count;
    return [flatten ba_flattenRecursivelyWithPaths:[paths subarrayWithRange:NSMakeRange(1, count - 1)] lastCanBeNil:lastCanBeNil];
}

- (RACSignal *)ba_replayLastLazily
{
    RACReplaySubject *subject = [[RACReplaySubject replaySubjectWithCapacity:1] setNameWithFormat:@"[%@] -replayLast", self.name];

    RACMulticastConnection *connection = [self multicast:subject];
    return [[RACSignal
             defer:^{
                 [connection connect];
                 return connection.signal;
             }]
            setNameWithFormat:@"[%@] -replayLazily", self.name];
}

- (RACSignal *)ba_skipNextIn:(NSTimeInterval)interval
{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        RACCompoundDisposable *compoundDisposable = [[RACCompoundDisposable alloc] init];
        __block NSNumber *previousTriggerTime = nil;
        RACDisposable *sourceDisposable = [self subscribeNext:^(id x) {
            NSTimeInterval currentTime = CACurrentMediaTime();
            if (!previousTriggerTime ||
                currentTime - [previousTriggerTime doubleValue] > interval) {
                previousTriggerTime = @(currentTime);
                [subscriber sendNext:x];
            }
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];

        [compoundDisposable addDisposable:sourceDisposable];
        return compoundDisposable;
    }];
//    __block RACTwoTuple<id, NSNumber *> *previousValue;
//    return [[[self map:^id _Nullable(id  _Nullable value) {
//        return RACTuplePack(value, @(CACurrentMediaTime()));
//    }] filter:^BOOL(typeof(previousValue) _Nullable value) {
//        if (previousValue) {
//            return [value.second doubleValue] - [previousValue.second doubleValue] >= interval;
//        } else {
//            previousValue = value;
//            return YES;
//        }
//    }] map:^id _Nullable(id  _Nullable value) {
//
//    }]
}

@end

@implementation NSObject (RACBAExt)

- (RACSignal *)ba_observeValueWithPaths:(NSArray<NSString *> *)paths
{
    return [self ba_observeValueWithPaths:paths lastCanBeNil:NO];
}

- (RACSignal *)ba_observeValueWithPaths:(NSArray<NSString *> *)paths lastCanBeNil:(BOOL)lastCanBeNil
{
    NSString *firstPath = paths.firstObject;
    return [[self rac_valuesForKeyPath:firstPath observer:self] ba_flattenRecursivelyWithPaths:[paths subarrayWithRange:NSMakeRange(1, paths.count - 1)] lastCanBeNil:lastCanBeNil];
}

@end
