//
//  XZTextView.h
//  XZFenLeiJieMian
//
//  Created by admin on 16/5/5.
//  Copyright © 2016年 yuyang. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef void(^textHeightChangedBlock)(NSString *text,CGFloat textHeight);


@interface XZTextView : UITextView

/// 占位文字
@property (nonatomic, strong) NSString *placeholder;

/// 占位文字颜色
@property (nonatomic, strong) UIColor *placeholderColor;
/// 占位符字体大小
@property (nonatomic,strong) UIFont *placeholderFont;

/// textView最大行数
@property (nonatomic, assign) NSUInteger maxNumberOfLines;

/**
 *  文字高度改变block → 文字高度改变会自动调用
 *  block参数(text) → 文字内容
 *  block参数(textHeight) → 文字高度
 */
@property (nonatomic, strong) textHeightChangedBlock textChangedBlock;
/**
 *  设置圆角
 */
@property (nonatomic, assign) NSUInteger cornerRadius;

- (void)textValueDidChanged:(textHeightChangedBlock)block;

@end
