//
//  RKAlertView.h
//  RKAlertView
//
//  Created by Roki Liu on 16/3/10.
//  Copyright © 2016年 Snail. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CancelBlock)();
typedef void(^ConfirmBlock)(UIAlertView *alertView);

@interface RKAlertView : UIAlertView <UIAlertViewDelegate>

//UIAlertViewStyleDefault样式
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)msg cancelTitle:(NSString *)cancelTitle confirmTitle:(NSString *)confirmTitle confrimBlock:(ConfirmBlock)confirm cancelBlock:(CancelBlock)cancel;

//没有取消按钮的UIAlertViewStyle样式
+ (void)showNoCancelBtnAlertWithTitle:(NSString *)title message:(NSString *)msg confirmTitle:(NSString *)confirmTitle confrimBlock:(CancelBlock)confirm;


//UIAlertViewStylePlainTextInput样式
+ (void)showAlertPlainTextWithTitle:(NSString *)title message:(NSString *)msg cancelTitle:(NSString *)cancelTitle confirmTitle:(NSString *)confirmTitle alertViewStyle:(UIAlertViewStyle)alertStype confrimBlock:(ConfirmBlock)confirm cancelBlock:(CancelBlock)cancel;

@end
