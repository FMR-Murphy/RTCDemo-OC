//
//  CreateRoomViewController.m
//  RTCDemo
//
//  Created by Murphy on 2023/3/22.
//

#import "CreateRoomViewController.h"

#import "CreateRoomViewModel.h"
#import "RoomViewController.h"

#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>
#import <FDeviceAuthorityManager/FDeviceAuthorityManager.h>
#if __has_include(<PromisesObjC/FBLPromise.h>)
#import <PromisesObjC/FBLPromises.h>
#else
#import <FBLPromises/FBLPromises.h>
#endif


@interface CreateRoomViewController ()

@property (nonatomic) UITextField * roomIDTextField;
@property (nonatomic) UITextField * userIdTextField;
@property (nonatomic) UIButton *createButton;
@property (nonatomic) UIButton *joinButton;
@property (nonatomic) UILabel * tipsLabel;

@property (nonatomic) CreateRoomViewModel *viewModel;
@end

@implementation CreateRoomViewController
- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createUI];
    [self bindAction];
}



#pragma mark - private
- (void)bindAction {
    
    @weakify(self);
    [[[self.roomIDTextField.rac_textSignal combineLatestWith:self.userIdTextField.rac_textSignal] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(RACTwoTuple<NSString *,id> * _Nullable x) {
        @strongify(self);
        if (self.roomIDTextField.text.length > 0 && self.userIdTextField.text.length > 0) {
            self.tipsLabel.hidden = YES;
        } else {
            self.tipsLabel.hidden = NO;
        }
    }];
    
    [[[self.createButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [[[[FDeviceAuthorityManager authorityWithType:FAuthorizationTypeCamera] then:^id _Nullable(id  _Nullable value) {
            return [FDeviceAuthorityManager authorityWithType:FAuthorizationTypeMicrophone];
        }] onQueue:dispatch_get_main_queue() then:^id _Nullable(id  _Nullable value) {
            [self createRoom:YES];
            return nil;
        }] catch:^(NSError * _Nonnull error) {
            NSLog(@"%@", error);
        }];
    }];
    
    [[[self.joinButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [[[[FDeviceAuthorityManager authorityWithType:FAuthorizationTypeCamera] then:^id _Nullable(id  _Nullable value) {
            return [FDeviceAuthorityManager authorityWithType:FAuthorizationTypeMicrophone];
        }] onQueue:dispatch_get_main_queue() then:^id _Nullable(id  _Nullable value) {
            [self createRoom:NO];
            return nil;
        }] catch:^(NSError * _Nonnull error) {
            NSLog(@"%@", error);
        }];
    }];
}

- (void)createRoom:(BOOL)isCreate {
    @weakify(self);
    [[self.viewModel createRoomWithId:self.roomIDTextField.text userId:self.userIdTextField.text] onQueue:dispatch_get_main_queue() then:^id _Nullable(id  _Nullable value) {
        @strongify(self);
        [self goRoomVC:isCreate];
        return nil;
    }];
}

- (void)goRoomVC:(BOOL)isCreate {
    RoomViewController * roomVC = [[RoomViewController alloc] initWithViewModel:self.viewModel];
    roomVC.isCreate = isCreate;
    [self.navigationController pushViewController:roomVC animated:YES];
    NSMutableArray *array = [self.navigationController.viewControllers mutableCopy];
    [array removeObject:self];
    [self.navigationController setViewControllers:array];
}

#pragma mark - UI
- (void)createUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"创建房间";
    [self.view addSubview:self.roomIDTextField];
    [self.view addSubview:self.userIdTextField];
    [self.view addSubview:self.tipsLabel];
    [self.view addSubview:self.createButton];
    [self.view addSubview:self.joinButton];
    
    [self.roomIDTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@40);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@50);
        make.top.equalTo(self.mas_topLayoutGuideBottom).offset(50);
    }];
    [self.userIdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.height.equalTo(self.roomIDTextField);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.roomIDTextField.mas_bottom).offset(20);
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.userIdTextField);
        make.top.equalTo(self.userIdTextField.mas_bottom).offset(10);
    }];
    
    [self.createButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@50);
        make.height.equalTo(@50);
        make.top.equalTo(self.userIdTextField.mas_bottom).offset(50);
    }];
    
    [self.joinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-50);
        make.height.width.top.equalTo(self.createButton);
    }];
//    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
//    [[IQKeyboardManager sharedManager] setEnable:YES];
}

#pragma mark - layz
- (UITextField *)roomIDTextField {
    if (!_roomIDTextField) {
        _roomIDTextField = [[UITextField alloc] init];
        _roomIDTextField.textColor = [UIColor blackColor];
        _roomIDTextField.placeholder = @"输入房间ID";
        _roomIDTextField.text = @"room0001";
    }
    return _roomIDTextField;
}

- (UITextField *)userIdTextField {
    if (!_userIdTextField) {
        _userIdTextField = [[UITextField alloc] init];
        _userIdTextField.textColor = [UIColor blackColor];
        _userIdTextField.placeholder = @"输入用户ID";
        _userIdTextField.text = @"123";
    }
    return _userIdTextField;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.text = @"用户ID和房间ID均不可为空";
        _tipsLabel.font = [UIFont systemFontOfSize:13];
        _tipsLabel.textColor = [UIColor redColor];
    }
    return _tipsLabel;
}

- (UIButton *)createButton {
    if (!_createButton) {
        _createButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_createButton setTitle:@"创建房间" forState:UIControlStateNormal];
        [_createButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _createButton;
}

- (UIButton *)joinButton {
    if (!_joinButton) {
        _joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_joinButton setTitle:@"加入房间" forState:UIControlStateNormal];
        [_joinButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _joinButton;
}

- (CreateRoomViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[CreateRoomViewModel alloc] init];
    }
    return _viewModel;
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
