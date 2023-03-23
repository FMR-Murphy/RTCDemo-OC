//
//  CCServiceRegistryService.m
//  OptimizationDemo
//
//  Created by Murphy on 2022/11/24.
//

#import "CCServiceRegistryService.h"
#import "CCProxy.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "FBLPromise+BARACSignal.h"

@interface CCServiceRegistryService ()

@property (nonatomic) NSMutableDictionary<NSString *, id> *services;
@property (nonatomic) dispatch_queue_t operationQueue;

@end

@implementation CCServiceRegistryService

+ (instancetype)sharedService {
    static CCServiceRegistryService * service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[CCServiceRegistryService alloc] init];
    });
    return service;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _services = [NSMutableDictionary dictionary];
        _operationQueue = dispatch_queue_create("com.murphy.services", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)registerLazily:(id)task forIdentifier:(NSString *)identifier {
    dispatch_barrier_async(self.operationQueue, ^{
        NSCAssert(self.services[identifier] == nil, @"%@ register twice, %@ and %@!", identifier, self.services[identifier], task);
        self.services[identifier] = task;
    });
}

- (id)lazyServiceForIdentifier:(NSString *)identifer {
    __block id service = nil;
    dispatch_sync(self.operationQueue, ^{
        service = self.services[identifer];
        if (!service) {
            
            service = [CCProxy promiseProxy:[[[[self.services rac_valuesForKeyPath:identifer observer:self] filter:^BOOL(id  _Nullable value) {
                return value != nil;
            }] take:1] ba_promise] valueType:NSClassFromString(identifer)];
        }
    });
    return service;
}
@end
