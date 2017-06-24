//
//  ZJInptutView.h
//  InputContentDemo
//
//  Created by 铅笔 on 2016/10/8.
//  Copyright © 2016年 铅笔. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^removeCoverAndInputView)(NSString *inputContent);

@interface ZJInptutView : UIView

@property (nonatomic,copy) removeCoverAndInputView removeView;

/**
 *输入内容 界面布局 文字传播
 */
- (id) initWithFrame:(CGRect)frame andTitle:(NSString *)title andPlaceHolderTitle:(NSString *)palceContent;

@end
