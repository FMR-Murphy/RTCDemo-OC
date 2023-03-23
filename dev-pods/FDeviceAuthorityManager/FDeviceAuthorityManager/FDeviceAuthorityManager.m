//
//  FDeviceAuthorityManager.m
//  example
//
//  Created by fang on 2021/7/4.
//

#import "FDeviceAuthorityManager.h"

#import "FDeviceCaptureAuthorityHandler.h"
#import "FDeviceAlbumAuthorityHandler.h"
#import "FDeviceLocationAuthorityManagerHandler.h"

#if __has_include(<PromisesObjC/FBLPromise.h>)
#import <PromisesObjC/FBLPromises.h>
#else
#import <FBLPromises/FBLPromises.h>
#endif

static NSString * const CJDevideAuthorityErrorDomain = @"com.CJDevideAuthorityErrorDomain";

@interface FDeviceAuthorityManager()

@end

@implementation FDeviceAuthorityManager

+ (FBLPromise *)authorityWithType:(FAuthorizationType)type {
    return [FBLPromise async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
        id<FDeviceAuthorityHandlerProtocol> manager = nil;
        
        for (id<FDeviceAuthorityHandlerProtocol> item in [self managerArray]) {
            if ([item canHandler:type]) {
                manager = item;
                break;
            }
        }
        __weak typeof(manager) weakManager = manager;
        [manager authority:^(FAuthorizationStatus status) {
            __strong typeof (weakManager) strongManager = weakManager;
            
            if (status == FAuthorizationStatusAuthorized) {
                fulfill(@YES);
            } else if (status == FAuthorizationStatusNotDetermined) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongManager requestAuthority:^(BOOL granted) {
                        if (granted) {
                            fulfill(@YES);
                        } else {
                            reject([NSError errorWithDomain:CJDevideAuthorityErrorDomain code:type userInfo:@{NSLocalizedDescriptionKey: @"用户拒绝"}]);
                        }
                    }];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showGoSettingAlertType:type];
                });
                reject([NSError errorWithDomain:CJDevideAuthorityErrorDomain code:type userInfo:@{NSLocalizedDescriptionKey: @"用户未授权"}]);
            }
        }];
    }];
}

+ (void)showGoSettingAlertType:(FAuthorizationType)type {
    
    UIViewController * viewController = UIApplication.sharedApplication.delegate.window.rootViewController;
    [self alertWithViewController:viewController message:[self messagesDic][@(type)] leftTitle:@"取消" leftAction:nil rightTitle:@"确定" rightAction:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
}

+ (void)alertWithViewController:(UIViewController *)viewController message:(NSString *)message leftTitle:(nullable NSString *)leftTitle leftAction:(void(^ _Nullable)(void))leftAction rightTitle:(nullable NSString *)rightTitle rightAction:(void(^ _Nullable)(void))rightAction {
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:(UIAlertControllerStyleAlert)];
    if (leftTitle) {
        UIAlertAction * left = [UIAlertAction actionWithTitle:leftTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            !leftAction ?: leftAction();
        }];
        [alertController addAction:left];
    }
    
    if (rightTitle) {
        UIAlertAction * right = [UIAlertAction actionWithTitle:rightTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            !rightAction ?: rightAction();
        }];
        [alertController addAction:right];
    }
    
    [viewController presentViewController:alertController animated:true completion:^{
        //
    }];
    
}

+ (NSDictionary<NSNumber *, NSString *> *)messagesDic {
    return @{@(FAuthorizationTypeCamera) : @"相机权限未授权，点击确定前往系统设置",
             @(FAuthorizationTypeMicrophone) : @"麦克风权限未授权，点击确定前往系统设置",
             @(FAuthorizationTypeAlbumAddOnly) : @"相册权限未授权，点击确定前往系统设置",
             @(FAuthorizationTypeAlbumReadWrite) : @"相册权限未授权，点击确定前往系统设置",
             @(FAuthorizationTypeLocation) : @"定位权限未授权，点击确定前往系统设置",
    };
}

+ (NSArray<id<FDeviceAuthorityHandlerProtocol>> *)managerArray {
    return @[[FDeviceCaptureAuthorityHandler cameraManager],
             [FDeviceCaptureAuthorityHandler microphoneManager],
             [FDeviceAlbumAuthorityHandler addOnlyManager],
             [FDeviceAlbumAuthorityHandler readWriteManager],
             [FDeviceLocationAuthorityManagerHandler sharedInstance]
    ];
}


@end
