//
//  RACSignal+BAExt.h
//  BAvatar
//
//  Created by Howie on 7/8/19.
//  Copyright © 2019 bitstarlight. All rights reserved.
//

#import <ReactiveObjC/ReactiveObjC.h>

NS_ASSUME_NONNULL_BEGIN

@interface RACSignal <__covariant ValueType> (BAExt)

- (RACSignal<ValueType> *)ba_retry:(RACSignal *(^)(NSError *error))retry;
- (RACSignal<ValueType> *)ba_replayLastLazily;

- (RACSignal *)ba_flattenRecursivelyWithPaths:(NSArray<NSString *> *)paths;
- (RACSignal *)ba_flattenRecursivelyWithPaths:(NSArray<NSString *> *)paths lastCanBeNil:(BOOL)lastCanBeNil;
- (RACSignal *)ba_skipNextIn:(NSTimeInterval)interval;

@end

@interface NSObject (RACBAExt)

- (nullable RACSignal *)ba_observeValueWithPaths:(NSArray<NSString *> *)paths;
- (nullable RACSignal *)ba_observeValueWithPaths:(NSArray<NSString *> *)paths lastCanBeNil:(BOOL)lastCanBeNil;

@end

#ifndef BAPathString
#define BAPathString(OBJ, PATH) \
(((void)(NO && ((void)OBJ.PATH, NO)), # PATH))

#endif

#ifndef _BAObserveRecursively
#define _BAObserveRecursively(OBJ, PATH) \
[OBJ ba_observeValueWithPaths:[@BAPathString(OBJ, PATH) componentsSeparatedByString:@"."]]
#endif

#ifndef BAObserveNumberRecursively
#define BAObserveNumberRecursively(OBJ, PATH) \
(RACSignal<NSNumber *> *)_BAObserveRecursively(OBJ, PATH)
#endif

#ifndef BAObserverRecursively
#define BAObserverRecursively(OBJ, PATH) \
(RACSignal<typeof(OBJ.PATH)> *)_BAObserveRecursively(OBJ, PATH)
#endif

#ifndef BAObserveNullableRecursively
#define BAObserveNullableRecursively(OBJ, PATH) \
(RACSignal<typeof(OBJ.PATH)> *)[OBJ ba_observeValueWithPaths:[@BAPathString(OBJ, PATH) componentsSeparatedByString:@"."] lastCanBeNil:YES]
#endif

NS_ASSUME_NONNULL_END
