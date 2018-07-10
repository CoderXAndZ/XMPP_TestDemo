//
//  XZToolBarTextView.h
//  XZFenLeiJieMian
//
//  Created by admin on 16/5/5.
//  Copyright © 2016年 yuyang. All rights reserved.
//

#import "XZToolBarTextView.h"
#import "UIView+Extension.h"

@interface XZToolBarTextView ()
{
    CGFloat _text_height;
}
/// 占位字符
@property (nonatomic, weak) UILabel *placeholderView;
/// 文字最大高度
@property (nonatomic, assign) NSInteger maxTextH;

@end

@implementation XZToolBarTextView

- (void)textValueDidChanged:(textHeightChangedBlock)block {
    
    _textChangedBlock = block;
}

- (void)textDidChange
{
    self.placeholderView.hidden = self.hasText;
    
    CGFloat height = ceilf([self sizeThatFits:CGSizeMake(self.bounds.size.width, MAXFLOAT)].height);
    
    // 当高度大于最大高度时，需要滚动
    self.scrollEnabled = height > _maxTextH && _maxTextH > 0;

    // 当不可以滚动（即 <= 最大高度）时，传值改变textView高度
    if (_textChangedBlock) {
        
        if (height > _maxTextH) {
            height = _maxTextH;
        }
        
        _textChangedBlock(self.text,height);
        
        [self.superview layoutIfNeeded];
    }
    
    _text_height = height;
    
    Log(@"_text_height ====== %.2f",_text_height);
}

- (CGFloat)text_height {
    if (_text_height) {
        return _text_height;
    }else {
        return 35;
    }
}

/// 设置行数
- (void)setMaxNumberOfLines:(NSUInteger)maxNumberOfLines
{
    _maxNumberOfLines = maxNumberOfLines;
    
    /**
     *  根据最大的行数计算textView的最大高度
     *  计算最大高度 = (每行高度 * 总行数 + 文字上下间距)
     */
//    _maxTextH = ceil(self.font.lineHeight * maxNumberOfLines);
    _maxTextH = ceil(self.font.lineHeight * maxNumberOfLines + self.textContainerInset.top + self.textContainerInset.bottom);
}

/// 设置圆角
- (void)setCornerRadius:(NSUInteger)cornerRadius
{
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
}

/// 设置placeholderView中的textColor
- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    
    self.placeholderView.textColor = placeholderColor;
}

/// 设置placeholderView中的text
- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    
    self.placeholderView.text = placeholder;
    [self.placeholderView sizeToFit];
}

/// 设置placeholderView中的Font
- (void)setPlaceholderFont:(UIFont *)placeholderFont {

    _placeholderFont = placeholderFont;
    
    self.placeholderView.font = placeholderFont;
}

#pragma mark ---- 设置页面
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setupTextView];
    }
    return self;
}

- (void)setupTextView
{
    self.scrollEnabled = NO;
    self.scrollsToTop = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.enablesReturnKeyAutomatically = YES;
    self.layer.borderWidth = 1;
    self.layer.borderColor = XZColor(222, 222, 222).CGColor;
    self.textContainerInset = UIEdgeInsetsMake(8, 2, 8, 0);
    
    // 实时监听textView值得改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self];
}

#pragma mark ---- 懒加载
- (UILabel *)placeholderView
{
    if (!_placeholderView ) {
        UILabel *placeholderView = [[UILabel alloc] initWithFrame:self.bounds];
        _placeholderView = placeholderView;
        _placeholderView.fm_x = 8;
        _placeholderView.fm_y = 7;
        _placeholderView.font =  self.font;
        _placeholderView.textColor = [UIColor lightGrayColor];
        _placeholderView.backgroundColor = [UIColor clearColor];
        [self addSubview:placeholderView];
    }
    return _placeholderView;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
