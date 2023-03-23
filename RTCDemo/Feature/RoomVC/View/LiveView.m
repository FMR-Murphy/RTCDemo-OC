//
//  LiveView.m
//  RTCDemo
//
//  Created by Murphy on 2023/3/22.
//

#import "LiveView.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

#import "SeatInfoModel.h"

@interface LiveView ()

@property (nonatomic) UIView *renderView;
@property (nonatomic) UILabel *nameLabel;

@end

@implementation LiveView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
        [self bindAction];
    }
    return self;
}

- (void)createUI {
    [self addSubview:self.renderView];
    [self addSubview:self.nameLabel];
    [self.renderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@-10);
        make.left.equalTo(@10);
        make.right.equalTo(@-20);
    }];
}

- (void)bindAction {
    @weakify(self);
    [[[[RACObserve(self, seatInfo.userId) distinctUntilChanged] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.nameLabel.text = x;
    }];
}

#pragma mark - lazy
- (UIView *)renderView {
    if (!_renderView) {
        _renderView = [[UIView alloc] init];
        _renderView.userInteractionEnabled = NO;
    }
    return _renderView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.font = [UIFont systemFontOfSize:12];
        _nameLabel.textColor = [UIColor blackColor];
    }
    return _nameLabel;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
