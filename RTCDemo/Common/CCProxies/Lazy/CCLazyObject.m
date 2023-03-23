//
//  CCLazyObject.m
//  OptimizationDemo
//
//  Created by Murphy on 2022/11/25.
//

#import "CCLazyObject.h"

@interface CCLazyObject <Value>()

@property (nonatomic) Value(^constructor)(void);
@property (nonatomic) Value value;
@property (nonatomic) BOOL fulfilled;

@end

@implementation CCLazyObject

- (instancetype)initWithConstructor:(id  _Nonnull (^)(void))constructor {
    if (self = [super init]) {
        _constructor = constructor;
    }
    return self;
}

- (id)value {
    if (!_value) {
        @synchronized (self) {
            if (!_value) {
                _value = self.constructor();
                self.fulfilled = YES;
            }
        }
    }
    return _value;
}

@end
