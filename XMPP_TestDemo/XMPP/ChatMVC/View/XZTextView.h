//
//  XZTextView.h
//  XZFenLeiJieMian
//
//  Created by admin on 16/5/5.
//  Copyright © 2016年 yuyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XZTextView : UITextView
/** 占位文字 */
@property (nonatomic, strong) NSString *placeholder;
/** 文字颜色 */
@property (nonatomic, strong) UIColor *color;
/** 行数控制 */
@property (nonatomic, assign) NSInteger numberOfLines;
/// 最高高度
@property (nonatomic, assign,readonly) CGFloat maxHeight;

///// 一行高度
//@property (nonatomic, assign,readonly) CGFloat oneLineHeight;

/// 修改高度
@property (nonatomic, copy) void(^blockChangeHeight)(CGFloat height,NSString *text);

@end
