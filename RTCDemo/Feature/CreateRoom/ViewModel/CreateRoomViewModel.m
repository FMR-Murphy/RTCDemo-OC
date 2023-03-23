//
//  CreateRoomViewModel.m
//  RTCDemo
//
//  Created by Murphy on 2023/3/22.
//

#import "CreateRoomViewModel.h"

#import "CCServiceRegistryService.h"
#import "VolcEngineService.h"
#import <FBLPromises/FBLPromises.h>
#import <VolcEngineRTC/VolcEngineRTC.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <YYModel/YYModel.h>
#import "LiveView.h"
#import "RoomCustomMessage.h"
#import "SeatInfoModel.h"


@interface CreateRoomViewModel() <ByteRTCRoomDelegate>

@property (nonatomic) NSString * roomId;
@property (nonatomic) NSString * userId;

@property (nonatomic) NSArray<LiveView *> *renderViews;

@property (nonatomic) NSMutableDictionary<RoomUserId, LiveView *> *viewDic;

@property (nonatomic)ByteRTCRoom *rtcRoom;

@end

@implementation CreateRoomViewModel

- (FBLPromise *)createRoomWithId:(NSString *)roomId userId:(RoomUserId)userId {
    self.roomId = roomId;
    self.userId = userId;
    @weakify(self);
    return [[CCGetServicePromise(VolcEngineService) then:^id _Nullable(VolcEngineService * _Nullable value) {
        return [value createRTCEngine];
    }] then:^id _Nullable(ByteRTCVideo * _Nullable value) {
        @strongify(self);
        NSString * token = [self tokenDic][userId];
        self.rtcRoom = [value createRTCRoom:roomId];
        self.rtcRoom.delegate = self;
        ByteRTCUserInfo *userInfo = [[ByteRTCUserInfo alloc] init];
        userInfo.userId = userId;
        ByteRTCRoomConfig *config = [[ByteRTCRoomConfig alloc] init];
        
        config.isAutoPublish = NO;
        config.isAutoSubscribeAudio = YES;
        config.isAutoSubscribeVideo = YES;
        [self.rtcRoom joinRoomByToken:token userInfo:userInfo roomConfig:config];
        
        ByteRTCVideoEncoderConfig *solution = [[ByteRTCVideoEncoderConfig alloc] init];
        solution.width = 480;
        solution.height = 640;
        solution.frameRate = 30;
        solution.maxBitrate = 1500;
        [value SetMaxVideoEncoderConfig:solution];
        [value SetVideoEncoderConfig:@[solution]];

        return nil;
    }];
}


- (void)setRenderViews:(NSArray<LiveView *> *)views {
    _renderViews = views;
}

- (void)startCapture {
    [self startCaptureWithSeatIndex:0];
}

/// 上麦
- (void)startCaptureWithSeatIndex:(NSInteger)index {
    LiveView *view = self.renderViews[index];
    [self updateSeatInfo:self.userId seatIndex:index];
    [self setLocalVideoView:view userId:self.userId];
    @weakify(self);
    [CCGetServicePromise(VolcEngineService) onQueue:dispatch_get_main_queue() then:^id _Nullable(VolcEngineService * _Nullable value) {
        @strongify(self);
        [value startCapture];
        int publish = [self.rtcRoom publishStream:ByteRTCMediaStreamTypeBoth];
        NSLog(@"%s 推流%@", __func__, publish == 0 ?@"成功":@"失败");
        
        return nil;
    }];
}

- (void)stopPublish {
    @weakify(self);
    [self removeSeatInfo:self.userId];
    [CCGetServicePromise(VolcEngineService) onQueue:dispatch_get_main_queue() then:^id _Nullable(VolcEngineService * _Nullable value) {
        @strongify(self);
        [value stopCapture];
        [self.rtcRoom unpublishStream:ByteRTCMediaStreamTypeBoth];
        return nil;
    }];
    
}

- (void)destroy{
    @weakify(self);
    [CCGetServicePromise(VolcEngineService) onQueue:dispatch_get_main_queue() then:^id _Nullable(VolcEngineService * _Nullable value) {
        @strongify(self);
        [value stopCapture];
        [self.rtcRoom destroy];
        return nil;
    }];
}

/// 更新麦位信息
- (void)updateSeatInfo:(RoomUserId)userId seatIndex:(NSInteger)index {
    LiveView *view = self.renderViews[index];
    SeatInfoModel * seatInfo = [[SeatInfoModel alloc] init];
    seatInfo.userId = userId;
    seatInfo.seatIndex = index;
    view.seatInfo = seatInfo;
    self.viewDic[userId] = view;
}

/// 移除麦位信息
- (void)removeSeatInfo:(RoomUserId)userId {
    LiveView *view = self.viewDic[userId];
    view.seatInfo = nil;
    self.viewDic[userId] = nil;
}

- (void)setLocalVideoView:(LiveView *)view userId:(RoomUserId)userId {
    @weakify(self);
    [CCGetServicePromise(VolcEngineService) then:^id _Nullable(VolcEngineService * _Nullable value) {
        @strongify(self);
        ByteRTCVideoCanvas *canvas = [self canvasWithView:view.renderView userId:userId];
        [value.rtcVideo setLocalVideoCanvas:ByteRTCStreamIndexMain withCanvas:canvas];
        return nil;
    }];
}

- (void)setRemoteVideoView:(LiveView *)view userId:(RoomUserId)userId {
    @weakify(self);
    [CCGetServicePromise(VolcEngineService) then:^id _Nullable(VolcEngineService * _Nullable value) {
        @strongify(self);
        ByteRTCVideoCanvas *canvas = [self canvasWithView:view.renderView userId:userId];
        [value.rtcVideo setRemoteVideoCanvas:userId withIndex:ByteRTCStreamIndexMain withCanvas:canvas];
        return nil;
    }];
}



- (ByteRTCVideoCanvas *)canvasWithView:(UIView *)view userId:(RoomUserId)userId {
    ByteRTCVideoCanvas *canvas = [[ByteRTCVideoCanvas alloc] init];
    canvas.view = view;
    canvas.roomId = self.roomId;
    canvas.uid = userId;
    canvas.renderMode = ByteRTCRenderModeFit;
    return canvas;
}

- (void)setRemote:(RoomUserId)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        LiveView *view = self.viewDic[userId];
        if (!view) {
            view = [self getEmptyLiveView];
        }
        [self updateSeatInfo:userId seatIndex:view.tag];
        // 未找到对应座位 接到
        if (!view) {
            NSLog(@"没有找到空座位");
            return;
        }
        [self setRemoteVideoView:view userId:userId];
    });
}

- (LiveView *)getEmptyLiveView {
    LiveView *view;
    for (int i = 0; i < self.renderViews.count; i ++) {
        LiveView *v = self.renderViews[i];
        if (v.seatInfo == nil) {
            view = v;
            break;
        }
    }
    return view;
}

#pragma mark - ByteRTCRoomDelegate
/// 房间状态改变回调，加入房间、异常退出房间、发生房间相关的警告或错误时会收到此回调
- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onRoomStateChanged:(NSString *)roomId withUid:(NSString *)uid state:(NSInteger)state extraInfo:(NSString *)extraInfo {
    NSLog(@"%s - room:%@ - user:%@ - state:%zi - info:%@", __func__, roomId, uid, state, extraInfo);
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onStreamStateChanged:(NSString *)roomId withUid:(NSString *)uid state:(NSInteger)state extraInfo:(NSString *)extraInfo {
    NSLog(@"%s - room:%@ - user:%@ - state:%zi - info:%@", __func__, roomId, uid, state, extraInfo);
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onRoomWarning:(ByteRTCWarningCode)warningCode {
    NSLog(@"%s - %zi", __func__, warningCode);
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onRoomError:(ByteRTCErrorCode)errorCode {
    NSLog(@"%s - %zi", __func__, errorCode);
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onLocalStreamStats:(ByteRTCLocalStreamStats *)stats {
    NSLog(@"%s - %@", __func__, [stats yy_modelToJSONObject]);
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onUserPublishStream:(NSString *)userId type:(ByteRTCMediaStreamType)type {
    if (type == ByteRTCMediaStreamTypeVideo || type == ByteRTCMediaStreamTypeBoth) {
//        ByteRTCRemoteStreamKey *streamKey = [[ByteRTCRemoteStreamKey alloc] init];
//        streamKey.userId = userId;
//        streamKey.streamIndex = ByteRTCStreamIndexMain;
//        streamKey.roomId = self.roomId;
//        [self setRemoteView:streamKey];
        [self setRemote:userId];
    }
}


- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onRoomMessageReceived:(NSString *)uid message:(NSString *)message {
    RoomCustomMessage *msg = [RoomCustomMessage yy_modelWithJSON:message];
    if (msg.action == RoomMessageActionBeMc) {
        // 有人上麦，更新麦位信息
        [self updateSeatInfo:uid seatIndex:msg.content.integerValue];
    }
}

/// 用户离开房间
- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onUserLeave:(NSString *)uid reason:(ByteRTCUserOfflineReason)reason {
    [self removeSeatInfo:uid];
}

/// 有用户停止推流
- (void)rtcRoom:(ByteRTCRoom *)rtcRoom didStreamRemoved:(NSString *)uid stream:(id<ByteRTCStream>)stream reason:(ByteRTCStreamRemoveReason)reason {
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onUserUnpublishStream:(NSString *)userId type:(ByteRTCMediaStreamType)type reason:(ByteRTCStreamRemoveReason)reason {
    NSLog(@"停止推流 user:%@", userId);
    [self removeSeatInfo:userId];

}

#pragma mark - lazy
- (NSMutableDictionary<NSString *,LiveView *> *)viewDic {
    if (!_viewDic) {
        _viewDic = [NSMutableDictionary dictionary];
    }
    return _viewDic;
}

- (NSDictionary *)tokenDic {
    /// room0001
    return @{
        @"123":@"001641ae5285f527801232a1be7QQAQHNsB+uUaZHogJGQIAHJvb20wMDAxAwAxMjMGAAAAeiAkZAEAeiAkZAIAeiAkZAMAeiAkZAQAeiAkZAUAeiAkZCAA8JRQqehJVsGDj3+0T4192czNz6QwvFMumJmBrlK+QJw=",
        @"456":@"001641ae5285f527801232a1be7QQB++C0DhBQcZARPJWQIAHJvb20wMDAxAwA0NTYGAAAABE8lZAEABE8lZAIABE8lZAMABE8lZAQABE8lZAUABE8lZCAAwq8qUx+sytp1eRes0fvXVszJY9nqdIXDQdIBwHd2y58=",
    };
}

@end
