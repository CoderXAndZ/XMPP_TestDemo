//
//  XZKeyboardInputView.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/7/5.
//  Copyright © 2018年 XZ. All rights reserved.
//  自定义键盘

#import "XZKeyboardInputView.h"
#import "XZButton.h"

@interface XZKeyboardInputView()
{
    BOOL _isRoboter;
}

@property (nonatomic, strong) NSMutableArray *arrButton;

@end

@implementation XZKeyboardInputView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupKeyboardInputView];
    }
    return self;
}

- (void)setIsRobot:(BOOL)isRobot {
    isRobot = isRobot;
    
    _isRoboter = isRobot;
    
    if (isRobot) { // 是机器人
        self.arrButton = @[@{@"title":@"留言",@"image":@"toolbar_keyboard_message"},
                           @{@"title":@"评价",@"image":@"toolbar_keyboard_ evaluation"}
                           ].mutableCopy;
    }else { // 人工
        self.arrButton = @[@{@"title":@"图片",@"image":@"toolbar_keyboard_photo"},
                           @{@"title":@"留言",@"image":@"toolbar_keyboard_message"},
                           @{@"title":@"评价",@"image":@"toolbar_keyboard_ evaluation"},
                           @{@"title":@"附件",@"image":@"toolbar_keyboard_attachment"}
                           ].mutableCopy;
    }
    
    for (int i = 0; i < self.arrButton.count; i++) {
        XZButton *button = (XZButton *)self.subviews[i];
        button.hidden = NO;
        
        NSString *image = self.arrButton[i][@"image"];
        NSString *title = self.arrButton[i][@"title"];
        
        [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
    }
    
}

- (BOOL)isRobot {
    return _isRoboter;
}

/// 点击按钮
- (void)didClickButton:(UIButton *)button {
    if (self.blockClickKeyboardInputViewBtn) {
        self.blockClickKeyboardInputViewBtn(button.tag);
    }
}

/// 设置页面
- (void)setupKeyboardInputView {
    self.backgroundColor = [UIColor whiteColor];
    
    for (int i = 0; i < 4; i++) {
        XZButton *button = [XZButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:button];
        button.buttonsType = XZButtonTypePicAbove;
//        button.backgroundColor = [UIColor greenColor];
        button.hidden = YES;
        [button setTitleColor:XZColor(51, 51, 51) forState:UIControlStateNormal];
        [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        CGFloat width = (KProjectScreenWidth - 30) / 4.0;
        button.frame = CGRectMake(15 + i * width, 20, width - 1, 60);
        [button.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
        button.tag = 2000 + i;
        [button addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (NSMutableArray *)arrButton {
    if (!_arrButton) {
        _arrButton = [NSMutableArray array];
    }
    return _arrButton;
}
@end
