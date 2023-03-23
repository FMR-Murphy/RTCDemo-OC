//
//  VolcEngineService.h
//  RTCDemo
//
//  Created by Murphy on 2023/3/22.
//

#import <Foundation/Foundation.h>
@protocol ByteRTCRoomDelegate;
@class ByteRTCVideo;
@class ByteRTCRoom;
@class FBLPromise<__covariant Value>;

NS_ASSUME_NONNULL_BEGIN

@interface VolcEngineService : NSObject

@property (nonatomic, readonly) ByteRTCVideo *rtcVideo;

/// 创建 rtcVideo 引擎
- (FBLPromise<ByteRTCVideo *> *)createRTCEngine;

- (void)startCapture;
- (void)stopCapture;
@end

NS_ASSUME_NONNULL_END
