//
//  NSString+XZChat.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/26.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (XZChat)
/// 获取文字高度
- (CGFloat)xz_textHeightWithWidth:(CGFloat)width font:(CGFloat)font;
/// 获取文字宽度
- (CGFloat)xz_textWidthWithHeight:(CGFloat)height font:(CGFloat)font;
@end
