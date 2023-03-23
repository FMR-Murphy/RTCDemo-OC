//
//  FDeviceAuthorityManager.h
//  example
//
//  Created by fang on 2021/7/4.
//

#import <Foundation/Foundation.h>

#import "FDeviceAuthorityHeader.h"

@class FBLPromise;

NS_ASSUME_NONNULL_BEGIN

@interface FDeviceAuthorityManager : NSObject

+ (FBLPromise *)authorityWithType:(FAuthorizationType)type;

@end

NS_ASSUME_NONNULL_END
