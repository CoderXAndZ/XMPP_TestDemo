//
//  XZButton.m
//
//  Created by XZ on 15/12/18.
//  Copyright © 2015年 XZ. All rights reserved.
//

#import "XZButton.h"
#import "UIView+Extension.h"

@implementation XZButton
- (void)awakeFromNib{
    [super awakeFromNib];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)layoutSubviews{
    [super layoutSubviews];
//    self.imageView.backgroundColor = [UIColor redColor];
//    self.titleLabel.backgroundColor = [UIColor orangeColor];
    switch (self.buttonsType) {
        case 0: // 图片和文字是上下的
        {
            // 1.调整图片的位置和尺寸
            self.imageView.y = 0;
            self.imageView.centerX = self.width * 0.5;
            
            // 2.调整下面文字的位置和尺寸
            self.titleLabel.x = 0;
            self.titleLabel.y = self.imageView.height;
            self.titleLabel.width = self.width;
            self.titleLabel.height = self.height - self.titleLabel.y;
        }
            break;
        case 1: // 图片和文字是左右的，中间有一段距离
        {
            self.titleLabel.x = CGRectGetMaxX(self.imageView.frame) + 10;
        }
            break;
        case 2: // 文字在左边，图片在右边
        {
            // 1.设置titleLabel的x位置
            self.titleLabel.x = 6;
            // 2. 计算imageView的x
            self.imageView.x = CGRectGetMaxX(self.titleLabel.frame) + 5;
        }
            break;
        default:
            break;
    }
}

@end
