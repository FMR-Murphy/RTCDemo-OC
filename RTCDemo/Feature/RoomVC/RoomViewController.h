//
//  RoomViewController.h
//  RTCDemo
//
//  Created by Murphy on 2023/3/22.
//

#import <UIKit/UIKit.h>
@class CreateRoomViewModel;
NS_ASSUME_NONNULL_BEGIN

@interface RoomViewController : UIViewController

/// YES 加入  NO 创建
@property (nonatomic) BOOL isCreate;

- (instancetype)initWithViewModel:(CreateRoomViewModel *)viewModel;


@end

NS_ASSUME_NONNULL_END
