//
//  XZEmoticonTipView.m
//  表情键盘
//
//  Created by XZ on 16/3/5.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "XZEmoticonTipView.h"
#import "UIImage+XZEmoticon.h"
#import "XZEmoticonButton.h"

@implementation XZEmoticonTipView {
    XZEmoticonButton *_tipButton;
}

#pragma mark - 属性
- (void)setEmoticon:(XZEmoticon *)emoticon {
    
    if (_tipButton.emoticon == emoticon) {
        return;
    }
    
    _tipButton.emoticon = emoticon;
    
    CGPoint center = _tipButton.center;
    _tipButton.center = CGPointMake(center.x, center.y + 16);
    [UIView animateWithDuration:0.25
                          delay:0
         usingSpringWithDamping:0.4
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _tipButton.center = center;
                     }
                     completion:nil];
}

#pragma mark - 构造函数
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithImage:[UIImage xz_imageNamed:@"emoticon_keyboard_magnifier"]];
    if (self) {
        // 计算按钮大小
        CGFloat width = 40;
        CGFloat x = (self.bounds.size.width - width) * 0.5;
        CGRect rect = CGRectMake(x, 8, width, width);
        
        _tipButton = [XZEmoticonButton emoticonButtonWithFrame:rect tag:0];
        [self addSubview:_tipButton];
        // 修改描点以更改TipView中心点 实现提示遮挡时的偏移
        self.layer.anchorPoint = CGPointMake(0.5, 0.8);
    }
    return self;
}

@end
