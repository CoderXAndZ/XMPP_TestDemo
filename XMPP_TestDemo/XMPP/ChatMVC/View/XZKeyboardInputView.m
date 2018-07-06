//
//  XZKeyboardInputView.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/7/5.
//  Copyright © 2018年 XZ. All rights reserved.
//  自定义键盘

#import "XZKeyboardInputView.h"

@implementation XZKeyboardInputView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupKeyboardInputView];
    }
    return self;
}

- (void)setupKeyboardInputView {
    self.backgroundColor = [UIColor redColor];
}

@end
