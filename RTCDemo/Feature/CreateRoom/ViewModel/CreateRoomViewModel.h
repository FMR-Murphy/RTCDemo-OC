//
//  CreateRoomViewModel.h
//  RTCDemo
//
//  Created by Murphy on 2023/3/22.
//

#import <UIKit/UIKit.h>
@class LiveView;

typedef NSString * RoomUserId;
@class FBLPromise<__covariant Value>;

NS_ASSUME_NONNULL_BEGIN

@interface CreateRoomViewModel : NSObject


@property (nonatomic, readonly) NSString * roomId;
@property (nonatomic, readonly) RoomUserId userId;


- (FBLPromise *)createRoomWithId:(NSString *)roomId userId:(RoomUserId)userId;

- (void)setRenderViews:(NSArray<LiveView *> *)views;

/// 房主开播
- (void)startCapture;
/// 观众上播
- (void)startCaptureWithSeatIndex:(NSInteger)index;
/// 下麦
- (void)stopPublish;
/// 主播下播，销毁房间
- (void)destroy;

@end

NS_ASSUME_NONNULL_END
