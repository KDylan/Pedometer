//
//  RKAlertView.m
//  RKAlertView
//
//  Created by Roki Liu on 16/3/10.
//  Copyright © 2016年 Snail. All rights reserved.
//

#import "RKAlertView.h"

@interface RKAlertView ()

@property (nonatomic, copy) CancelBlock cancelBlock;
@property (nonatomic, copy) ConfirmBlock confirmBlock;

@end

@implementation RKAlertView

//初始化AlertView
-(id)initWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle  confirmTitle:(NSString *)confirmTitle confrimBlock:(ConfirmBlock)confirm cancelBlock:(CancelBlock)cancel {
    
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:confirmTitle, nil];
    if (self) {
        _cancelBlock = [cancel copy];
        _confirmBlock = [confirm copy];
    }
    return self;
}

//UIAlertViewStyleDefault样式
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)msg cancelTitle:(NSString *)cancelTitle confirmTitle:(NSString *)confirmTitle confrimBlock:(ConfirmBlock)confirm cancelBlock:(CancelBlock)cancel {
    
    RKAlertView *alert = [[RKAlertView alloc] initWithTitle:title message:msg cancelTitle:cancelTitle confirmTitle:confirmTitle  confrimBlock:confirm cancelBlock:cancel];
    [alert show];
}

//没有取消按钮的UIAlertViewStyle样式
+ (void)showNoCancelBtnAlertWithTitle:(NSString *)title message:(NSString *)msg confirmTitle:(NSString *)confirmTitle confrimBlock:(CancelBlock)confirm {
    
    RKAlertView *alert = [[RKAlertView alloc] initWithTitle:title message:msg cancelTitle:confirmTitle confirmTitle:nil  confrimBlock:nil cancelBlock:confirm];
    [alert show];
}

//UIAlertViewStylePlainTextInput样式
+ (void)showAlertPlainTextWithTitle:(NSString *)title message:(NSString *)msg cancelTitle:(NSString *)cancelTitle confirmTitle:(NSString *)confirmTitle alertViewStyle:(UIAlertViewStyle)alertStype confrimBlock:(ConfirmBlock)confirm cancelBlock:(CancelBlock)cancel {
    
    RKAlertView *alert = [[RKAlertView alloc] initWithTitle:title message:msg cancelTitle:cancelTitle confirmTitle:confirmTitle confrimBlock:confirm cancelBlock:cancel];
    alert.alertViewStyle = alertStype;
    [alert show];
}

#pragma -mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (1 == buttonIndex) {
        if (_confirmBlock) {
            _confirmBlock(alertView);
        }
    }else {
        if (_cancelBlock) {
            _cancelBlock();
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
