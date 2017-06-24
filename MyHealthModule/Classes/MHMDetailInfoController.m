//
//  MHMDetailInfoController.m
//  MyHealthModule
//
//  Created by ChenWeidong on 16/2/26.
//  Copyright © 2016年. All rights reserved.
//

#import "MHMDetailInfoController.h"
#import "UIView+Layout.h"
#import "UtilsMacro.h"
#import "MHMHealthDataCell.h"
#import "MHMHealthDataSectionHeaderView.h"

@interface MHMDetailInfoController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tabelView;
@property (nonatomic, strong) NSArray *listModels;
@end

@implementation MHMDetailInfoController

- (instancetype)initWithListModels:(NSArray *)listModels {
    self = [super init];
    if (self) {
        _listModels = listModels;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBar.shadowImage = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"All Recorded Data";
    [self.view addSubview:self.tabelView];
    
    self.tabelView.hidden = (self.listModels.count == 0);
    [self.tabelView reloadData];
}

#pragma mark - tableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MHMHealthDataCell *cell = [MHMHealthDataCell cellWithTableView:tableView indexPath:indexPath];
    cell.healthModel = self.listModels[indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MHMHealthDataSectionHeaderView *headerView = [[MHMHealthDataSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    return headerView;
}

#pragma mark - getter
- (UITableView *)tabelView {
    if (!_tabelView) {
        _tabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - StatusBarHeight - NavBarHeight) style:UITableViewStyleGrouped];
        _tabelView.dataSource = self;
        _tabelView.delegate = self;
        [_tabelView registerClass:[MHMHealthDataCell class] forCellReuseIdentifier:NSStringFromClass([MHMHealthDataCell class])];
    }
    return _tabelView;
}

@end
