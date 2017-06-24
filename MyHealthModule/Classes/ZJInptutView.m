//
//  ZJInptutView.m
//  InputContentDemo
//
//  Created by 铅笔 on 2016/10/8.
//  Copyright © 2016年 铅笔. All rights reserved.
//

#import "ZJInptutView.h"

@interface ZJInptutView ()
@property (nonatomic,strong) UIView *view_cover;//遮罩层

@property (nonatomic,strong) UIView *view_showInputView;//展示输入内容的背景

@property (nonatomic,strong) UITextField *textField_input;
@end

@implementation ZJInptutView

- (id) initWithFrame:(CGRect)frame andTitle:(NSString *)title andPlaceHolderTitle:(NSString *)placeContent
{
    if (self = [super initWithFrame:frame]) {
//        self.backgroundColor = [UIColor greenColor];
        [self initWithAllSubviews:title andPlaceTitle:placeContent];
    }
    return self;
}

- (void) initWithAllSubviews:(NSString *)title andPlaceTitle:(NSString *)placeContent
{
    //遮罩层
    self.view_cover = [[UIView alloc] initWithFrame:self.frame];
    [self addSubview:self.view_cover];
    self.view_cover.backgroundColor = [UIColor blackColor];
    self.view_cover.alpha = 0.65;
    
    //手势移除
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissViewAction)];
    [self.view_cover addGestureRecognizer:gesture];
    
    //展示输入内容
    self.view_showInputView = [[UIView alloc] initWithFrame:CGRectMake(30, 130, self.frame.size.width-30*2, 140)];
    [self addSubview:self.view_showInputView];
    self.view_showInputView.backgroundColor = [UIColor whiteColor];
    self.view_showInputView.layer.cornerRadius = 10.0;
    self.view_showInputView.clipsToBounds = YES;
    
    //标题
    UILabel *lable_title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view_showInputView.frame.size.width, 25)];
    [self.view_showInputView addSubview:lable_title];
    lable_title.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    lable_title.text = title;
    lable_title.textColor = [UIColor blackColor];
    lable_title.font = [UIFont systemFontOfSize:14];
    lable_title.textAlignment = NSTextAlignmentCenter;
    
    //输入内容的框
    self.textField_input = [[UITextField alloc] initWithFrame:CGRectMake(10, 40, self.view_showInputView.frame.size.width-20, 30)];
    [self.view_showInputView addSubview:self.textField_input];
    self.textField_input.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    self.textField_input.layer.cornerRadius = 10.0;
    self.textField_input.clipsToBounds = YES;
    //设置距离输入框左侧间距
    self.textField_input.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
    self.textField_input.leftViewMode = UITextFieldViewModeAlways;
    self.textField_input.placeholder = placeContent;
    self.textField_input.font = [UIFont systemFontOfSize:14];
    
    //button
    UIButton *button_sure = [[UIButton alloc] initWithFrame:CGRectMake(10, 90, self.view_showInputView.frame.size.width-20, 30)];
    [self.view_showInputView addSubview:button_sure];
    button_sure.backgroundColor = [UIColor purpleColor];
    button_sure.layer.cornerRadius = 10.0;
    button_sure.clipsToBounds = YES;
    [button_sure setTitle:@"确 定" forState:0];
    [button_sure.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [button_sure addTarget:self action:@selector(dismissViewAction) forControlEvents:UIControlEventTouchUpInside];
}

//移除视图
- (void) dismissViewAction
{
    if (self.removeView) {
        self.removeView(self.textField_input.text);
    }
}

@end
