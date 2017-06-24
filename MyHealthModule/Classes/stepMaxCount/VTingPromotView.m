//
//  VTingPromotView.m
//  VTingPopView
//
//  Created by WillyZhao on 16/8/31.
//  Copyright © 2016年 WillyZhao. All rights reserved.
//

#import "VTingPromotView.h"

#import "ZXPAutoLayout.h"


@interface VTingTextfField : UITextField

@end

@implementation VTingTextfField

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUpUI];
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self setUpUI];
}

-(void)setUpUI {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 5.0f;
    
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 1;
    
    self.font = [UIFont systemFontOfSize:14];
    
    NSString *holderText = @"1<……<1000000";
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:holderText];
    [placeholder addAttribute:NSForegroundColorAttributeName
                       value:[UIColor lightGrayColor]
                       range:NSMakeRange(0, holderText.length)];
    [placeholder addAttribute:NSFontAttributeName
                       value:[UIFont boldSystemFontOfSize:13]
                       range:NSMakeRange(0, holderText.length)];
    self.attributedPlaceholder = placeholder;

}

//控制placeHolder的位置
-(CGRect)placeholderRectForBounds:(CGRect)bounds {
    CGRect inset = CGRectMake(bounds.origin.x+10, bounds.origin.y, bounds.size.width -10, bounds.size.height);//更好理解些
    return inset;
}

//控制显示文本的位置
-(CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectMake(bounds.origin.x+10, bounds.origin.y, bounds.size.width -10, bounds.size.height);
    return inset;
}

//控制编辑文本的位置
-(CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectMake(bounds.origin.x +10, bounds.origin.y, bounds.size.width -10, bounds.size.height);
    return inset;
}

@end

@interface VTingPromotView () <UITextFieldDelegate> {
    UIButton *sureBtn;          //确认按钮
    UIButton *closeBtn;         //取消按钮
    VTingTextfField *nameInput;     //名称输入框
    
    UIView *backgroundView;     //背景view
    UIView *centerView;         //内容view
    
    UITapGestureRecognizer *tap;        //点击事件
}

@property (nonatomic, assign) VTingPopViewStyle style;

@end



@implementation VTingPromotView

-(instancetype)initWithFrame:(CGRect)frame andStyle:(VTingPopViewStyle)style {
    if (self = [super initWithFrame:frame]) {
        self.style = style;
        [self loadSubViews];        //初始化视图
        //添加键盘显示与消失通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillDismiss:) name:UIKeyboardWillHideNotification object:nil];
    }
    
    return self;
    
}


-(void)keyBoardWillDismiss:(NSNotification *)na {
    [UIView animateWithDuration:.2f animations:^{
        [centerView zxp_updateConstraints:^(ZXPAutoLayoutMaker *layout) {
            layout.widthValue(([UIScreen mainScreen].bounds.size.width - 70));
            layout.heightValue((175 * ([UIScreen mainScreen].bounds.size.width - 70))/250);
            layout.xCenterByView(self,0);
            layout.yCenterByView(self,0);
        }];
    }];
}


-(void)keyBoardWillAppear:(NSNotification *)na {

    [UIView animateWithDuration:.2f animations:^{
        [centerView zxp_updateConstraints:^(ZXPAutoLayoutMaker *layout) {
            layout.widthValue(([UIScreen mainScreen].bounds.size.width - 70));
            layout.heightValue((175 * ([UIScreen mainScreen].bounds.size.width - 70))/250);
            layout.xCenterByView(self,0);
            layout.yCenterByView(self,-100);
        }];
    }];
}

-(void)loadSubViews {
    if (self.style == VTingPromotCheck) {
        
        
        
        //有输入框初始化
        //背景
        backgroundView = [[UIView alloc] initWithFrame:self.frame];
        backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [self addSubview:backgroundView];
        [backgroundView zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
            layout.edgeInsets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        //内容view
        centerView = [UIView new];
        centerView.layer.masksToBounds = YES;
        centerView.layer.cornerRadius = 5.0f;
        centerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:centerView];
        [centerView zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
            layout.widthValue(([UIScreen mainScreen].bounds.size.width - 70));
            layout.heightValue((175 * ([UIScreen mainScreen].bounds.size.width - 70))/250);
            layout.xCenterByView(self,0);
            layout.yCenterByView(self,0);
        }];
    }
    
    
    //上分割线
    UIView *lineView = [UIView new];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [centerView addSubview:lineView];
    [lineView zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.topSpace((((175 * ([UIScreen mainScreen].bounds.size.width - 70))/250) * 50)/175);
        layout.heightValue(1);
        layout.leftSpace(0);
        layout.rightSpace(0);
    }];
    
    //添加新建分组容器
    UIView *topView = [UIView new];
    topView.backgroundColor = [UIColor whiteColor];
    [centerView addSubview:topView];
    [topView zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.leftSpace(0);
        layout.rightSpace(0);
        layout.topSpace(0);
        layout.heightValue((((175 * ([UIScreen mainScreen].bounds.size.width - 70))/250) * 50)/175);
    }];
    
    //新建分组
    UILabel *label = [UILabel new];
    label.text = @"Custom steps";
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:26 weight:.5f];
    [topView addSubview:label];
    [label zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.xCenterByView(topView,0);
        layout.yCenterByView(topView,0);
    }];
    
    //添加下分割线
    UIView *downLineView = [UIView new];
    downLineView.backgroundColor = [UIColor lightGrayColor];
    [centerView addSubview:downLineView];
    [downLineView zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.heightValue(1);
        layout.leftSpace(0);
        layout.rightSpace(0);
        layout.bottomSpace(35);
    }];
    
    //添加按钮容器
    UIView *downView = [UIView new];
    downView.backgroundColor = [UIColor whiteColor];
    [centerView addSubview:downView];
    [downView zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.bottomSpace(0);
        layout.leftSpace(0);
        layout.rightSpace(0);
        layout.topSpaceByView(downLineView,0);
    }];

    //添加分割线
    UIView *view_c = [UIView new];
    view_c.backgroundColor = [UIColor lightGrayColor];
    [downView addSubview:view_c];
    [view_c zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.widthValue(1);
        layout.topSpace(0);
        layout.bottomSpace(0);
        layout.xCenterByView(downView,0);
    }];
    
    //确认按钮
    sureBtn = [UIButton new];
    [downView addSubview:sureBtn];
    [sureBtn setTitle:@"OK" forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    sureBtn.titleLabel.font = [UIFont systemFontOfSize:23];
    [sureBtn addTarget:self action:@selector(sureBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.topSpace(0);
        layout.rightSpace(0);
        layout.bottomSpace(0);
        layout.leftSpaceByView(view_c,0);
    }];
    
    //取消按钮
    closeBtn = [UIButton new];
    [downView addSubview:closeBtn];
    [closeBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:23];
    [closeBtn addTarget:self action:@selector(cloeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.leftSpace(0);
        layout.topSpace(0);
        layout.bottomSpace(0);
        layout.rightSpaceByView(view_c,0);
    }];
    
    //输入框容器
    UIView *middleView = [UIView new];
    middleView.backgroundColor = [UIColor whiteColor];
    [centerView addSubview:middleView];
    [middleView zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.leftSpace(0);
        layout.rightSpace(0);
        layout.topSpaceByView(lineView,0);
        layout.bottomSpaceByView(downLineView,0);
    }];
    
    //输入框
    nameInput = [VTingTextfField new];
    nameInput.delegate = self;
    
    [middleView addSubview:nameInput];
    [nameInput zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.xCenterByView(middleView,0);
        layout.yCenterByView(middleView,0);
        layout.widthValue((([UIScreen mainScreen].bounds.size.width - 70) - 50));
        layout.heightValue(((([UIScreen mainScreen].bounds.size.width - 70) - 50)*40)/210);
    }];
}

-(void)showPopViewAnimate:(BOOL)animate{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (animate == YES) {
        [window addSubview:self];
        //动画效果
        centerView.transform = CGAffineTransformMakeScale(1.3, 1.3);
        centerView.alpha = 0;
        [UIView animateWithDuration:.35 animations:^{
            centerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            centerView.alpha = 1;
        }];
    }else{
        [window addSubview:self];
    }
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (![touch.view isEqual:centerView]) {
        [self dismissPopViewAnimate:YES];
    }
}

-(void)tapAction:(UITapGestureRecognizer *)tap {
    [self dismissPopViewAnimate:YES];
}

-(void)dismissPopViewAnimate:(BOOL)animate {
    [self endEditing:YES];
    if (animate) {
        [UIView animateWithDuration:.35 animations:^{
            centerView.transform = CGAffineTransformMakeScale(1.3, 1.3);
            centerView.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                [self removeFromSuperview];
            }
        }];
    }else{
        centerView.alpha = 0;
        [centerView removeFromSuperview];
    }
}

-(void)cloeBtnAction:(UIButton *)btn {
    [self dismissPopViewAnimate:YES];
}

-(BOOL)sureBtnAction:(UIButton *)btn {
    [self dismissPopViewAnimate:YES];
    if (self.block) {
        if (nameInput.text.length!= 0) {
            
                if (nameInput.text.length >=7) {
                    nameInput.text = [nameInput.text substringToIndex:6];
           
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Input error" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                  
                    self.block(nameInput.text);
                   
                    return YES;
                }else{
                    self.block(nameInput.text);
                }
        }else{
              [self chargeNameInputText:@"Please set the correct number of steps"];
          //  self.block(@"输入为空");
        }
    }
    return YES;
}

-(void)chargeNameInputText:(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:@"cancel"
                                             otherButtonTitles:@"OK", nil];
    //显示alertView
    [alertView show];
    

}

#pragma mark UITextField delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"开始输入");

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
