//
//  FDeviceLocationAuthorityManagerHandler.m
//  example
//
//  Created by fang on 2021/7/4.
//

#import "FDeviceLocationAuthorityManagerHandler.h"

#import <CoreLocation/CoreLocation.h>

@interface FDeviceLocationAuthorityManagerHandler () <CLLocationManagerDelegate>

@property (nonatomic)FAuthorityRequestCallBack callBack;

@property (nonatomic)CLLocationManager * manager;
@end

@implementation FDeviceLocationAuthorityManagerHandler

+ (instancetype)sharedInstance {
    static FDeviceLocationAuthorityManagerHandler * locationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationManager = [[FDeviceLocationAuthorityManagerHandler alloc] init];
    });
    return locationManager;
}

- (BOOL)canHandler:(FAuthorizationType)type {
    return type == FAuthorizationTypeLocation;
}

- (void)authority:(FAuthorityCallBack)callBack {
    FAuthorizationStatus rStatus;
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            rStatus = FAuthorizationStatusNotDetermined;
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            rStatus = FAuthorizationStatusAuthorized;
            break;
        case kCLAuthorizationStatusDenied:
            rStatus = FAuthorizationStatusDenied;
            break;
        case kCLAuthorizationStatusRestricted:
            rStatus = FAuthorizationStatusRestricted;
            break;
        default:
            break;
    }
    callBack(rStatus);
}

- (void)requestAuthority:(FAuthorityRequestCallBack)callBack {
    self.callBack = callBack;
    [self.manager requestWhenInUseAuthorization];
}

/// iOS 14.0 及以后的方法
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    FAuthorizationStatus status;
    
    if (@available(iOS 14.0, *)) {
        status = manager.authorizationStatus;
    } else {
        // Fallback on earlier versions
        status = [CLLocationManager authorizationStatus];
    }
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        !self.callBack ?: self.callBack(YES);
    } else {
        !self.callBack ?: self.callBack(NO);
    }
}

//iOS 4.2 - 14.0
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        !self.callBack ?: self.callBack(YES);
    } else {
        !self.callBack ?: self.callBack(NO);
    }
}

- (CLLocationManager *)manager {
    if (!_manager) {
        _manager = [[CLLocationManager alloc] init];
        _manager.delegate = self;
    }
    return _manager;
}
@end
