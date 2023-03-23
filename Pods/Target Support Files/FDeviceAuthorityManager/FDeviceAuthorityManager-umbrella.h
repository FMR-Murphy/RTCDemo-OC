#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "FDeviceAlbumAuthorityHandler.h"
#import "FDeviceAuthorityHeader.h"
#import "FDeviceAuthorityManager.h"
#import "FDeviceCaptureAuthorityHandler.h"
#import "FDeviceLocationAuthorityManagerHandler.h"

FOUNDATION_EXPORT double FDeviceAuthorityManagerVersionNumber;
FOUNDATION_EXPORT const unsigned char FDeviceAuthorityManagerVersionString[];

