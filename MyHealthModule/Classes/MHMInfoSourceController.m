//
//  MHMInfoSourceController.m
//  MyHealthModule
//
//  Created by ChenWeidong on 16/2/26.
//  Copyright © 2016年. All rights reserved.
//

#import "MHMInfoSourceController.h"
#import "UIView+Layout.h"
#import "UtilsMacro.h"
#import "MHMHealthDataSourceCell.h"

@interface MHMInfoSourceController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation MHMInfoSourceController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Data Sources";

    [self.view addSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBar.shadowImage = nil;
}

#pragma mark - tableViewdataSource 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MHMHealthDataSourceCell *cell = [MHMHealthDataSourceCell cellWithTableView:tableView indexPath:indexPath];
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"My Data Sources:";
}

#pragma mark - getter 
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - NavBarHeight - StatusBarHeight) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[MHMHealthDataSourceCell class] forCellReuseIdentifier:NSStringFromClass([MHMHealthDataSourceCell class])];
    }
    return _tableView;
}

@end
