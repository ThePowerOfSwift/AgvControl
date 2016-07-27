//
//  FirstViewController.m
//  HitProject
//
//  Created by 郭龙 on 15/10/29.
//  Copyright (c) 2015年 郭龙. All rights reserved.
//

#import "FirstViewController.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "ConnectStatesCell.h"
#import "SettingViewController.h"
#import "LoginViewController.h"
#import <TSTableView.h>
#import <TSTableViewModel.h>
#import "MapView.h"

//#import "ServerSocket.h"
//#import "UdpServerSocket.h"

#define LEFTPADING   15
#define TOPPADING    45
#define RIGHTPADING  15
#define BOTTOMPADING 25
#define MAPWIDTH     1600
#define MAPHEIGHT    900
#define TAPHEIGHT    49

@interface FirstViewController ()  <UITableViewDelegate, UITableViewDataSource>
{
    NSInteger screenWidth;
    UIView *mapContainer;
    UIView *stationContainer;
    UIView *detailContainer;
    
}

//@property (nonatomic) UdpServerSocket *server;
@property (nonatomic) HitControl *control;
@property (nonatomic) BOOL isStart;

@end

@implementation FirstViewController
@synthesize control;
@synthesize isStart;

#pragma mark - lifecicle
- (instancetype)init {
    self = [super init];
    if (self) {
        self  = [super init];
        control = [HitControl sharedControl];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToForground:) name:NOTICE_FORGRAOUND object:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    MainViewController *main =(MainViewController *) self.tabBarController;
    if (![CommonsFunc isDeviceIpad]) {
        main.rightsideContainer.hidden = NO;
        main.p_debugLabel.hidden = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];//[CommonsFunc colorOfSystemBackground];
    isStart = NO;
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    [self addContainerView];
    
    
    /*
    UIButton *settingBtn = [UIButton new];
    [settingBtn setTitle:@"设置" forState:UIControlStateNormal];
    [settingBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [settingBtn setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    [self.view addSubview:settingBtn];
    [settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([CommonsFunc isDeviceIpad]) {
            make.bottom.equalTo(self.view).offset(-60);
            make.left.equalTo(self.view).offset(20);
        } else {
            make.top.equalTo(self.view).offset(15);
            make.right.equalTo(self.view).offset(-15);
        }
    }];
    [settingBtn addTarget:self action:@selector(setting:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout:) name:NOTICE_LOGOUTSUCCESS object:nil];
    */
}

//input realPotision
//output mapPositiion
- (CGPoint) changeCood: (CGPoint )inputPoint
{
    int realX = mapContainer.bounds.size.width;
    int realY = mapContainer.bounds.size.height;
    
    float scalX = MAPWIDTH / realX;
    float scalY = MAPHEIGHT / realY;
    int x = inputPoint.x / scalX;
    int y = inputPoint.y / scalY;
    CGPoint newPoit = CGPointMake(x, y);
    
    return newPoit;
}

#pragma mark - addSubViews
- (void)addContainerView
{
    mapContainer = [UIView new];
    [self.view addSubview:mapContainer];
    mapContainer.backgroundColor = [UIColor darkGrayColor];
    [mapContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(LEFTPADING);
        make.top.equalTo(self.view).offset(TOPPADING);
        make.size.mas_equalTo(CGSizeMake(MAPWIDTH, MAPHEIGHT));
    }];
    
    [self mapContainerAddSubviews];
    
    
    stationContainer = [UIView new];
    stationContainer.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:stationContainer];
    [stationContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mapContainer);
        make.left.equalTo(mapContainer.mas_right).offset(LEFTPADING);
        make.right.equalTo(self.view).offset(-RIGHTPADING);
        make.bottom.equalTo(self.view).offset(-(TAPHEIGHT+BOTTOMPADING));
    }];
    
    [self stationContainerAddSubviews];
    
    
    detailContainer = [UIView new];
    [self.view addSubview:detailContainer];
    [detailContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(mapContainer);
        make.bottom.equalTo(stationContainer);
        make.top.equalTo(mapContainer.mas_bottom).offset(15);
        make.right.equalTo(mapContainer);
    }];
    
    [self detailContainerAddSubviews];
    
}

- (void) mapContainerAddSubviews
{
    //add map
    MapView *map = [[MapView alloc] initWithFrame:mapContainer.bounds];
    [mapContainer addSubview:map];
    
}

- (void) stationContainerAddSubviews
{
    //add tabelview
    UITableView *tableView  = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) style:UITableViewStylePlain];
    [stationContainer addSubview:tableView];
    tableView.backgroundColor = [UIColor whiteColor];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(stationContainer).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    tableView.delegate = self;
    tableView.dataSource = self;
    
}

- (void) detailContainerAddSubviews
{
    //add tstableview
    NSArray *columns = @[
                         @{ @"title" : @"agv 编号"},
                         @{ @"title" : @"1 号车"},
                         @{ @"title" : @"2 号车"},
                         @{ @"title" : @"3 号车", @"titleColor" : @"FF00CF00"}
                         ];
    
    NSArray *rows = @[
                      @{ @"cells" : @[
                                 @{ @"value" : @"当前站点"},
                                 @{ @"value" : @1},
                                 @{ @"value" : @2},
                                 @{ @"value" : @3}
                                 ]
                         },
                      @{ @"cells" : @[
                                 @{ @"value" : @"目标站点"},
                                 @{ @"value" : @2},
                                 @{ @"value" : @3},
                                 @{ @"value" : @4}
                                 ]
                         },
                      @{ @"cells" : @[
                                 @{ @"value" : @"运行状态"},
                                 @{ @"value" : @"获取失败"},
                                 @{ @"value" : @"获取失败"},
                                 @{ @"value" : @"获取失败"}
                                 ]
                         }
                      ];
    
    TSTableView *tableView = [[TSTableView alloc] initWithFrame: detailContainer.bounds];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //tableView.delegate = self;
    [self.view addSubview:tableView];
    
    TSTableViewModel  *dataModel = [[TSTableViewModel alloc] initWithTableView:tableView andStyle:kTSTableViewStyleDark];
    [dataModel setColumns:columns andRows:rows];
    
}


#pragma mark - tableviewDele
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CMainCell = @"CMainCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CMainCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier: CMainCell];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"工位：%ld", indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"button"];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

#pragma mark - noti
/**
 *  返回该程序后的重新监听
 *  @param
 */
- (void)backToForground :(NSNotification *)noti
{
    NSLog(@"backToForground noti");
    if ([ServerSocket sharedSocket].isRunning) {
        [control startListen];
    }
}

#pragma mark - action.
- (void)logout:(id)sender {
    MainViewController *main =(MainViewController *) self.tabBarController;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // 在delegate中初始化新的controller
    // 修改rootViewController
    // [delegate.window addSubview:delegate.main.view];
    [main.view removeFromSuperview];
    delegate.window.rootViewController = [LoginViewController new];
}

- (void)setting :(id) sender {
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[SettingViewController new]];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playBtnTaped:(UIButton *)btn {
    NSLog(@"image taped");
    
    if (isStart == NO) {
        isStart = YES;
        [control startListen];
        [btn setBackgroundColor:[UIColor lightGrayColor]];
        [btn setTitle:@"停止服务" forState:UIControlStateNormal];
    }else
    {
        isStart = NO;
        [control stopAll];
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn setTitle:@"开始服务" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSString *)deviceIPAdress {
    NSString *address = @"an error occurred when obtaining ip address";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0) { // 0 表示获取成功
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    NSLog(@"server的IP是：%@", address);
    return address;  
}

@end
