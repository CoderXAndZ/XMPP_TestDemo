//
//  NSString+XZChat.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/26.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import "NSString+XZChat.h"

@implementation NSString (XZChat)
/// 获取文字高度
- (CGFloat)xz_textHeightWithWidth:(CGFloat)width font:(CGFloat)font {
    NSDictionary *attres = @{NSFontAttributeName:[UIFont systemFontOfSize:font]};
    
    return [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attres context:nil].size.height;
}

/// 获取文字宽度
- (CGFloat)xz_textWidthWithHeight:(CGFloat)height font:(CGFloat)font {
    NSDictionary *attres = @{NSFontAttributeName:[UIFont systemFontOfSize:font]};
    
    return [self boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attres context:nil].size.width;
}

@end
