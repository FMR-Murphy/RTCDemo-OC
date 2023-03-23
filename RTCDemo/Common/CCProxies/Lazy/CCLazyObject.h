//
//  CCLazyObject.h
//  OptimizationDemo
//
//  Created by Murphy on 2022/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCLazyObject <__covariant Value> : NSObject

- (instancetype)initWithConstructor:(Value(^)(void))constructor;
@property (nonatomic, readonly) Value value;
@property (nonatomic, readonly) BOOL fulfilled;

@end

NS_ASSUME_NONNULL_END
