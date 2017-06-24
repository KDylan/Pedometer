//
//  MHMHomePageController.m
//  MyHealthModule
//
//  Created by ChenWeidong on 16/2/26.
//  Copyright © 2016年. All rights reserved.
//

#import "MHMHomePageController.h"
#import "UtilsMacro.h"
#import "MHMDetailInfoController.h"
#import "MHMInfoSourceController.h"
#import <ReactiveCocoa.h>
#import "UIView+Layout.h"
#import "MHMLineChartView.h"
#import "MHMHealthManager.h"
#import "MHMHelper.h"

static NSInteger const topViewHeight = 64;
static NSString *kMHMNormalCellIdentifier = @"MHMNormalCellIdentifier";

@interface MHMHomePageController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *jumpControllers;
@property (nonatomic, strong) UISegmentedControl *dateSegmentControl;

@property (nonatomic, strong) MHMLineChartView *lineChartView;
@property (nonatomic, strong) MHMHealthManager *healthManager;

@property (nonatomic, strong) NSArray *listModels;
@property (nonatomic, strong) NSDictionary *dayResultDict;//存储日数据
@property (nonatomic, strong) NSDictionary *weekResultDict;//存储周数据
@property (nonatomic, strong) NSDictionary *monthResultDict;//存储月数据
@property (nonatomic, strong) NSDictionary *yearResultDict;//存储年数据
@property (nonatomic, assign) NSInteger dayAverage;//日/周对应的日平均值
@property (nonatomic, assign) NSInteger yearAverage;//年对应的日平均值

@property (nonatomic, assign) BOOL isShowAlert;
@end

@implementation MHMHomePageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Steps";
   
      //self.navigationItem.backBarButtonItem.title = @"Back";
    //setupView、setupData、bindingData这三个方法是放在基类中的viewDidLoad调用的，
    //子类中调用[super viewDidLoad]时会自动调用这三个方法
}

- (void)setupView {
    [self.view addSubview:self.tableView];
    
    [self setupTopView];
    
//    UIView *tableHeaderView = [[UIView alloc] init];
//    tableHeaderView.height = 200;
  //  self.tableView.tableHeaderView = tableHeaderView;
    
    [self.view addSubview:self.lineChartView];
  //  self.lineChartView.center = tableHeaderView.center;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
}

- (void)setupData {
    //一次性获取 日/周/月/年 数据并存储
    @weakify(self);
    [self fetchHealthData:MHMHealthIntervalUnitDay resultBlock:^(NSDictionary *queryResultDict) {
        @strongify(self);
        self.dayResultDict = queryResultDict;
        self.dayAverage =[queryResultDict[kTotalStepCountKey] integerValue]/24;
     //   NSLog(@"kTotalStepCountKey = %ld",(long)self.dayAverage);
    }];
    
    [self fetchHealthData:MHMHealthIntervalUnitWeek resultBlock:^(NSDictionary *queryResultDict) {
        @strongify(self);
        self.weekResultDict = queryResultDict;
        if (((NSArray *)queryResultDict[kResultModelsKey]).count <= 0) {
            return;
        }
        
        self.lineChartView.averageStepCount = [queryResultDict[kTotalStepCountKey] integerValue] / ((NSArray *)queryResultDict[kResultModelsKey]).count;
      
        self.dayAverage = self.lineChartView.averageStepCount;//存储日/周对应的日平均值
    }];
    
    [self fetchHealthData:MHMHealthIntervalUnitMonth resultBlock:^(NSDictionary *queryResultDict) {
        @strongify(self);
        self.monthResultDict = queryResultDict;
    }];
    
    [self fetchHealthData:MHMHealthIntervalUnitYear resultBlock:^(NSDictionary *queryResultDict) {
        @strongify(self);
        self.yearResultDict = queryResultDict;
        if (((NSArray *)queryResultDict[kResultModelsKey]).count <= 0) {
            return;
        }
        //存储年对应的日平均值
        self.yearAverage = [queryResultDict[kTotalStepCountKey] integerValue] / (self.listModels.count - 1);
        
   //     NSLog(@" self.yearAverage = %ld", (long)self.yearAverage);
    }];
    
    
}

- (void)bindingData {
    @weakify(self);
    [[self.dateSegmentControl rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(UISegmentedControl *segmentControl) {
        @strongify(self);
        __block NSDictionary *dict;
        switch (segmentControl.selectedSegmentIndex) {
            case 0:
                dict = self.dayResultDict;
                break;
            case 1:
                dict = self.weekResultDict;
                break;
            case 2:
                dict = self.monthResultDict;
                break;
            case 3:
                dict = self.yearResultDict;
                break;
        }
        if (dict) {
            [self.lineChartView setupChartWithDictionary:dict index:segmentControl.selectedSegmentIndex];
        } else {
            [self fetchHealthData:segmentControl.selectedSegmentIndex resultBlock:^(NSDictionary *queryResultDict) {
                dict = queryResultDict;
            }];
        }
        //选择为 日/年 的话，手动修改对应日平均值
        if (segmentControl.selectedSegmentIndex == 0) {
            self.lineChartView.averageStepCount = self.dayAverage;
        } else if (segmentControl.selectedSegmentIndex == 3) {
            self.lineChartView.averageStepCount = self.yearAverage;
        }
    }];
}

#pragma mark - custom Method
- (void)fetchHealthData:(MHMHealthIntervalUnit)unit
            resultBlock:(void (^)(NSDictionary *queryResultDict))resultBlock {
    if (![self.healthManager isHealthDataAvailable]) {
        [self showAlert:@"Current system does not support health data acquisition !"];
    } else {
        @weakify(self);
        [self.healthManager authorizateHealthKit:^(BOOL isAuthorizateSuccess) {
            @strongify(self);
            if (isAuthorizateSuccess) {
                if (!self.listModels) {//全部数据获取 这里只获取一次
                    [self.healthManager fetchAllHealthDataByDay:^(NSArray *modelArray) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (modelArray) {
                                
                                self.listModels = modelArray;
                                
                               
                             //   NSLog(@" self.listModels = %@", self.listModels);
                            }
                        });
                    }];
                    
                }
                [self.healthManager fetchHealthDataForUnit:unit queryResultBlock:^(NSDictionary *queryResultDict) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (resultBlock) {
                            resultBlock(queryResultDict);
                        }
                        if (self.dateSegmentControl.selectedSegmentIndex == unit) {
                          
                            [self.lineChartView setupChartWithDictionary:queryResultDict index:self.dateSegmentControl.selectedSegmentIndex];
                        }
                    });
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlert:F(@"Please read the data in the privacy of health %@ APP", AppName)];
                });
            }
        }];
    }
   
}

- (void)showAlert:(NSString *)prompt {
    if (self.isShowAlert) {//提示语只显示一次，之后获取信息出现则不提示
        return;
    }
    
    ALERT(prompt, nil);
    self.isShowAlert = YES;
}

//  设置年月日的view
- (void)setupTopView {
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, topViewHeight)];
    
    //topView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:topView];
    
    [topView addSubview:self.dateSegmentControl];
    self.dateSegmentControl.center = topView.center;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, topView.bottom - 0.5, topView.width, 0.5)];
    
    line.backgroundColor = RGB(185, 185, 185);
    
    [topView addSubview:line];
}


#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   // NSLog(@"%lu",(unsigned long)self.titles.count);
    return self.titles.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMHMNormalCellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:kMHMNormalCellIdentifier];
    }
    
    cell.textLabel.text = self.titles[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14];

    cell.detailTextLabel.textColor = HEXCOLOR(0x2a2a2a);
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    if (indexPath.row == 2) {
        cell.textLabel.textColor = HEXCOLOR(0x2a2a2a);
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = @"Steps";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.textLabel.textColor = HEXCOLOR(0x2a2a2a);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = @"";
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    return cell;
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 2) {
        return;
    }
       if (indexPath.row == 0) {
        MHMDetailInfoController *vc = [[MHMDetailInfoController alloc] initWithListModels:self.listModels];
       
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    Class class = self.jumpControllers[indexPath.row];
    MHMBaseViewController *vc = [[class alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - getter
- (UITableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(4, self.view.height-220, self.view.width-8, 132) style:UITableViewStylePlain];
          // NSLog(@"_lineChartView---------=%f",_lineChartView.height);
       //    NSLog(@"_tableView=%@",_tableView.tableFooterView);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 44;
        _tableView.backgroundColor = [UIColor yellowColor];
       
    }
    return _tableView;
}

//  设置、年、月、日
- (UISegmentedControl *)dateSegmentControl {
    if (!_dateSegmentControl) {
        NSArray *items = @[ @"Day", @"Week", @"Month", @"Year" ];
        //  [_dateSegmentControl setWidth:15.0 forSegmentAtIndex:0];
        _dateSegmentControl = [[UISegmentedControl alloc] initWithItems:items];
        _dateSegmentControl.selectedSegmentIndex = 0;
        _dateSegmentControl.frame = CGRectMake(0, 0, ScreenWidth - 8, 35);
        _dateSegmentControl.layer.cornerRadius = 10;//  加圆角
        _dateSegmentControl.tintColor = RGB(255, 45, 85);
        
        //   _dateSegmentControl.backgroundColor = [UIColor blueColor];
        //设置字体大小
        
        UIFont *font = [UIFont boldSystemFontOfSize:16.0f];
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                               forKey:NSFontAttributeName];
        [_dateSegmentControl setTitleTextAttributes:attributes
                                           forState:UIControlStateNormal];
    }
    return _dateSegmentControl;
}

//  设置图表view的大小
- (MHMLineChartView *)lineChartView {
    if (!_lineChartView) {
       // _lineChartView.backgroundColor = [UIColor redColor];
        _lineChartView = [[MHMLineChartView alloc] initWithFrame:CGRectMake(4, topViewHeight, self.view.width - 8, self.view.height-285)];
        
       // // nslog(@"_lineChartView=%f",_lineChartView.height);
    }
    return _lineChartView;
}

- (MHMHealthManager *)healthManager {
    
    if (!_healthManager) {
        
        _healthManager = [[MHMHealthManager alloc] init];
        
    }
    return _healthManager;
}

- (NSArray *)titles {
    
    return @[@"Show All Data", @"Data Sources",@"Unit"];
}

- (NSArray *)jumpControllers {
    
    return @[ [MHMDetailInfoController class], [MHMInfoSourceController class] ];
    
}

@end
