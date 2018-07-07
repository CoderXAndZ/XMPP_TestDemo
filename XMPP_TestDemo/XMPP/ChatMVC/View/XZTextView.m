//
//  XZTextView.m
//  XZFenLeiJieMian
//
//  Created by admin on 16/5/5.
//  Copyright © 2016年 yuyang. All rights reserved.
//

#import "XZTextView.h"
#import "UIView+Extension.h"

@interface XZTextView ()
{
    /// 最高高度
    CGFloat _maxHeight;
    /// 文字高度
    CGFloat _textHeight;
}
/**
 *  占位文字Label
 */
@property (weak, nonatomic) UILabel *phLabel;

/// 初始高度
@property (nonatomic, assign) CGFloat originalHeight;
/// 文字高度
@property (nonatomic, assign) CGFloat textHeight;
@end

@implementation XZTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.phLabel.textColor = [UIColor lightGrayColor];
        
        self.scrollEnabled = NO;
        self.scrollsToTop = NO;
        self.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
        self.translatesAutoresizingMaskIntoConstraints = NO; // 允许autoLayout
        _originalHeight = frame.size.height ? frame.size.height : 35;
        
        NSLog(@"frame.size.height ====== %f",frame.size.height);
        
        // 添加监听器，监听自己的文字改变通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:nil];
        
    }
    return self;
}

- (void)textValueDidChanged:(blockChangeHeight)block {
    self.blockChangeHeight = block;
}

// 时刻监听文字键盘文字的变化，文字一旦改变便调用setNeedsDisplay方法
- (void)textDidChange
{
    // 有文字就隐藏
    self.phLabel.hidden = self.hasText;
    
    // 计算高度
    CGFloat height = ceilf([self sizeThatFits:CGSizeMake(self.bounds.size.width, MAXFLOAT)].height);
   
    if (_textHeight != height) {
        // 当高度大于最大高度时，需要滚动
        self.scrollEnabled = height > (_maxHeight && _maxHeight > 0);
        
        if (height > _maxHeight) {
            height = _maxHeight;
        }
        _textHeight = height;
        if (self.blockChangeHeight) {
            self.blockChangeHeight(height, self.text);
            
            [self.superview layoutIfNeeded];
        }
    }else {
        if (self.blockChangeHeight) {
            self.blockChangeHeight(_originalHeight, @"");
            
            [self.superview layoutIfNeeded];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 确定label的宽度，高度由文字数量自动计算
    CGSize size = CGSizeMake(self.width - 2 * self.phLabel.x, MAXFLOAT);
    // 根据文字的字体属性、文字的数量动态计算label的尺寸
    self.phLabel.size = [self.placeholder boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.font} context:nil].size;
}

// 设置行数

- (void)setNumOfLines:(NSInteger)numOfLines {
    _numOfLines = numOfLines;
    
    // 最大高度 = 每行高度 * 总行数 + textContainer的上下间距
    _maxHeight = ceil(self.font.lineHeight * numOfLines + self.textContainerInset.top + self.textContainerInset.bottom);
}
//- (void)setNumberOfLines:(NSInteger)numberOfLines {
//    _numberOfLines = numberOfLines;
//
//    // 最大高度 = 每行高度 * 总行数 + textContainer的上下间距
////    _maxHeight = numberOfLines * _oneLineHeight + 5;
//    _maxHeight = ceil(self.font.lineHeight * numberOfLines + self.textContainerInset.top + self.textContainerInset.bottom);
//}

// 占位文字
- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    self.phLabel.text = placeholder;
    // 更新文字尺寸
    [self setNeedsLayout];
}

/// 设置圆角
- (void)setCornerRadius:(NSUInteger)cornerRadius {
    _cornerRadius = cornerRadius;
    
    self.layer.cornerRadius = cornerRadius;
}

// 字体
- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    self.phLabel.font = font;
    [self setNeedsLayout];
    
//    _oneLineHeight = [self.layoutManager usedRectForTextContainer:self.textContainer].size.height;
}

/// 最高高度
- (CGFloat)maxHeight {
    return _maxHeight;
}

#pragma mark --- 懒加载
- (UILabel *)phLabel
{
    if (!_phLabel) {
        UILabel *phLabel = [[UILabel alloc] init];
        // 文字自动换行
        phLabel.numberOfLines = 0;
        phLabel.x = 10;
        phLabel.y = 7;
        phLabel.backgroundColor = [UIColor redColor];
        //        phLabel.textColor = self.color;
        [self addSubview:phLabel];
        self.phLabel = phLabel;
    }
    
    return _phLabel;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
