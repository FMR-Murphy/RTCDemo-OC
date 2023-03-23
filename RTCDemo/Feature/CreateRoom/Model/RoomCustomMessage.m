//
//  RoomCustomMessage.m
//  RTCDemo
//
//  Created by Murphy on 2023/3/23.
//

#import "RoomCustomMessage.h"

@interface RoomCustomMessage ()

/// 1000 上麦
@property (nonatomic) RoomMessageAction action;
/// 内容
@property (nonatomic, nullable) NSString * content;


@end

@implementation RoomCustomMessage

+ (instancetype)messageWithAction:(RoomMessageAction)action content:(NSString * _Nullable)content {
    RoomCustomMessage *message = [[RoomCustomMessage alloc] init];
    message.action = action;
    message.content = content;
    return message;
}

@end
