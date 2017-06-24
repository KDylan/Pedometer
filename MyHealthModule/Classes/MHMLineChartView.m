//
//  MHMLineChartView.m
//  MyHealthModule
//
//  Created by ChenWeidong on 16/2/27.
//  Copyright © 2016Year. All rights reserved.
//

#import "MHMLineChartView.h"
#import "MHMHealthModel.h"
#import "MHMHelper.h"
#import "UIImage+Resize.h"
#import "UIView+Layout.h"
#import "UtilsMacro.h"
#import "UIImageView+Dashed.h"

@interface MHMLineChartView ()
@property (nonatomic, strong) UILabel *lblStepCount;
@property (nonatomic, strong) UILabel *lblDayAverageStep;
@property (nonatomic, strong) NSArray *healthModelArray;
@property (nonatomic, assign) NSInteger maxStepCount;
@property (nonatomic, assign) NSInteger minStepCount;
@property (nonatomic, assign) NSInteger totalStepCount;
@property (nonatomic, assign) NSInteger maxLimitCount;
@property (nonatomic, assign) NSInteger minLimitCount;
@property (nonatomic, strong) CABasicAnimation *pathAnimation;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, assign) MHMHealthInterval interval;
@property (nonatomic, strong) UILabel *maxCountLabel;
@property (nonatomic, strong) UILabel *minCountLabel;
@property(nonatomic,strong)NSMutableArray *monthDateArr;
@end

@implementation MHMLineChartView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    [self setupUI];
    
    return self;
}

- (void)setupChartWithDictionary:(NSDictionary *)dic index:(MHMHealthInterval)interval {
  
    self.healthModelArray = [dic valueForKey:kResultModelsKey];
  //  // // NSLog(@"dic==========%@",dic);
    
    self.maxStepCount = [[dic valueForKey:kMaxStepCountKey] integerValue];
    self.minStepCount = [[dic valueForKey:kMinStepCountKey] integerValue];
    self.totalStepCount = [[dic valueForKey:kTotalStepCountKey] integerValue];
    self.interval = interval;
    self.maxLimitCount = [self getMaxLimitCount];
    self.minLimitCount = [self getMinLimitCount];
    if (self.healthModelArray.count != 0) {
        [self.shapeLayer removeAllAnimations];
        [self.shapeLayer removeFromSuperlayer];
        [self drawLineChart];
    }
    //Day/Year均值手动赋值，这里不作处理
    if (interval != MHMHealthInterval_day && interval != MHMHealthInterval_year) {
        UILabel *lblDayAverageStep = [self viewWithTag:1007];
        lblDayAverageStep.text = F(@"Daily Average：%zd",self.healthModelArray.count == 0 ? 0 : self.totalStepCount / self.healthModelArray.count);
    }
    if (interval == MHMHealthInterval_day) {//只显示Day总步数
        UILabel *lblStepCount = [self viewWithTag:1008];
        lblStepCount.text = F(@"%zd steps",self.totalStepCount);
        
        
    }
    self.maxCountLabel.text = F(@"%ld",(long)self.maxLimitCount);
    self.minCountLabel.text = F(@"%ld",(long)self.minLimitCount);
    [self showX];
    
}
//  设置最大值
- (NSInteger)getMaxLimitCount {
    NSInteger maxLimitCount = 0;
    if (self.maxStepCount <= 0) {
        maxLimitCount = 0;
    } else {
        maxLimitCount = self.maxStepCount + self.maxStepCount / 3;
        if (self.interval == MHMHealthInterval_day) {
            maxLimitCount = maxLimitCount / 10 * 10;
        } else if (self.interval == MHMHealthInterval_month || self.interval == MHMHealthInterval_week) {
            maxLimitCount = maxLimitCount / 100 * 100;
        } else if (self.interval == MHMHealthInterval_year) {
            maxLimitCount = maxLimitCount / 10000 * 10000;
        }
    }
    return maxLimitCount;
}
//  设置最小值
- (NSInteger)getMinLimitCount {
    NSInteger minLimitCount = 0;
    if (self.maxStepCount <= 0) {
        minLimitCount = 0;
    } else {
        minLimitCount = self.minStepCount - self.minStepCount / 3;
        if (self.interval == MHMHealthInterval_month || self.interval == MHMHealthInterval_week || self.interval == MHMHealthInterval_day) {
            minLimitCount = minLimitCount / 100 * 100;
        } else if (self.interval == MHMHealthInterval_year) {
            minLimitCount = minLimitCount / 10000 * 10000;
        }
    }
    return minLimitCount;
}

//  设置图表UI
- (void)setupUI {
    
    self.backgroundColor = [UIColor grayColor];
    
    UIColor *lblColor = [UIColor whiteColor];
    
    //步数文字
    UILabel *lblStepPrompt = [self createLabelWithRect:CGRectMake(20, 25, 55, 18)
                                             alignment:NSTextAlignmentLeft
                                                  font:[UIFont systemFontOfSize:20]
                                             textColor:lblColor
                                                  text:@"Steps"];
   // lblStepPrompt.backgroundColor = [UIColor redColor];
    [self addSubview:lblStepPrompt];
    
    //Day平均值
    _lblDayAverageStep = [self createLabelWithRect:CGRectMake(lblStepPrompt.left, lblStepPrompt.bottom + 25, 180, 18)
                                         alignment:NSTextAlignmentLeft
                                              font:[UIFont systemFontOfSize:16]
                                         textColor:lblColor
                                              text:@"Daily Average：0"];
    _lblDayAverageStep.tag = 1007;
   //  _lblDayAverageStep.backgroundColor = [UIColor redColor];
    [self addSubview:_lblDayAverageStep];
    
    
    
    //步数
    _lblStepCount = [self createLabelWithRect:CGRectMake(0, lblStepPrompt.top, 130, 20)
                                    alignment:NSTextAlignmentRight
                                         font:[UIFont systemFontOfSize:20]
                                    textColor:lblColor
                                         text:@"0 steps"];
    _lblStepCount.right = self.right - 12;
    _lblStepCount.tag = 1008;
    _lblStepCount.textColor = lblColor;
    
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:_lblStepCount.text];
    
    [attributeStr setAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:16] }
                          range:NSMakeRange(_lblStepCount.text.length - 1, 1)];
    _lblStepCount.attributedText = attributeStr;
    
 //   _lblStepCount.backgroundColor = [UIColor redColor];

    [self addSubview:_lblStepCount];
    
    //今天
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    UILabel *lblDayPrompt = [self createLabelWithRect:CGRectMake(0, _lblDayAverageStep.top, 120, 20)
                                            alignment:NSTextAlignmentRight
                                                 font:[UIFont systemFontOfSize:16]
                                            textColor:lblColor
                                                 text:F(@"Today:%@", [formatter stringFromDate:[NSDate date]])];
    lblDayPrompt.right = _lblStepCount.right;
    //lblDayPrompt.backgroundColor = [UIColor redColor];
    [self addSubview:lblDayPrompt];
    
    // 第一条线
    UIView *firstLineView = [[UIView alloc] initWithFrame:CGRectMake(12, _lblDayAverageStep.bottom + 25, self.width - 24, 0.5)];
    firstLineView.backgroundColor = lblColor;
    firstLineView.tag = 1001;
   // firstLineView.backgroundColor = [UIColor yellowColor];
    
    [self addSubview:firstLineView];
    
    //  显示最大值
    self.maxCountLabel = [self createLabelWithRect:CGRectMake(0, firstLineView.bottom+10, 150, 12) alignment:NSTextAlignmentRight font:[UIFont systemFontOfSize:16.0] textColor:lblColor text:@"0"];
    self.maxCountLabel.right = _lblStepCount.right;
    [self addSubview:self.maxCountLabel];
    
    //  底部的线
    UIView *thirdLineView = [[UIView alloc] initWithFrame:CGRectMake(firstLineView.left, self.height-40, firstLineView.width, firstLineView.height)];
    thirdLineView.backgroundColor = firstLineView.backgroundColor;
    thirdLineView.tag = 1003;
  //  thirdLineView.backgroundColor = [UIColor yellowColor];
    
    [self addSubview:thirdLineView];
    
    //  将虚线放在两条实线中间
    CGFloat SecondY ;
    
    SecondY = ((thirdLineView.frame.origin.y-firstLineView.frame.origin.y)/2+firstLineView.frame.origin.y);
    //  第二条虚线
    UIImageView *secondLineView = [[UIImageView alloc] initWithFrame:CGRectMake(firstLineView.left, SecondY, firstLineView.width, firstLineView.height)];
    secondLineView.image = [self drawDottedLine:secondLineView.size lineWidth:1.5 lineColor:lblColor];
    secondLineView.tag = 1002;
    
    //secondLineView.backgroundColor = [UIColor yellowColor];
    [self addSubview:secondLineView];
    
    
    //  显示最小值
    self.minCountLabel = [self createLabelWithRect:CGRectMake(0, thirdLineView.top - 20, 150, 12) alignment:NSTextAlignmentRight font:[UIFont systemFontOfSize:16.0] textColor:lblColor text:@"0"];
    self.minCountLabel.right = _lblStepCount.right;
    [self addSubview:self.minCountLabel];
    
    //  编辑X轴
    [self drawX];
    
    //  贝塞尔曲线(设置点)
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.lineWidth = 1;
    self.shapeLayer.fillColor = [UIColor redColor].CGColor;
    self.shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    [self.shapeLayer setAffineTransform:CGAffineTransformMakeTranslation(0, thirdLineView.top - firstLineView.bottom)];
    [self.shapeLayer setAffineTransform:CGAffineTransformMakeScale(1, -1)];
}


- (UILabel *)createLabelWithRect:(CGRect)rect alignment:(NSTextAlignment)textAlignment font:(UIFont *)textFont textColor:(UIColor *)textColor text:(NSString *)text {
    UILabel *lblPrompt = [[UILabel alloc] initWithFrame:rect];
    lblPrompt.textAlignment = textAlignment;
    lblPrompt.textColor = textColor;
    lblPrompt.font = textFont;
    lblPrompt.text = text;
    return lblPrompt;
}

// 设置X轴
- (void)drawX {
    UIView *thirdLine = [self viewWithTag:1003];
    for (NSInteger j = 1; j <= 7; j++) {
        
        CGFloat x = 15 + (self.width - 24) / 7 * (j - 1);
        
        UILabel *xLabel = [self createLabelWithRect:CGRectMake(x, thirdLine.bottom + 12, 40, 10) alignment:NSTextAlignmentCenter font:[UIFont systemFontOfSize:14.0] textColor:[UIColor whiteColor] text:@""];
        xLabel.backgroundColor = [UIColor clearColor];
        xLabel.text = @"0.00";
        xLabel.hidden = YES;
        xLabel.tag = 2000 + j;
        [self addSubview:xLabel];
    }
}

// 显示X轴
- (void)showX {
    UILabel *label1 = [self viewWithTag:2001];//0
    UILabel *label2 = [self viewWithTag:2002];
    UILabel *label3 = [self viewWithTag:2003];
    UILabel *label4 = [self viewWithTag:2004];//8
    UILabel *label5 = [self viewWithTag:2005];
    UILabel *label6 = [self viewWithTag:2006];
    UILabel *label7 = [self viewWithTag:2007];//12
    
    if (self.interval == MHMHealthInterval_day) {
        
        [self setLabelArray:@[label1,label2,label3,label4,label5] hidden:NO];
        [self setLabelArray:@[label6,label7] hidden:YES];
        [self setDayLabelArray:@[label1,label2,label3,label4,label5] text:@[@"0:00",@"6:00",@"12:00",@"18:00",@"0:00"]];
        [self resetDayLabelFrame:@[label1,label2,label3,label4,label5,label6,label7]];
        
    }
    else if (self.interval == MHMHealthInterval_week) {
        
        NSInteger lastMonth = 0;
        NSMutableArray *textArray = @[].mutableCopy;//  nil
        
        for (MHMHealthModel *model in self.healthModelArray) {
           
            if (lastMonth != model.startDateComponents.month) {
             
                [textArray addObject:F(@"%ld.%ld",(long)model.startDateComponents.month,(long)model.startDateComponents.day)];}
            else {
                    
                [textArray addObject:F(@"%ld",(long)model.startDateComponents.day)];
            }
            
            lastMonth = model.startDateComponents.month;
            
        }
        // // NSLog(@"for -out ");
        [self setLabelArray:@[label1,label2,label3,label4,label5,label6,label7] hidden:NO];
        [self setweekLabelArray:@[label1,label2,label3,label4,label5,label6,label7] text:textArray];
        [self resetWeekLabelFrame:@[label1,label2,label3,label4,label5,label6,label7]];
        
    }
    else if (self.interval == MHMHealthInterval_month) {
        
        [self setMonthXdate];
        
            NSMutableArray *textArray = @[].mutableCopy;
        
        [textArray addObjectsFromArray:self.monthDateArr];
            [self setMonthLabelArray:@[label1,label2,label3,label4,label5] text:textArray];
            [self setLabelArray:@[label1,label2,label3,label4,label5] hidden:NO];
        
            [self setLabelArray:@[label6,label7] hidden:YES];
        
        [self resetMonthLabelFrame:@[label1,label2,label3,label4,label5,label6,label7]];
        
        
    }
    else if (self.interval == MHMHealthInterval_year) {
        
        MHMHealthModel *lastModel = self.healthModelArray.lastObject;
        if (!lastModel) {
            [self setLabelArray:@[label1,label2,label3,label4,label5,label6,label7] hidden:YES];
            return;
        }
        NSMutableArray *textArray = @[].mutableCopy;
        if (lastModel.startDateComponents.month - 3 <= 0) {
            [textArray addObject:F(@"%ld.%ld",(long)lastModel.startDateComponents.year,(long)lastModel.startDateComponents.month)];
            [textArray addObject:F(@"%ld",12 - (3 - (long)lastModel.startDateComponents.month))];
            [textArray addObject:F(@"%ld",12 - (6 - (long)lastModel.startDateComponents.month))];
            [textArray addObject:F(@"%ld.%ld",(long)lastModel.startDateComponents.year - 1,12 - (9 - (long)lastModel.startDateComponents.month))];
        } else if (lastModel.startDateComponents.month - 6 <= 0) {
            [textArray addObject:F(@"%ld",(long)lastModel.startDateComponents.month)];
            [textArray addObject:F(@"%ld.%ld",(long)lastModel.startDateComponents.year,(long)lastModel.startDateComponents.month - 3)];
            [textArray addObject:F(@"%ld",12 - (6 - (long)lastModel.startDateComponents.month))];
            [textArray addObject:F(@"%ld.%ld",(long)lastModel.startDateComponents.year - 1,12 - (6 - (long)lastModel.startDateComponents.month))];
        } else if (lastModel.startDateComponents.month - 9 <= 0) {
            [textArray addObject:F(@"%ld",(long)lastModel.startDateComponents.month)];
            [textArray addObject:F(@"%ld",(long)lastModel.startDateComponents.month - 3)];
            [textArray addObject:F(@"%ld.%ld",(long)lastModel.startDateComponents.year,(long)lastModel.startDateComponents.month - 6)];
            [textArray addObject:F(@"%ld",12 - (9 - (long)lastModel.startDateComponents.month))];
        } else if (lastModel.startDateComponents.month - 12 <= 0) {
            [textArray addObject:F(@"%ld",(long)lastModel.startDateComponents.month)];
            [textArray addObject:F(@"%ld",(long)lastModel.startDateComponents.month - 3)];
            [textArray addObject:F(@"%ld",(long)lastModel.startDateComponents.month - 6)];
            [textArray addObject:F(@"%ld.%ld",(long)lastModel.startDateComponents.year,(long)lastModel.startDateComponents.month - 9)];
        }
        
        [self setLabelArray:@[label1,label3,label5,label7] hidden:NO];
        [self setLabelArray:@[label2,label4,label6] hidden:YES];
        [self resetYearLabelFrame:@[label1,label2,label3,label4,label5,label6,label7]];
        label1.width = 70;
        label3.width = 50;
        label5.width = 50;
        label7.width = 70;
        [self setYearLabelArray:@[label1,label3,label5,label7] text:[textArray reverseObjectEnumerator].allObjects];
    }
}

#pragma mark 设置时间位置
//  设置显示Day的时间位置
- (void)resetDayLabelFrame:(NSArray *)labelArray {
    NSInteger i = labelArray.count;
    //  设置label位置
    
    for (NSInteger j = 1; j <= i; j++) {
        
        
        ((UILabel *)labelArray[j - 1]).left = 15 + (self.width) / (i-2) * (j - 1);
      
        //  设置每个label宽度
        ((UILabel *)labelArray[j - 1]).width = 40;
      
      //  ((UILabel *)labelArray[j - 1]).backgroundColor = [UIColor redColor];
        }
  
}
//  设置显示Week的时间位置
- (void)resetWeekLabelFrame:(NSArray *)labelArray {
    NSInteger i = labelArray.count;
    
    for (NSInteger j = 1; j <= i; j++) {
        
        
        ((UILabel *)labelArray[j - 1]).left = 5+ (self.width) / (i) * (j - 1);
       
        //  设置每个label宽度
        ((UILabel *)labelArray[j - 1]).width = 50;
        
      //  ((UILabel *)labelArray[j - 1]).backgroundColor = [UIColor redColor];
    }
 
}
//  设置显示Month的时间位置
- (void)resetMonthLabelFrame:(NSArray *)labelArray {
    // // NSLog(@"resetMonth");
    NSInteger i = labelArray.count;
    
    for (NSInteger j = 1; j <= i; j++) {
        //  i=7
        ((UILabel *)labelArray[j - 1]).left =5+(self.width) / (i-2) * (j - 1);
           // // NSLog(@"j=%ld",(long)j);
        //  设置每个label宽度
        ((UILabel *)labelArray[j - 1]).width = 60;
        
     //   ((UILabel *)labelArray[j - 1]).backgroundColor = [UIColor redColor];
    }
     // // NSLog(@"i=%ld",(long)i);
}

//  设置显示Year的时间位置
- (void)resetYearLabelFrame:(NSArray *)labelArray {
    NSInteger i = labelArray.count;
    //  设置label位置
    
    for (NSInteger j = 1; j <= i; j++) {
        
        
        ((UILabel *)labelArray[j - 1]).left =(self.width-36) / (i) * (j - 1);
      //  ((UILabel *)labelArray[j - 1]).backgroundColor = [UIColor redColor];
    }
}


#pragma mark 设置时间显示
//  设置Day时间显示
- (void)setDayLabelArray:(NSArray *)labelArray text:(NSArray *)textArray {
    
    if (textArray.count == labelArray.count) {
       
        for (NSInteger i = 0; i < labelArray.count; i++) {
            
            ((UILabel *)labelArray[i]).text = textArray[i];
        }
    } else {
        for (NSInteger i = 0; i < labelArray.count; i++) {
            
            ((UILabel *)labelArray[i]).text = @"day";
        }
    }
}
//  设置Week时间显示
- (void)setweekLabelArray:(NSArray *)labelArray text:(NSArray *)textArray {
    
    if (textArray.count == labelArray.count) {
        
        for (NSInteger i = 0; i < labelArray.count; i++) {
            
            ((UILabel *)labelArray[i]).text = textArray[i];
        }
    } else {
        for (NSInteger i = 0; i < labelArray.count; i++) {
            
            ((UILabel *)labelArray[i]).text = @"week";
        }
    }
}
//  Month时间显示
- (void)setMonthLabelArray:(NSArray *)labelArray text:(NSArray *)textArray {
    
    if (textArray.count == labelArray.count) {

        for (NSInteger i = 0; i < labelArray.count; i++) {
            
            
            ((UILabel *)labelArray[i]).text = textArray[i];
        }
    } else {
        for (NSInteger i = 0; i < labelArray.count; i++) {
            
            ((UILabel *)labelArray[i]).text = @"month";
        }
    }
}
//  Year时间显示
- (void)setYearLabelArray:(NSArray *)labelArray text:(NSArray *)textArray {
    
    if (textArray.count == labelArray.count) {
        
        for (NSInteger i = 0; i < labelArray.count; i++) {
            
            ((UILabel *)labelArray[i]).text = textArray[i];
        }
    } else {
        for (NSInteger i = 0; i < labelArray.count; i++) {
            
            ((UILabel *)labelArray[i]).text = @"year";
        }
    }
}

//画虚线
- (UIImage *)drawDottedLine:(CGSize)size lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor {
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGFloat lengths[] = {3,3};
    CGContextSetLineWidth(context, lineWidth);
    CGContextRef line = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(line, lineColor.CGColor);
    CGContextSetLineDash(line, 0, lengths, 2);
    CGContextMoveToPoint(line, 0.0, 0);
    CGContextAddLineToPoint(line, self.frame.size.width, 0);
    CGContextStrokePath(line);
    UIImage *drawImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return drawImage;
}

// 设置时间对否隐藏
- (void)setLabelArray:(NSArray *)labelArray hidden:(BOOL)hidden {
    for (UILabel *label in labelArray) {
        label.hidden = hidden;
    }
}

//画折线
- (void)drawLineChart {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIBezierPath *path = [UIBezierPath bezierPath];
        NSArray *points = [self pointsFromModel:self.healthModelArray];
        CGPoint lastPoint = CGPointZero;
        for (NSInteger i = 0; i < points.count; i++) {
            CGPoint p = [[points objectAtIndex:i] CGPointValue];
            [path moveToPoint:CGPointMake(p.x + 2, p.y)];
            [path addArcWithCenter:p radius:2 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
            if (i == 0) {
                lastPoint = p;
            } else {
                float distance = sqrt(pow(p.x - lastPoint.x, 2) + pow(p.y - lastPoint.y, 2));
                float last_x1 = lastPoint.x + 2 / distance * (p.x - lastPoint.x);
                float last_y1 = lastPoint.y + 2 / distance * (p.y - lastPoint.y);
                float x1 = p.x - 2 / distance * (p.x - lastPoint.x);
                float y1 = p.y - 2 / distance * (p.y - lastPoint.y);
                [path moveToPoint:CGPointMake(last_x1, last_y1)];
                [path addLineToPoint:CGPointMake(x1, y1)];
                lastPoint = p;
            }
        }

        self.shapeLayer.path = path.CGPath;

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.layer addSublayer:self.shapeLayer];
            [CATransaction begin];
            [self.shapeLayer addAnimation:self.pathAnimation forKey:@"strokeEndAnimation"];
            self.shapeLayer.strokeEnd = 1.0;
            [CATransaction commit];
        });
    });
}
//  设置点
- (NSArray *)pointsFromModel:(NSArray *)healthModelArray {
    UIView *firstLine = [self viewWithTag:1001];
    UIView *thirdLine = [self viewWithTag:1003];
    NSMutableArray *points = @[].mutableCopy;
    NSInteger i = 0;
    if (self.interval == MHMHealthInterval_week) {
        i = 7 - healthModelArray.count;
    
    //    // NSLog(@"healthModelArray.count111 = %lu",(unsigned long)healthModelArray.count);
   
    } else if (self.interval == MHMHealthInterval_month) {
       
    //    // NSLog(@"healthModelArray.count222 = %lu",(unsigned long)healthModelArray.count);
        
        i = 30 - healthModelArray.count;
    
    } else if (self.interval == MHMHealthInterval_year) {
    
     //   // NSLog(@"healthModelArray.count 333= %lu",(unsigned long)healthModelArray.count);
        
        i = 12 - healthModelArray.count;
    }
    for (MHMHealthModel *model in healthModelArray) {
        i++;
        CGFloat x = 0;
        if (self.interval == MHMHealthInterval_day) {
            x = model.startDateComponents.hour / 24.0 * (self.width - 24);
        } else if (self.interval == MHMHealthInterval_week) {
            x = 25 + (self.width - 24) / 7 * (i - 1);
        } else if (self.interval == MHMHealthInterval_month) {
            x = i / 31.0 * (self.width - 24);
        } else if (self.interval == MHMHealthInterval_year) {
            x = i / 13.0 * (self.width - 24);
        }
        CGFloat y = (model.stepCount - self.minLimitCount) / (CGFloat)(self.maxLimitCount - self.minLimitCount) * (thirdLine.top - firstLine.top);
        x += 12;
        y -= thirdLine.top;
        CGPoint point = CGPointMake(x, y);
        [points addObject:[NSValue valueWithCGPoint:point]];
    }
    return points;
}

-(CABasicAnimation *)pathAnimation
{
    if (!_pathAnimation) {
        _pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        _pathAnimation.duration = 0.0;
        _pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _pathAnimation.fromValue = @0.0f;
        _pathAnimation.toValue   = @0.0f;
    }
    return _pathAnimation;
}

- (void)setAverageStepCount:(NSInteger)averageStepCount {
    _averageStepCount = averageStepCount;
    
    UILabel *lblDayAverageStep = [self viewWithTag:1007];
    lblDayAverageStep.text = F(@"Daily average：%zd",averageStepCount);
    
}
-(void)setMonthXdate{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"M.d"];
    
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    
    //[lastMonthComps setYear:1]; // year = 1表示1Year后的时间 year = -1为1Year前的Day期，month day 类推
    // [lastMonthComps setMonth:-5];
    
    
    NSDateComponents *lastMonthComps = [[NSDateComponents alloc] init];
    [lastMonthComps setDay:-1];
    NSDateComponents *lastMonthComps1 = [[NSDateComponents alloc] init];
    [lastMonthComps1 setDay:-8];
    
    
    NSDateComponents *lastMonthComps2 = [[NSDateComponents alloc] init];
    [lastMonthComps2 setDay:-15];
    
    NSDateComponents *lastMonthComps3 = [[NSDateComponents alloc] init];
    [lastMonthComps3 setDay:-22];
    
    NSDateComponents *lastMonthComps4 = [[NSDateComponents alloc] init];
    [lastMonthComps4 setDay:-29];
    
    
    NSDate *newdate = [calendar dateByAddingComponents:lastMonthComps toDate:currentDate options:0];
    
    
    NSDate *newdate1 = [calendar dateByAddingComponents:lastMonthComps1 toDate:currentDate options:0];
    
    NSDate *newdate2 = [calendar dateByAddingComponents:lastMonthComps2 toDate:currentDate options:0];
    
    NSDate *newdate3 = [calendar dateByAddingComponents:lastMonthComps3 toDate:currentDate options:0];
    
    NSDate *newdate4 = [calendar dateByAddingComponents:lastMonthComps4 toDate:currentDate options:0];
    
    
    NSString *dateStr = [formatter stringFromDate:newdate];
    
    // // NSLog(@"date str = %@", dateStr);
    
    
    NSString *dateStr1 = [formatter stringFromDate:newdate1];
    
    // // NSLog(@"date str = %@", dateStr1);
    
    NSString *dateStr2 = [formatter stringFromDate:newdate2];
    
    // // NSLog(@"date str = %@", dateStr2);
    
    NSString *dateStr3 = [formatter stringFromDate:newdate3];
    
    // // NSLog(@"date str = %@", dateStr3);
    
    NSString *dateStr4 = [formatter stringFromDate:newdate4];
    
    // // NSLog(@"date str = %@", dateStr4);
    
    NSMutableArray *dateArr = [NSMutableArray array];
    
    [dateArr addObject:dateStr4];
    [dateArr addObject:dateStr3];
    [dateArr addObject:dateStr2];
    [dateArr addObject:dateStr1];
    [dateArr addObject:dateStr];
    // // NSLog(@"dateArr=%@",dateArr);
    
    self.monthDateArr = dateArr;
}
@end
