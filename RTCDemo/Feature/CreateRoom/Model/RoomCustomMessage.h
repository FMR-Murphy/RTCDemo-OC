//
//  RoomCustomMessage.h
//  RTCDemo
//
//  Created by Murphy on 2023/3/23.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RoomMessageAction) {
    RoomMessageActionBeMc = 0,
    
};

NS_ASSUME_NONNULL_BEGIN

@interface RoomCustomMessage : NSObject

/// 1000 上麦
@property (nonatomic, readonly) RoomMessageAction action;
/// 内容
@property (nonatomic, readonly, nullable) NSString * content;

+ (instancetype)messageWithAction:(RoomMessageAction)action content:(NSString * _Nullable)content;

@end

NS_ASSUME_NONNULL_END
