//
//  AppDelegate.m
//  MyHealthModule
//
//  Created by ChenWeidong on 16/2/26.
//  Copyright © 2016年. All rights reserved.
//

#import "AppDelegate.h"

#import "UIImage+Color.h"
#import "UtilsMacro.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
// 微信
#import "WXApi.h"

#import "StepRootViewController.h"
//Facebook Messenger SDK
#import <FBSDKMessengerShareKit/FBSDKMessengerSharer.h>

@interface AppDelegate ()<WXApiDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    StepRootViewController *vc = [[StepRootViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithSolidColor:[UIColor whiteColor] size:CGSizeMake(10, 10)]
                                       forBarMetrics:UIBarMetricsDefault];
    [UINavigationBar appearance].titleTextAttributes = @{
                                                         NSForegroundColorAttributeName: [UIColor blackColor],
                                                         NSFontAttributeName: [UIFont boldSystemFontOfSize:18],
                                                         };
    //  分享
    [ShareSDK registerApp:@"177dc9318e8dc"
     
          activePlatforms:@[
                            //@(SSDKPlatformTypeUnknown),
                            //@(SSDKPlatformTypeMail),
                            //@(SSDKPlatformTypeSMS),
                            //@(SSDKPlatformTypeCopy),
                            @(SSDKPlatformTypeWechat),//  微信
                            //@(SSDKPlatformTypeQQ),
                            //@(SSDKPlatformTypeRenren),
                            @(SSDKPlatformTypeFacebook),//  Facebook
                            @(SSDKPlatformTypeGooglePlus),//  G+
                            @(SSDKPlatformTypeTwitter),//  Twitter
                            @(SSDKPlatformTypeFacebookMessenger),
                            @(SSDKPlatformSubTypeWechatFav)
                            
                            ]
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             case SSDKPlatformTypeFacebook:
                 [ShareSDKConnector connectFacebookMessenger:[FBSDKMessengerSharer class]];
                 break;

               
//             case SSDKPlatformTypeGooglePlus:
//                  [ShareSDKConnector connectGooglePlus: [GPPSignIn class] shareClass:[GPPShare class]];
//                 break;
//             case SSDKPlatformTypeTwitter:
//                 [ShareSDKConnector connect:[RennClient class]];
//                 break;
                 
             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         
         switch (platformType)
         {
            case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:@"wx58b91efa78f544a3"
                                       appSecret:@"1d78e366367ae572491a54fc51315cb5"];
                 break;
                 
             case SSDKPlatformTypeFacebook:
         //       设置Facebook应用信息，其中authType设置为只用SSO形式授权
                 [appInfo SSDKSetupFacebookByApiKey:@"686760001531169"
                                          appSecret:@"35f954861b0943d608e912b50d147e3d"
                                     //   displayName:@"efitbuddy"
                                           authType:SSDKAuthTypeBoth];
                 
                 [appInfo SSDKSetAuthSettings:@[@"public_profile"]];
                break;
//             case SSDKPlatformTypeFacebook:
//                 //设置Facebook应用信息，其中authType设置为只用SSO形式授权
//                 [appInfo SSDKSetupFacebookByApiKey:@"107704292745179"
//                                          appSecret:@"38053202e1a5fe26c80c753071f0b573"
//                                           authType:SSDKAuthTypeBoth];
//                 break;

             case SSDKPlatformTypeTwitter:
                 [appInfo SSDKSetupTwitterByConsumerKey:@"1F5KcpPSD8O1vaaPpZD5sSMHV"
                                         consumerSecret:@"P6BKhBhS6AyTADfpYbJQG7jBj9IoDVB7nOKnTkudqPdai306ns"
                                            redirectUri:@"https://dev.twitter.com"];
                 break;
             case SSDKPlatformTypeGooglePlus:
                 
                 [appInfo SSDKSetupGooglePlusByClientID:@"20260438717-jk4pd0si8ghbscm6t1fekk306r0hlqea.apps.googleusercontent.com"
                                           clientSecret:@"PEdFgtrMw97aCvf0joQj7EMk"
                                            redirectUri:@"http://localhost"];
                 break;

             default:
                 break;
         }
     }];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url

{
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [WXApi handleOpenURL:url delegate:self];
}
//- (void)onResp:(BaseResp *)resp
//{
//    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
//        switch (resp.errCode) {
//            case WXSuccess: { // 成功
//                NSLog(@"发送成功");
//                break;
//            }
//            case WXErrCodeCommon: { // 普通错误类型
//                NSLog(@"网络有问题");
//                break;
//            }
//            case WXErrCodeUserCancel: { // 用户取消发送
//                NSLog(@"取消发送");
//                break;
//            }
//            case WXErrCodeSentFail: { // 发送失败
//                NSLog(@"发送失败");
//                break;
//            }
//            case WXErrCodeAuthDeny: { // 授权失败
//                NSLog(@"授权失败");
//                break;
//            }
//            case WXErrCodeUnsupport: { // 微信版本不支持
//                NSLog(@"版本不支持");
//                break;
//            }
//            default:
//                break;
//        }
//    }
//}
//
- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

@end
