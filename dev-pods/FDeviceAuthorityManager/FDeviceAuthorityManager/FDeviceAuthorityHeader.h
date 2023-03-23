//
//  FDeviceAuthorityHeader.h
//  example
//
//  Created by fang on 2021/7/4.
//

#ifndef FDeviceAuthorityHeader_h
#define FDeviceAuthorityHeader_h

@class FBLPromise;

typedef NS_ENUM(NSUInteger, FAuthorizationStatus) {
    /**未确定*/
    FAuthorizationStatusNotDetermined = 0,
    /**限制*/
    FAuthorizationStatusRestricted,
    /**拒绝*/
    FAuthorizationStatusDenied,
    /**同意授权*/
    FAuthorizationStatusAuthorized,
};

typedef NS_ENUM(NSUInteger, FAuthorizationType) {
    //相机
    FAuthorizationTypeCamera       = 0,
    //麦克风
    FAuthorizationTypeMicrophone,
    //相册
    FAuthorizationTypeAlbumAddOnly,
    FAuthorizationTypeAlbumReadWrite,
    //定位
    FAuthorizationTypeLocation,
    
};

typedef void(^FAuthorityCallBack)(FAuthorizationStatus status);
typedef void(^FAuthorityRequestCallBack)(BOOL granted);

@protocol FDeviceAuthorityHandlerProtocol <NSObject>

- (BOOL)canHandler:(FAuthorizationType)type;
- (void)authority:(nonnull FAuthorityCallBack)callBack;
- (void)requestAuthority:(nonnull FAuthorityRequestCallBack)callBack;

@end



#endif /* FDeviceAuthorityHeader_h */
