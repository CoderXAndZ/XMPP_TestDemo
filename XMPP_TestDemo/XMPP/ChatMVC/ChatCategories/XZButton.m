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
    
//    self.imageView.backgroundColor = [UIColor purpleColor];
//    self.titleLabel.backgroundColor = [UIColor orangeColor];
    
    switch (self.buttonsType) {
        case 0: // 图片和文字是上下的
        {
            // 1.调整图片的位置和尺寸
            self.imageView.fm_y = 0;
            self.imageView.fm_centerX = self.fm_width * 0.5;
            
            // 2.调整下面文字的位置和尺寸
            self.titleLabel.fm_x = 0;
            self.titleLabel.fm_y = self.imageView.fm_height;
            self.titleLabel.fm_width = self.fm_width;
            self.titleLabel.fm_height = self.fm_height - self.titleLabel.fm_y;
            
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
        }
            break;
        case 1: // 图片和文字是左右的，中间有一段距离
        {
            self.titleLabel.fm_x = CGRectGetMaxX(self.imageView.frame) + 10;
        }
            break;
        case 2: // 文字在左边，图片在右边
        {
            // 1.设置titleLabel的x位置
            self.titleLabel.fm_x = 6;
            // 2. 计算imageView的x
            self.imageView.fm_x = CGRectGetMaxX(self.titleLabel.frame) + 5;
        }
            break;
        default:
            break;
    }
}

@end
