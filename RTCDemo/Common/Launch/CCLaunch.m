//
//  CCLaunch.m
//  OptimizationDemo
//
//  Created by Murphy on 2022/11/20.
//  Copyright © 2022 四方精创. All rights reserved.
//

#import "CCLaunch.h"
#import <objc/runtime.h>
#import "TYSVarariable.h"

#if __has_include(<PromisesObjC/FBLPromise.h>)
#import <PromisesObjC/FBLPromises.h>
#else
#import <FBLPromises/FBLPromises.h>
#endif

@implementation CCLaunch

+ (void)initialize {
    if (self == [CCLaunch class]) {
        [self executeAllVoidToVoidMethods];
    }
}

+ (BOOL)touch {
    // 由于这个运行时非常依赖于FBLPromise，将FBLPromise的初始化放于此处
    FBLPromise.defaultDispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return YES;
}

+ (BOOL)executeAllVoidToVoidMethods {
    unsigned int count = 0;
    let methodList = class_copyMethodList(object_getClass(self), &count);
    for (unsigned int i = 0; i < count ; i ++) {
        let method = methodList[i];
        let name = method_getName(method);
        if (sel_isEqual(name, @selector(initialize))) {
            continue;
        }
        
        let numberOfArgs = method_getNumberOfArguments(method);
        if (numberOfArgs != 2) {
            continue;
        }
        char * returnType = method_copyReturnType(method);
        BOOL returnVoid = strcmp(returnType, "v") == 0;
        free(returnType);
        if (!returnVoid) {
            continue;
        }
        IMP imp = method_getImplementation(method);
        ((void(*)(id))(imp))(self);
    }
    free(methodList);
    return YES;
}

@end
