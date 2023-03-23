//
//  VolcEngineService.m
//  RTCDemo
//
//  Created by Murphy on 2023/3/22.
//

#import "VolcEngineService.h"
#import <VolcEngineRTC/VolcEngineRTC.h>
#import <FBLPromises/FBLPromises.h>

static NSString * const VolcAppID = @"641ae5285f527801232a1be7";

@interface VolcEngineService () <ByteRTCVideoDelegate>

@property (nonatomic)ByteRTCVideo *rtcVideo;

@end

@implementation VolcEngineService

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - public
- (FBLPromise<ByteRTCVideo *> *)createRTCEngine {
    return [FBLPromise async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
        self.rtcVideo = [ByteRTCVideo createRTCVideo:VolcAppID delegate:self parameters:@{}];
        ByteRTCVideoEncoderConfig *solution = [[ByteRTCVideoEncoderConfig alloc] init];
        solution.width = 480;
        solution.height = 640;
        solution.frameRate = 30;
        solution.maxBitrate = 1500;
        [self.rtcVideo SetMaxVideoEncoderConfig:solution];
        [self.rtcVideo SetVideoEncoderConfig:@[solution]];
        [self.rtcVideo setVideoSourceType:ByteRTCVideoSourceTypeInternal WithStreamIndex:ByteRTCStreamIndexMain];
        [self.rtcVideo setVideoOrientation:ByteRTCVideoOrientationPortrait];

        fulfill(self.rtcVideo);
    }];
}

- (void)startCapture {
    // 开始音频采集
    [self.rtcVideo startAudioCapture];
    // 开始视频采集
    [self.rtcVideo startVideoCapture];
}

- (void)stopCapture {
    [self.rtcVideo stopAudioCapture];
    [self.rtcVideo stopVideoCapture];
}

#pragma mark - ByteRTCVideoDelegate

- (void)rtcEngine:(ByteRTCVideo *)engine onWarning:(ByteRTCWarningCode)Code {
    NSLog(@"%s - %zi", __func__, Code);
}

- (void)rtcEngine:(ByteRTCVideo *)engine onError:(ByteRTCErrorCode)errorCode {
    NSLog(@"%s - %zi", __func__, errorCode);
}

- (void)rtcEngine:(ByteRTCVideo *)engine onCreateRoomStateChanged:(NSString *)roomId errorCode:(NSInteger)errorCode {
    NSLog(@"%s - %@:%zi", __func__, roomId, errorCode);
}

- (void)rtcEngine:(ByteRTCVideo *)engine connectionChangedToState:(ByteRTCConnectionState)state {
    NSLog(@"%s - %zi", __func__, state);
}

- (void)rtcEngine:(ByteRTCVideo *)engine networkTypeChangedToType:(ByteRTCNetworkType)type {
    NSLog(@"%s - %zi", __func__, type);

}

- (void)rtcEngine:(ByteRTCVideo *)engine onUserMuteAudio:(NSString *)roomId uid:(NSString *)uid muteState:(ByteRTCMuteState)muteState {
    NSLog(@"%s - room:%@ - user:%@ - %zi", __func__, roomId, uid, muteState);
}

- (void)rtcEngine:(ByteRTCVideo *)engine onUserStopAudioCapture:(NSString *)roomId uid:(NSString *)userId {
    NSLog(@"%s - room:%@ - user:%@", __func__, roomId, userId);
}

- (void)rtcEngine:(ByteRTCVideo *)engine onVideoDeviceStateChanged:(NSString *)device_id device_type:(ByteRTCVideoDeviceType)device_type device_state:(ByteRTCMediaDeviceState)device_state device_error:(ByteRTCMediaDeviceError)device_error {
    NSLog(@"%s - device_state:%zi - device_error:%zi", __func__, device_state, device_error);
}

@end
