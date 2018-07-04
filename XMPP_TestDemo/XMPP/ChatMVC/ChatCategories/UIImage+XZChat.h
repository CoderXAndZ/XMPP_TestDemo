//
//  UIImage+XZChat.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/26.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (XZChat)

/// 返回当前图像从中心点开始向四周的拉伸结果
///
/// @return UIImage
- (UIImage *)xz_resizableImageWithCapInsets:(UIEdgeInsets)capInsets;

/// 生成带箭头的图片
+ (UIImage *)imageArrowWithImage:(UIImage *)image
                       isSender:(BOOL)isSender;

/// 获取带箭头的Bezier路径
+ (UIBezierPath *)getArrowBezierPath:(BOOL)isSender
                           imageSize:(CGSize)imageSize;

/// 修改图片大小
+ (CGSize)changeImgSize:(CGSize)imgSize
                maxSize:(CGSize)maxSize;
@end
