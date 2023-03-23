//
//  LiveView.h
//  RTCDemo
//
//  Created by Murphy on 2023/3/22.
//

#import <UIKit/UIKit.h>
@class SeatInfoModel;

NS_ASSUME_NONNULL_BEGIN

@interface LiveView : UIControl

@property (nonatomic, readonly) UIView *renderView;

@property (nonatomic, nullable) SeatInfoModel *seatInfo;

@end

NS_ASSUME_NONNULL_END
