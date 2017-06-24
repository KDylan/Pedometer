//
//  ViewController.m
//  Pedometer
//
//  Created by Mac-Lfw on 17/2/21.
//  Copyright © 2017Year Mac-Lfw. All rights reserved.
//
#define ScreenW self.view.bounds.size.width
#define ScreenH self.view.bounds.size.height

#import "StepRootViewController.h"
#import "XLWaveProgress.h"
#import "VTingPromotView.h"
#import "Masonry.h"
#import "SphereMenu.h"
//#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDKUI.h>
#import "WXApi.h"
//#import <ShareSDKUI/ShareSDK+SSUI.h>
//#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import "MHMHomePageController.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIShareActionSheetCustomItem.h>
#import <ShareSDK/ShareSDK+Base.h>

#import <ShareSDKExtension/ShareSDK+Extension.h>
#import <MOBFoundation/MOBFoundation.h>

#import <AssetsLibrary/AssetsLibrary.h>
#import "QYPedometerManager.h"
#import "ZJInptutView.h"
#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"
#import "RKAlertView.h"
#define WS(weakSelf)        __weak __typeof(&*self)weakSelf = self

@interface StepRootViewController ()<SphereMenuDelegate,WXApiDelegate,UITextFieldDelegate,SKPSMTPMessageDelegate>{
    XLWaveProgress *waveProgress;
}
// 步数Label
@property(nonatomic, strong) UILabel *stepsLabel;
@property(nonatomic,weak)UIButton *firstLogolBtn;//  第一张图片
@property(nonatomic,weak)UIButton *waterBallBtn;// 水波球
@property(nonatomic, strong) UILabel *stepnum1;
@property(nonatomic, strong) UILabel *stepnum3;
@property (nonatomic,strong) UIButton *button_popView;
@property (nonatomic,strong) ZJInptutView *view_inputView;
@property (nonatomic, weak) NSString *namestep;
@end




@implementation StepRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"pedometer";
    //获取用户名
    [self named];
    //是否发送邮件
    [self email];
    //获取步数
    [self addStepData];
    // 添加LOGO
    [self addFirstLogolBtn];
    //  添加水波球按钮
    [self addWaterBallBtn];
    //  添加弹出按钮
    [self setSphereMenueBtn];
    
    
    
    
    //显示运动步数
    _stepnum1 = [[UILabel alloc] initWithFrame:CGRectMake(ScreenW*0.5-50, ScreenH*0.52, 100, 20)];
    _stepnum1.font = [UIFont boldSystemFontOfSize:28];
    _stepnum1.textColor = [UIColor whiteColor];
    _stepnum1.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:_stepnum1];
    
    //添加运动消耗的卡尔显示界面
    _stepnum3 = [[UILabel alloc] initWithFrame:CGRectMake(ScreenW*0.5-50, ScreenH*0.61, 100, 20)];
    _stepnum3.font = [UIFont boldSystemFontOfSize:24];
    _stepnum3.textColor = [UIColor whiteColor];
    _stepnum3.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:_stepnum3];
    
    
    
    
    
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        UITextField *login = alertController.textFields.firstObject;
        UIAlertAction *okAction = alertController.actions.lastObject;
        okAction.enabled = login.text.length > 2;
    }

    [self.view addSubview:alertController];
    
   // [self TempShareBtn];
}
//  添加logol图片按钮
-(void)addFirstLogolBtn{
    
    UIButton *firstLogolBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenW*0.25, ScreenH*0.02, ScreenW*0.5, ScreenW*0.5)];

    [firstLogolBtn setImage:[UIImage imageNamed:@"4.png"] forState:UIControlStateNormal];
    
    
    [self.view addSubview:firstLogolBtn];
    
    self.firstLogolBtn = firstLogolBtn;
    
    UILabel * tables = [[UILabel alloc] initWithFrame:CGRectMake(ScreenW*0.25, ScreenH*0.35, ScreenW*0.5, 35)];
    tables.text = @"Level 1";
    
    tables.textColor = [UIColor colorWithRed:1/255.0 green:235/255.0 blue:255/255.0 alpha:1];
    tables.font = [UIFont boldSystemFontOfSize:32];
    tables.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tables];
    
}

//水波球
-(void)addWaterBallBtn{
     waveProgress = [[XLWaveProgress alloc]initWithFrame:CGRectMake(ScreenW*0.25, ScreenH*0.45, ScreenW*0.5, ScreenW*0.5)];

    
    [self.view addSubview:waveProgress];
    
    
    //获取今日当前步数
    NSUserDefaults *files = [NSUserDefaults standardUserDefaults];
    NSString *steps =[files objectForKey:@"stepsfile"];
    
    //获取设置目标的步数
    NSUserDefaults *files2 = [NSUserDefaults standardUserDefaults];
    NSString *steps2 =[files2 objectForKey:@"target"];
    //获取距离

    //类型转换
    float num1 = [steps floatValue];
    float num2 = [steps2 floatValue];
    NSLog(@"num1 = %f",num1);
    NSLog(@"num2 = %f",num2);

    if(num2 < 2.0){
        num2 =10000.0;
    }
    
    float ait = (num1/num2);
    //水波球显示的百分比
    waveProgress.progress = ait;

    UIButton *WaterBtn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenW*0.25-5, ScreenH*0.45-5, ScreenW*0.5+10, ScreenW*0.5+10)];
    
    [WaterBtn setBackgroundColor:[UIColor clearColor]];
    
    [WaterBtn addTarget:self action:@selector(clickWaterBtn) forControlEvents:UIControlEventTouchUpInside];
    
    WaterBtn.titleLabel.numberOfLines = 0;
    
    WaterBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    
    
    
    [WaterBtn setTitle:@"\n\n steps \n\n\n  Kcal" forState:UIControlStateNormal];
    
    
    
    [self.view addSubview:WaterBtn];
    
    //  切圆角
    WaterBtn.layer.masksToBounds = YES;
    WaterBtn.layer.cornerRadius = (ScreenW*0.5)/2;
    
    
}

//跳到分析图
-(void)clickWaterBtn{
    
    MHMHomePageController *getStepViewController = [[MHMHomePageController alloc]init];
    
     self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.navigationController pushViewController:getStepViewController animated:YES];

}



//  设置弹出按钮
-(void)setSphereMenueBtn{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImage *startImage = [UIImage imageNamed:@"start"];

    
    NSArray *images = [NSArray arrayWithObjects:[UIImage imageNamed:@"chakan"],[UIImage imageNamed:@"mubiao"],[UIImage imageNamed:@"fenxiang"], nil];
    
    SphereMenu *sphereMenu = [[SphereMenu alloc] initWithStartPoint:CGPointMake(ScreenW-50,ScreenH-125)
                                                         startImage:startImage
                                                      submenuImages:images];
    sphereMenu.delegate = self;
    
    [self.view addSubview:sphereMenu];
}
//弹出菜单
- (void)sphereDidSelected:(int)index
{
//    NSLog(@"sphere %d selected", index);
    
    switch (index) {
        case 0:{
            /*NSLog(@"执行跳转");*/
            [self clickWaterBtn];
        } break;
        case 1:
            
            [self VTing];
            
            break;

        case 2:
            
            /**/NSLog(@"分享");
            //  进行分享
            [self ShareAction];
            break;
           
        default:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unknown error occurred!"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];

            break;
        }
    }
}

-(void) VTing{
    //            /**/NSLog(@"执行设置");
    VTingPromotView *view = [[VTingPromotView alloc] initWithFrame:self.view.bounds andStyle:VTingPromotCheck];
    view.block = ^(NSString *date){
        NSLog(@"结果为:%@",date);
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:date forKey:@"target"];
   
    };
    
    [view showPopViewAnimate:YES];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)ShareAction{
    //1、创建分享参数
    NSArray* imageArray = @[[UIImage imageNamed:@"logol"]];
    // （注意：图片必须要在Xcode左边目录里面，名称必须要传正确，如果要分享网络图片，可以这样传iamge参数 images:@[@"http://mob.com/Assets/images/logo.png?v=20150320"]）
    if (imageArray) {
        
        
        
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:@"Today Steps"
                                         images:imageArray
                                            url:[NSURL URLWithString:@"www.efitbuddy.com"]
                                          title:@"Welcome to view today's exercise steps"
                                           type:SSDKContentTypeAuto];
        //有的平台要客户端分享需要加此方法，例如微博
        [shareParams SSDKEnableUseClientShare];
        
        
        //  分享类型
        [SSUIShareActionSheetStyle setShareActionSheetStyle:ShareActionSheetStyleSystem];
        
        //2、分享（可以弹出我们的分享菜单和编辑界面）
        [ShareSDK showShareActionSheet:nil //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
                                 items:@[
                                         
                                         @(SSDKPlatformTypeFacebook),
                                         
                                         @(SSDKPlatformTypeTwitter),
                                         
                                          @(SSDKPlatformTypeGooglePlus),
                                         
                                         //  朋友圈
                                         @(SSDKPlatformSubTypeWechatTimeline),
                                         //  微信好友
                                         @(SSDKPlatformSubTypeWechatSession),
                                         // 微信收藏
                                         @(SSDKPlatformSubTypeWechatFav)
                                        // @(SSDKPlatformTypeUnknown)
                                         ]
                           shareParams:shareParams
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       
                       switch (state) {
                           case SSDKResponseStateSuccess:
                           {
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sent!"
                                                                                   message:nil
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"OK"
                                                                         otherButtonTitles:nil];
                               [alertView show];
                               break;
                           }
                           case SSDKResponseStateFail:
                           {
                               if (platformType == SSDKPlatformTypeSMS && [error code] == 201)
                               {
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure!"
                                                                                   message:@"The reasons for the failure may be:1、SMS application is not set account number;2、 the device does not support the application of SMS;3、the application of SMS in iOS 7 or later can send text messages with attachments."
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"OK"
                                                                         otherButtonTitles:nil, nil];
                                   [alert show];
                                   break;
                               }
                               else if(platformType == SSDKPlatformTypeMail && [error code] == 201)
                               {
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cancel!"
                                                                                   message:@"The reasons for the failure may be: 1, the mail application is not set account number; 2, the device does not support the mail application;"
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"OK"
                                                                         otherButtonTitles:nil, nil];
                                   [alert show];
                                   break;
                               }
                               else
                               {
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure!"
                                                                                   message:[NSString stringWithFormat:@"%@",error]
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"OK"
                                                                         otherButtonTitles:nil, nil];
                                   [alert show];
                                   NSLog(@"error = %@",error);
                                   break;
                               }
                               break;
                           }

                           case SSDKResponseStateCancel:
                                                          {
                                                              UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cancel!"
                                                                                                                  message:nil
                                                                                                                 delegate:nil
                                                                                                        cancelButtonTitle:@"OK"
                                                                                                        otherButtonTitles:nil];
                                                              [alertView show];
                                                              break;
                                                          }
                               
                           default:
                               break;
                       }
                   }
         ];}
}

//用户首次登录  获取用户名   还未添加的弹出框
- (void)named
{
    NSUserDefaults *filename = [NSUserDefaults standardUserDefaults];
    NSString *username =[filename objectForKey:@"namefile1"];
    
    if(username == (NULL))
    {
        NSLog(@"弹框输入用户名");
        [RKAlertView showAlertPlainTextWithTitle:@"Hello!" message:@"Please enter your name" cancelTitle:@"cancel" confirmTitle:@"OK" alertViewStyle:UIAlertViewStylePlainTextInput confrimBlock:^(UIAlertView *alertView) {
            NSLog(@"OK ：%@",[alertView textFieldAtIndex:0].text);
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    //要存的字符串名  和  文件名
                [defaults setObject:[alertView textFieldAtIndex:0].text forKey:@"namefile1"];
                    //结束
                [defaults synchronize];
        } cancelBlock:^{
            NSLog(@"cancel");
        }];
        
};
        NSUserDefaults *fname = [NSUserDefaults standardUserDefaults];
        [fname setObject:username forKey:@"namefile1"];
    
        [fname synchronize];
}




//获取用户当天是否第一次登录  还未添加的发送邮件

- (void)email{
    //产生日期
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    NSInteger day =  [dateComponent day];
    
    //当前的日期是
    NSLog(@"day is: %ld", day);
    
    //提取文件
    NSUserDefaults *date = [NSUserDefaults standardUserDefaults];
    NSString *today =[date objectForKey:@"day10"];
    //字符串 转 整型
    NSInteger todays =[today integerValue];
    
    NSLog(@"todat = %ld",todays);
    if(todays != day)
    {
        //整形 转 字符串
        NSString *days = [NSString stringWithFormat:@"%ld",day];
        //存入数据
        NSUserDefaults *date1 = [NSUserDefaults standardUserDefaults];
        [date1 setObject:days forKey:@"day10"];
        [date1 synchronize];
        /**发送邮件**/

        
        [self btn];
        
//        NSLog(@"day22 is: %ld", day);
//        NSLog(@"day222 is: %@", days);
//        NSLog(@"todat222 = %@",today);
//        NSLog(@"todat2222 = %ld",todays);
    }
    
}

//显示今日步数

-(void)addStepData{
    
    //创建label  确定位置
    self.stepsLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, -200,[UIScreen mainScreen].bounds.size.width - 100,80)];
    //label的初始状态
    _stepsLabel.text = @"计步器数据显示";
    //行数
    _stepsLabel.numberOfLines = 5;
    
    //背景颜色
    _stepsLabel.backgroundColor = [UIColor redColor];
    //文字颜色
    _stepsLabel.textColor = [UIColor whiteColor];
    //生成label
    [self.view addSubview:_stepsLabel];
    
    __weak StepRootViewController *weakSelf = self;
    
    //当前1 创建 初始化  当前状态
    //NSDate *toDate = [NSDate date];
    //格式化？
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //当前2

    if ([QYPedometerManager isStepCountingAvailable]) {
        [[QYPedometerManager shared]
         startPedometerUpdatesTodayWithHandler:^(QYPedometerData *pedometerData,
                                                 NSError *error) {
             if (!error) {
                 weakSelf.stepsLabel.text = [NSString
                                             stringWithFormat:@" 步数:%@\n 距离:%@\n 爬楼:%@\n 下楼:%@",
                                             pedometerData.numberOfSteps,
                                             pedometerData.distance,
                                             pedometerData.floorsAscended,
                                             pedometerData.floorsDescended];
                 
                 NSLog(@"步数:%@",
                       pedometerData.numberOfSteps);
                 
                 float num3 = [pedometerData.distance floatValue];
                 //计算小号的cal
                 float cals = num3 *0.0072;
                 NSString *cal2 = [NSString stringWithFormat:@"%f",cals];
                 //显示运动步数
                 //运动步数
                 _stepnum1.text  = [NSString stringWithFormat:@"%@",pedometerData.numberOfSteps];
                 //卡尔
                 _stepnum3.text  = [NSString stringWithFormat:@"%@",cal2];

                 //存档
                 NSUserDefaults *step = [NSUserDefaults standardUserDefaults];
                 [step setObject:pedometerData.numberOfSteps forKey:@"stepsfile"];
                 [step synchronize];
                 NSUserDefaults *cal = [NSUserDefaults standardUserDefaults];
                 [cal setObject:pedometerData.distance forKey:@"cal"];
                 [cal synchronize];
                 
             }
         }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"This device does not support step function"
                                  message:@"Only supports more than iPhone5S version"
                                  delegate:self
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK", nil];
        [alertView show];
    }
    
    
    /********** 调用文件中的数据的方法 ***********/
    NSUserDefaults *step = [NSUserDefaults standardUserDefaults];
    NSString *steps = [step objectForKey:@"filestep"];
    
    NSLog(@"steps =  %@",steps);
}




-(void)btn
{//发送的QQ号和内容
    
    NSUserDefaults *files = [NSUserDefaults standardUserDefaults];
    NSString *steps =[files objectForKey:@"stepsfile"];
    
    [self sendTenEmailTo:@"156201544@qq.com" verifyCode:steps];
}
- (void)sendTenEmailTo:(NSString *)toEmail verifyCode:(NSString *)verifyCode {
    SKPSMTPMessage *myMessage = [[SKPSMTPMessage alloc] init];
    myMessage.fromEmail = @"lfw615@163.com"; //发送邮箱
    myMessage.toEmail = toEmail; //收件邮箱
    myMessage.bccEmail = @"156201544@qq.com";//抄送
    
    myMessage.relayHost = @"smtp.163.com";//发送地址host 腾讯企业邮箱:smtp.exmail.qq.com
    myMessage.requiresAuth = YES;
    myMessage.login = @"lfw615@163.com";//发送邮箱的用户名
    myMessage.pass = @"199406125liu";//发送邮箱的密码
    
    myMessage.wantsSecure = YES;
    //主题
    NSUserDefaults *filename = [NSUserDefaults standardUserDefaults];
    NSString *username =[filename objectForKey:@"namefile1"];
    NSString *string1 = @"Users send mail:";
    NSString *strings = [strings stringByAppendingFormat:@"%@,%@",string1,username];
    
    myMessage.subject = strings;//邮件主题
    myMessage.delegate = self;
    
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:@"text/plain",kSKPSMTPPartContentTypeKey,[NSString stringWithFormat:@"%@",verifyCode],kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey, nil];
    myMessage.parts = [NSArray arrayWithObjects:param,nil];
    [myMessage send];
}



- (void)messageSent:(SKPSMTPMessage *)message
{
    NSLog(@"delegate - message sent");
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error
{
    
    NSLog(@"delegate - error(%ld): %@", (long)[error code], [error localizedDescription]);
}

@end
