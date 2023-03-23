//
//  CCLazyProxy.h
//  OptimizationDemo
//
//  Created by Murphy on 2022/11/20.
//  Copyright © 2022 Murphy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCLazyProxy <__covariant Value> : NSProxy

- (instancetype)initWithConstructor:(Value(^)(void))constructor;

@end

NS_ASSUME_NONNULL_END
