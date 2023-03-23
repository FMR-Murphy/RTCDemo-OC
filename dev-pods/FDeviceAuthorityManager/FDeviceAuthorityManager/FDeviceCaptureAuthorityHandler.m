//
//  FDeviceCaptureAuthorityHandler.m
//  example
//
//  Created by fang on 2021/7/4.
//

#import "FDeviceCaptureAuthorityHandler.h"

#if __has_include(<PromisesObjC/FBLPromise.h>)
#import <PromisesObjC/FBLPromises.h>
#else
#import <FBLPromises/FBLPromises.h>
#endif

#import <AVFoundation/AVFoundation.h>

@interface FDeviceCaptureAuthorityHandler()

@property (nonatomic) FAuthorizationType type;

@end

@implementation FDeviceCaptureAuthorityHandler

+ (instancetype)cameraManager {
    return [FDeviceCaptureAuthorityHandler managerWithCamera:FAuthorizationTypeCamera];
}

+ (instancetype)microphoneManager {
    return [FDeviceCaptureAuthorityHandler managerWithCamera:FAuthorizationTypeMicrophone];
}

+ (instancetype)managerWithCamera:(FAuthorizationType)type {
    FDeviceCaptureAuthorityHandler * manager = [[FDeviceCaptureAuthorityHandler alloc] init];
    manager.type = type;
    return manager;
}

- (BOOL)canHandler:(FAuthorizationType)type {
    return type == self.type;
}

- (void)authority:(FAuthorityCallBack)callBack {
    AVMediaType type = self.type == FAuthorizationTypeCamera ? AVMediaTypeVideo : AVMediaTypeAudio;
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:type];
    
    FAuthorizationStatus cjStatus;
    switch (status) {
        case AVAuthorizationStatusAuthorized:
            cjStatus = FAuthorizationStatusAuthorized;
            break;
        case AVAuthorizationStatusDenied:
            cjStatus = FAuthorizationStatusDenied;
            break;
        case AVAuthorizationStatusRestricted:
            cjStatus = FAuthorizationStatusRestricted;
            break;
        case AVAuthorizationStatusNotDetermined:
            cjStatus = FAuthorizationStatusNotDetermined;
            break;
        default:
            break;
    }
    callBack(status);
}

- (void)requestAuthority:(FAuthorityRequestCallBack)callBack {
    AVMediaType type = self.type == FAuthorizationTypeCamera ? AVMediaTypeVideo : AVMediaTypeAudio;
    [AVCaptureDevice requestAccessForMediaType:type completionHandler:^(BOOL granted) {
        callBack(granted);
    }];
}

@end
