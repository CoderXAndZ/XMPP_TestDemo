//
//  XZAfterThreeMinutesView.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/7/9.
//  Copyright © 2018年 XZ. All rights reserved.
//  3分钟后页面

#import "XZAfterThreeMinutesView.h"
#import "XZButton.h"

@implementation XZAfterThreeMinutesView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupAfterThreeMinutesView];
    }
    return self;
}

/// 点击按钮
- (void)didClickButton:(UIButton *)button {
    if (self.blockClickAfterThreeMBtn) {
        self.blockClickAfterThreeMBtn(button.tag);
    }
}

/// 设置页面
- (void)setupAfterThreeMinutesView {
    self.backgroundColor = [UIColor whiteColor];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KProjectScreenWidth, 1)];
    [self addSubview:line];
    line.backgroundColor = XZColor(191, 191, 191);
    
    NSArray *arrImg = @[@"after_three_minutes_satisfaction_evaluation",@"after_three_minutes_new_sesseion",@"after_three_minutes_message"];
    NSArray *arrTitle = @[@"满意度评价",@"新会话",@"留言"];
//    NSArray *arrColor = @[[UIColor greenColor],[UIColor blueColor],[UIColor orangeColor]];
    for (int i = 0; i < 3; i++) {
        XZButton *button = [XZButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:button];
        button.buttonsType = XZButtonTypePicAbove;
        [button setImage:[UIImage imageNamed:arrImg[i]] forState:UIControlStateNormal];
        [button setTitle:arrTitle[i] forState:UIControlStateNormal];
        [button setTitleColor:XZColor(51, 51, 51) forState:UIControlStateNormal];
        [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        CGFloat width = (KProjectScreenWidth - 40) / 3.0;
        button.frame = CGRectMake(20 + i * width, 10, width, self.frame.size.height - 15);
        [button.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        button.tag = 1000 + i;
        [button addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
//        [button setBackgroundColor:arrColor[i]];
    }
}
@end
