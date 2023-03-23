//
//  HomeViewController.m
//  example-OC
//
//  Created by Murphy on 2022/8/19.
//

#import "HomeViewController.h"

#import "HomeViewModel.h"
#import "CreateRoomViewController.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

static NSString * RoomCellIdentifier = @"RoomCellIdentifier";

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) HomeViewModel *homeViewModel;
@property (nonatomic) UIButton *createButton;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createUI];
    [self bindAction];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RoomCellIdentifier];
    
    return cell;
}

#pragma mark - private
- (void)bindAction {
    @weakify(self);
    [[[self.createButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self goCreateRoomVC];
    }];
}

- (void)goCreateRoomVC {
    CreateRoomViewController *createVC = [[CreateRoomViewController alloc] init];
    [self.navigationController pushViewController:createVC animated:YES];
}

#pragma mark - UI
- (void)createUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"房间列表";
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIBarButtonItem * createItem = [[UIBarButtonItem alloc] initWithCustomView:self.createButton];
    self.navigationItem.rightBarButtonItem = createItem;
//    [self.navigationController.navigationItem setRightBarButtonItem:createItem];
}

#pragma mark - layz
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.rowHeight = 60;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:RoomCellIdentifier];
    }
    return _tableView;
}

- (UIButton *)createButton {
    if (!_createButton) {
        _createButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_createButton setTitle:@"创建房间" forState:UIControlStateNormal];
        [_createButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _createButton;
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
