//
//  NSString+XZEmoji.h
//  表情键盘
//
//  Created by XZ on 16/7/7.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (XZEmoji)

/// 将十六进制的编码转为 emoji 字符串
///
/// @param intCode 无符号 32 位整数
///
/// @return emoji 字符串
+ (NSString *)xz_emojiWithIntCode:(unsigned int)intCode;

/// 将十六进制的编码转为 emoji 字符串
///
/// @param stringCode 十六进制格式的字符串，例如：`0x1f633`
///
/// @return emoji 字符串
+ (NSString *)xz_emojiWithStringCode:(NSString *)stringCode;

/// 返回当前十六进制格式字符串 `0x1f633` 对应的 emoji 字符串
///
/// @return emoji 字符串
- (NSString *)xz_emoji;

@end
