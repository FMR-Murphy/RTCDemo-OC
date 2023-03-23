//
//  RoomViewController.m
//  RTCDemo
//
//  Created by Murphy on 2023/3/22.
//

#import "RoomViewController.h"

#import "CCServiceRegistryService.h"
#import "VolcEngineService.h"
#import <VolcEngineRTC/VolcEngineRTC.h>
#if __has_include(<PromisesObjC/FBLPromise.h>)
#import <PromisesObjC/FBLPromises.h>
#else
#import <FBLPromises/FBLPromises.h>
#endif
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>
#import "CreateRoomViewModel.h"
#import "LiveView.h"
#import "SeatInfoModel.h"

@interface RoomViewController ()

@property (nonatomic) LiveView *liveView;
@property (nonatomic) LiveView *liveView1;
@property (nonatomic) LiveView *liveView2;

@property (nonatomic) CreateRoomViewModel *viewModel;
@property (nonatomic) UIStackView *stackView;
@end

@implementation RoomViewController
- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (instancetype)initWithViewModel:(CreateRoomViewModel *)viewModel
{
    self = [super init];
    if (self) {
        self.viewModel = viewModel;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createUI];
    [self bindAction];
    [self.viewModel setRenderViews:@[self.liveView, self.liveView1, self.liveView2]];
    if (self.isCreate) {
        [self.viewModel startCapture];
    }
}

#pragma mark - private
- (void)createUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.liveView];
    [self.view addSubview:self.liveView1];
    [self.view addSubview:self.liveView2];
    
    [self.liveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(10);
        make.height.equalTo(self.liveView.mas_width).multipliedBy(1080.0/720.0);
    }];
    
    [self.liveView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.liveView);
        make.left.equalTo(self.liveView.mas_right).offset(10);
        make.width.height.equalTo(self.liveView);
    }];
    [self.liveView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.liveView);
        make.left.equalTo(self.liveView1.mas_right).offset(10);
        make.width.height.equalTo(self.liveView);
        make.right.equalTo(@-20);
    }];
}

- (void)bindAction {
    RACSignal *signal = [self.liveView rac_signalForControlEvents:UIControlEventTouchUpInside];
    RACSignal *signal1 = [self.liveView1 rac_signalForControlEvents:UIControlEventTouchUpInside];
    RACSignal *signal2 = [self.liveView2 rac_signalForControlEvents:UIControlEventTouchUpInside];
    @weakify(self);
    [[[RACSignal merge:@[signal, signal1, signal2]] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(LiveView * _Nullable x) {
        @strongify(self);
        if (x.seatInfo) {
            if ([x.seatInfo.userId isEqualToString:self.viewModel.userId]) {
                if (self.isCreate) {
                    [self.viewModel destroy];
                } else {
                    [self.viewModel stopPublish];
                }
            } else {
                NSLog(@"已经有人了，给他点个赞吧。");
            }
        } else {
            [self.viewModel startCaptureWithSeatIndex:x.tag];
        }
    }];
}



 #pragma mark - lazy
- (LiveView *)liveView {
    if (!_liveView) {
        _liveView = [self createLiveView];
        _liveView.tag = 0;
    }
    return _liveView;
}

- (LiveView *)liveView1 {
    if (!_liveView1) {
        _liveView1 = [self createLiveView];
        _liveView1.tag = 1;
    }
    return _liveView1;
}

- (LiveView *)liveView2 {
    if (!_liveView2) {
        _liveView2 = [self createLiveView];
        _liveView2.tag = 2;
    }
    return _liveView2;
}

- (LiveView *)createLiveView {
    LiveView *view = [[LiveView alloc] init];
    view.backgroundColor = [UIColor grayColor];
    return view;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
