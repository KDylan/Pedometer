//
//  UITextField+WayTextField.m
//  WayService
//
//  Created by Johnny on 16/6/27.
//  Copyright © 2016年 Johnny. All rights reserved.
//

#import "UITextField+WayTextField.h"

@implementation UITextField (WayTextField)

-(void)changeTextWithNSString:(NSString *)text {
    //UITextPosition
    //文本开始
    UITextPosition *begining = self.beginningOfDocument;
    
    //标记和选定文本
    UITextPosition *start = self.selectedTextRange.start;
    UITextPosition *end = self.selectedTextRange.end;
    
    //计算文本的范围和位置
    NSInteger staetIndex = [self offsetFromPosition:begining toPosition:start];
    NSInteger endIndex = [self offsetFromPosition:begining toPosition:end];
    
    //获取输入的字符串
    NSString *originText = self.text;
    
    //截取字符串---从字符串的开头一直截取到指定的位置，但不包括该位置字符
    NSString *firstPart = [originText substringToIndex:staetIndex];
    
    //截取字符串---从指定位置开始（包括指定位置字符），并包括之后的全部字符
    NSString *secondPart = [originText substringFromIndex:endIndex];
    
    //设置变量
    NSInteger offset;
    
    if (![text isEqualToString:@""]) {
        offset = text.length;
    } else {
        if (staetIndex == endIndex) {
            if (staetIndex == 0) {
                return;
            }
            offset = -1;
            firstPart = [firstPart substringToIndex:(firstPart.length - 1)];
        } else {
            offset = 0;
        }
    }
    
    NSString *newText = [NSString stringWithFormat:@"%@%@%@",firstPart,secondPart,text];
    self.text = newText;
    UITextPosition *now = [self positionFromPosition:start offset:offset];
    UITextRange *range = [self textRangeFromPosition:now toPosition:now];
    self.selectedTextRange = range;
    
}

@end
