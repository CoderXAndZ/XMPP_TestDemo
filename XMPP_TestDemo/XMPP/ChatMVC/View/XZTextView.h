//
//  XZTextView.h
//  XZFenLeiJieMian
//
//  Created by admin on 16/5/5.
//  Copyright © 2016年 yuyang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^blockChangeHeight)(CGFloat height,NSString *text);

@interface XZTextView : UITextView
/** 占位文字 */
@property (nonatomic, strong) NSString *placeholder;
/** 文字颜色 */
@property (nonatomic, strong) UIColor *color;
/** 行数控制 */
@property (nonatomic, assign) NSInteger numOfLines;
/** 最高高度 */
@property (nonatomic, assign,readonly) CGFloat maxHeight;
/** 设置圆角 */
@property (nonatomic, assign) NSUInteger cornerRadius;

/// 修改高度
@property (nonatomic, copy) blockChangeHeight blockChangeHeight;

- (void)textValueDidChanged:(blockChangeHeight)block;

@end
