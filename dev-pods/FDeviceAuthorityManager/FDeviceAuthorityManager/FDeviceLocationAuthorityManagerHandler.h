//
//  FDeviceLocationAuthorityManagerHandler.h
//  example
//
//  Created by fang on 2021/7/4.
//

#import <Foundation/Foundation.h>

#import "FDeviceAuthorityHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface FDeviceLocationAuthorityManagerHandler : NSObject <FDeviceAuthorityHandlerProtocol>

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
