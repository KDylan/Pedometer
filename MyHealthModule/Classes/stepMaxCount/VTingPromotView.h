//
//  VTingPromotView.h
//  VTingPopView
//
//  Created by WillyZhao on 16/8/31.
//  Copyright © 2016年 WillyZhao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    VTingPromotSetting,     //无输入框
    VTingPromotCheck        //有输入框
}VTingPopViewStyle;

typedef void(^Success)(NSString *pwd);  //点击确认后密码返回

@interface VTingPromotView : UIView

@property (nonatomic, assign) Success block;

//重写初始化方法
-(instancetype)initWithFrame:(CGRect)frame andStyle:(VTingPopViewStyle)style;

//弹出密码提示框
-(void)showPopViewAnimate:(BOOL)animate;

//消失密码提示框
-(void)dismissPopViewAnimate:(BOOL)animate;

@end
