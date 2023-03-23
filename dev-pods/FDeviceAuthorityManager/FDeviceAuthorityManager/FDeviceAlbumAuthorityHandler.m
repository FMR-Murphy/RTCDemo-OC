//
//  FDeviceAlbumAuthorityHandler.m
//  example
//
//  Created by fang on 2021/7/4.
//

#import "FDeviceAlbumAuthorityHandler.h"

#import <Photos/Photos.h>

@interface FDeviceAlbumAuthorityHandler()

@property (nonatomic) FAuthorizationType type;
@end

@implementation FDeviceAlbumAuthorityHandler

+ (instancetype)addOnlyManager {
    return [FDeviceAlbumAuthorityHandler managerWithCamera:FAuthorizationTypeAlbumAddOnly];
}

+ (instancetype)readWriteManager {
    return [FDeviceAlbumAuthorityHandler managerWithCamera:FAuthorizationTypeAlbumReadWrite];
}

+ (instancetype)managerWithCamera:(FAuthorizationType)type {
    FDeviceAlbumAuthorityHandler * manager = [[FDeviceAlbumAuthorityHandler alloc] init];
    manager.type = type;
    return manager;
}

- (BOOL)canHandler:(FAuthorizationType)type {
    return type == self.type;
}

- (void)authority:(FAuthorityCallBack)callBack {
    PHAuthorizationStatus status;
    
    if (@available(iOS 14, *)) {
        status = [PHPhotoLibrary authorizationStatusForAccessLevel:self.type == FAuthorizationTypeAlbumReadWrite ? PHAccessLevelReadWrite : PHAccessLevelAddOnly];
    } else {
        status = [PHPhotoLibrary authorizationStatus];
    }
    
    FAuthorizationStatus cjStatus;
    switch (status) {
        case PHAuthorizationStatusAuthorized:
        case PHAuthorizationStatusLimited:
            cjStatus = FAuthorizationStatusAuthorized;
            break;
        case PHAuthorizationStatusDenied:
            cjStatus = FAuthorizationStatusDenied;
            break;
        case PHAuthorizationStatusRestricted:
            cjStatus = FAuthorizationStatusRestricted;
            break;
        case PHAuthorizationStatusNotDetermined:
            cjStatus = FAuthorizationStatusNotDetermined;
            break;
        default:
            break;
    }
    callBack(cjStatus);

}

- (void)requestAuthority:(FAuthorityRequestCallBack)callBack {
    
    void(^authorityHandler)(PHAuthorizationStatus status) = ^(PHAuthorizationStatus status) {
        if (@available(iOS 14, *)) {
            if (status == PHAuthorizationStatusLimited) {
                callBack(YES);
                return;
            }
        }
        if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
            callBack(NO);
            return;
        }
        if (status == PHAuthorizationStatusAuthorized) {
            callBack(YES);
            return;
        }
    };
    
    
    if (@available(iOS 14, *)) {
        [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:authorityHandler];
    } else {
        // Fallback on earlier versions
        [PHPhotoLibrary requestAuthorization:authorityHandler];
    }
}


@end
