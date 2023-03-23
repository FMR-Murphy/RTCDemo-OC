//
//  CCProxiesHeaders.h
//  OptimizationDemo
//
//  Created by Murphy on 2022/11/20.
//  Copyright © 2022 Murphy. All rights reserved.
//

#ifndef CCProxiesHeaders_h
#define CCProxiesHeaders_h

#if __has_include("CCLazyProxy.h")
#import "CCLazyProxy.h"
#define LAZY_ENABLED 1
#endif

#if __has_include("CCPromiseProxy.h")
#import "CCPromiseProxy.h"
#define PROMISE_ENABLED 1
#endif

#endif /* CCProxiesHeaders_h */
