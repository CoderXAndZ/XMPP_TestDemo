//
//  UIImage+XZChat.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/26.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import "UIImage+XZChat.h"

@implementation UIImage (XZChat)

/// 返回当前图像从中心点开始向四周的拉伸结果
///
/// @return UIImage
- (UIImage *)xz_resizableImageWithCapInsets:(UIEdgeInsets)capInsets {
    return [self resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch];
   }

/// 生成带箭头的图片
+ (UIImage *)imageArrowWithImage:(UIImage *)image
                       isSender:(BOOL)isSender
{
    CGSize imageSize = image.size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    UIBezierPath *path = [self getArrowBezierPath:isSender imageSize:imageSize];
    CGContextAddPath(contextRef, path.CGPath);
    CGContextEOClip(contextRef);
    [image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    UIImage *arrowImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return arrowImage;
}

/// 获取带箭头的Bezier路径
+ (UIBezierPath *)getArrowBezierPath:(BOOL)isSender
                           imageSize:(CGSize)imageSize
{
    CGFloat arrowWidth = 6;
    CGFloat marginTop = 15;
    CGFloat arrowHeight = 10;
    CGFloat imageW = imageSize.width;
    UIBezierPath *path;
    if (isSender) {
        path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, imageSize.width - arrowWidth, imageSize.height) cornerRadius:6];
        [path moveToPoint:CGPointMake(imageW - arrowWidth, 0)];
        [path addLineToPoint:CGPointMake(imageW - arrowWidth, marginTop)];
        [path addLineToPoint:CGPointMake(imageW, marginTop + 0.5 * arrowHeight)];
        [path addLineToPoint:CGPointMake(imageW - arrowWidth, marginTop + arrowHeight)];
        [path closePath];
        
    } else {
        path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(arrowWidth, 0, imageSize.width - arrowWidth, imageSize.height) cornerRadius:6];
        [path moveToPoint:CGPointMake(arrowWidth, 0)];
        [path addLineToPoint:CGPointMake(arrowWidth, marginTop)];
        [path addLineToPoint:CGPointMake(0, marginTop + 0.5 * arrowHeight)];
        [path addLineToPoint:CGPointMake(arrowWidth, marginTop + arrowHeight)];
        [path closePath];
    }
    return path;
}

/// 修改图片大小
+ (CGSize)changeImgSize:(CGSize)imgSize
                maxSize:(CGSize)maxSize {
    CGFloat width = 0;
    CGFloat height = 0;
//    if (imgSize.width > imgSize.height) {
//        width  = maxSize.width;
//        height = imgSize.height / imgSize.width * width;
//    } else {
//        height = maxSize.height;
//        width  = imgSize.width / imgSize.height * height;
//    }
    
    if (imgSize.width > maxSize.width) {
        width  = maxSize.width;
        height = imgSize.height / imgSize.width * width;
    }else if (imgSize.width < 50) {
        width = 50;
        height = imgSize.height / imgSize.width * width;
    }else {
        width = imgSize.width;
        height = imgSize.height;
    }
    
    return CGSizeMake(width, height);
}

@end
