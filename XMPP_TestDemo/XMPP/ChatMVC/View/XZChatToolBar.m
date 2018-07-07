//
//  XZChatToolBar.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/27.
//  Copyright © 2018年 XZ. All rights reserved.
//  聊天工具栏

#import "XZChatToolBar.h"
#import "XZKeyboardInputView.h"
#import "XZTextView.h"
#import "XZTextView.h"
#import "XZButton.h"

#define kNaviBarH       64   // 导航栏高度
#define kToolbarBtnH    35   // 顶部工具栏的按钮高度
#define kToolbarBottom  100  // 底部视图
#define kBtnSpeakLeftX  55   // 按住说话左边距
#define kBotContainerH  216  // 底部自定义键盘高度
#define DURTAION  0.25f      // 键盘显示/收起动画时间
#define kTextVTopMargin 8

@interface XZChatToolBar() // <UITextViewDelegate>
{
    BOOL _toolBarBtnTap; /// toolbarButton被点击
    CGFloat _heightOfOneLine; /// 输入框每一行文字高度
    CGFloat _heightOfToolbar; /// 当前 toolbar 高度
    NSMutableArray *_ArrToolbarBtn;
    UIButton *_btnSelectedToolbar;
}
/// 语音聊天按钮 // 35
@property (nonatomic, strong) UIButton *btnVoice;
/// 按住说话按钮,默认隐藏
@property (nonatomic, strong) UIButton *btnSpeak;
/// 发送按钮
@property (nonatomic, strong) UIButton *btnSendMsg;
/// 加号按钮
@property (nonatomic, strong) UIButton *btnContactAdd;
/// 转人工
@property (nonatomic, strong) XZButton *btnTurnArtifical;
// 被添加到的 控制器 和 父视图
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, weak) UIView *superView;
@property (nonatomic, weak) UIView *aboveView;
/// 输入框
@property (nonatomic,strong) XZTextView *textView;
/// 键盘视图
@property (nonatomic,strong) XZKeyboardInputView *keyboardInputView;
/// 顶部工具栏
@property (nonatomic,strong) UIView *topView;
@end;

@implementation XZChatToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupChatToolBar];
        [self keyboardNotification];
    }
    return self;
}

- (instancetype)initWithViewController:(UIViewController <XZChatToolBarDelegate>*)viewController aboveView:(UIView *)aboveView {

    if (self = [super init]) {
        // 保存vc和父视图
        self.viewController = viewController;
        _delegate = viewController;
        self.superView = viewController.view;
        [self.superView addSubview:self];

        WeakSelf
        if (aboveView) {
            _aboveView = aboveView;
            if (![self.superView.subviews containsObject:_aboveView]) {
                [self.superview addSubview:_aboveView];
            }

            [_aboveView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(weakSelf.mas_top);
                make.left.right.equalTo(self.superview);
                make.top.equalTo(self.superView);
            }];
        }

        // 在控制器中，自定义键盘在父视图中的位置
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(XZChatToolBarHeight));
            make.left.right.bottom.equalTo(weakSelf.superview);
        }];
        
    }
    
    return self;
}

#pragma mark --- 键盘处理
- (void)keyboardNotification {
    // 添加监听，当键盘出现时收到消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)name:UIKeyboardWillShowNotification object:nil];
    // 添加监听，当键盘退出时收到消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)name:UIKeyboardWillHideNotification object:nil];
}

// 当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    // 获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];

    int height = keyboardRect.size.height;
    
    // 隐藏底部视图
    [self makeKeyboardInputViewConstraints: NO];

    WeakSelf;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.viewController.view);
            make.bottom.equalTo(self.viewController.view).offset(-height);
            make.height.equalTo(@(XZChatToolBarHeight));
        }];
    });

    // tableView是否滚动上去
    [self aboveScroll:YES];
}

// 当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.viewController.view);
        make.height.equalTo(@(XZChatToolBarHeight));
    }];
}

#pragma mark ---- 按钮的点击事件
///// 点击 "按住 说话" ==> 变成 “松开 结束”
//- (void)pressOnSpeakButton:(UIButton *)button {
//    button.selected = !button.selected;
//}

/// UIControlEventTouchDragInside
- (void)speakerTouchDragInside {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDragInside:)]) {
        [self.delegate didDragInside: YES];
    }
}

/// UIControlEventTouchDragOutside
- (void)speakerTouchDragOutside {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDragInside:)]) {
        [self.delegate didDragInside: NO];
    }
}

/// UIControlEventTouchCancel
- (void)speakerTouchCancel {
    NSLog(@"speakerTouchCancel");
}

/// UIControlEventTouchUpOutside
- (void)speakerTouchUpOutside {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCancelRecordingVoice)]) {
        [self.delegate didCancelRecordingVoice];
    }
}

/// UIControlEventTouchDown === 开始录音
- (void)speakerTouchDown {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didStartRecordingVoice)]) {
        [self.delegate didStartRecordingVoice];
    }
}

/// UIControlEventTouchUpInside === 松开结束
- (void)speakerTouchUpInside:(UIButton *)button {
    button.selected = !button.selected;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didStopRecordingVoice)]) {
        [self.delegate didStopRecordingVoice];
    }
}

// 点击录音按钮
- (void)didClickVoiceButton:(UIButton *)button {
    
    if (button.tag == 120) { // 语音聊天按钮
        button.selected = !button.selected;
        if (button.selected) {
            self.textView.hidden = YES;
            self.btnSpeak.hidden = NO;
            // 回收键盘
            [self.textView resignFirstResponder];
        }else {
            self.textView.hidden = NO;
            self.btnSpeak.hidden = YES;
            // 成为第一响应者
            [self.textView becomeFirstResponder];
        }
        
        // 隐藏底部视图
        [self makeKeyboardInputViewConstraints: NO];
        
    }else if (button.tag == 121) { // 转人工按钮
        button.hidden = YES;
        self.btnVoice.hidden = NO;
        
        if (self.blockDidClickButton) {
            self.blockDidClickButton(button.tag);
        }
    }else if (button.tag == 122) { // 加号按钮
        button.selected = !button.selected;
        
        // 回收键盘
        [self.textView resignFirstResponder];
        
        self.keyboardInputView.hidden = button.selected ? NO : YES;
        
        // 显示输入框
        if (self.textView.hidden == YES) {
            self.textView.hidden = NO;
            self.btnSpeak.hidden = YES;
            self.btnVoice.selected = NO;
        }
        
        WeakSelf
        [weakSelf makeKeyboardInputViewConstraints:button.selected ? YES : NO];
        
    }else if (button.tag == 123)  { // 发送按钮
        if (self.blockDidClickButton) {
            self.blockDidClickButton(button.tag);
        }
    }
}

#pragma mark ---- 设置页面
- (void)setupChatToolBar { // 83 最高
    self.backgroundColor = [UIColor whiteColor];
    
    /// 顶部工具栏
    UIView *topView = [[UIView alloc] init];
    [self addSubview:topView];
    topView.backgroundColor = [UIColor whiteColor];
    self.topView = topView;
    
    /// 顶部线
    UIView *line = [[UIView alloc] init];
    line.frame = CGRectMake(0, 0, kScreenWidth, 1);
    [topView addSubview:line];
    line.backgroundColor = XZColor(191, 191, 191);
    
    /// 语音聊天按钮 // 35
    UIButton *btnVoice = [UIButton buttonWithType:UIButtonTypeCustom];
    [topView addSubview:btnVoice];
    self.btnVoice = btnVoice;
    btnVoice.hidden = YES;
    [btnVoice setImage:[UIImage imageNamed:@"toolbar_voice"] forState:UIControlStateNormal];
    [btnVoice setImage:[UIImage imageNamed:@"toolbar_input_info"] forState:UIControlStateSelected];
    [btnVoice addTarget:self action:@selector(didClickVoiceButton:) forControlEvents:UIControlEventTouchUpInside];
    btnVoice.tag = 120;
    
    /// 转人工
    XZButton *btnTurnArtifical = [XZButton buttonWithType:UIButtonTypeCustom];
    [topView addSubview:btnTurnArtifical];
    self.btnTurnArtifical = btnTurnArtifical;
    btnTurnArtifical.buttonsType = XZButtonTypePicAbove;
    [btnTurnArtifical setImage:[UIImage imageNamed:@"toolbar_turnToArtificial"] forState:UIControlStateNormal];
    [btnTurnArtifical setTitle:@"转人工" forState:UIControlStateNormal];
    [btnTurnArtifical setTitleColor:XZColor(51, 51, 51) forState:UIControlStateNormal];
    [btnTurnArtifical.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [btnTurnArtifical addTarget:self action:@selector(didClickVoiceButton:) forControlEvents:UIControlEventTouchUpInside];
//    btnTurnArtifical.backgroundColor = [UIColor redColor];
    [btnTurnArtifical.titleLabel setTextAlignment:NSTextAlignmentCenter];
    btnTurnArtifical.tag = 121;
    
    /// 按住说话按钮,默认隐藏
    UIButton *btnSpeak = [UIButton buttonWithType:UIButtonTypeCustom];
    [topView addSubview:btnSpeak];
    self.btnSpeak = btnSpeak;
    [btnSpeak setTitle:@"按住 说话" forState:UIControlStateNormal];
    [btnSpeak setTitle:@"松开 结束" forState:UIControlStateHighlighted];
    [btnSpeak addTarget:self action:@selector(speakerTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [btnSpeak addTarget:self action:@selector(speakerTouchDown) forControlEvents:UIControlEventTouchDown];
    [btnSpeak addTarget:self action:@selector(speakerTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [btnSpeak addTarget:self action:@selector(speakerTouchCancel) forControlEvents:UIControlEventTouchCancel];
    [btnSpeak addTarget:self action:@selector(speakerTouchDragOutside) forControlEvents:UIControlEventTouchDragOutside];
    [btnSpeak addTarget:self action:@selector(speakerTouchDragInside) forControlEvents:UIControlEventTouchDragInside];
    [btnSpeak setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnSpeak.hidden = YES;
    btnSpeak.layer.masksToBounds = YES;
    btnSpeak.layer.cornerRadius = 15;
    btnSpeak.layer.borderWidth = 1.0f;
    btnSpeak.layer.borderColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1.0].CGColor;
    [btnSpeak.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    
    UIImage *image = [UIImage imageNamed:@"compose_emotion_table_left_normal"];
    image = [image xz_resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, image.size.width - 1)];
    [btnSpeak setBackgroundImage:image forState:UIControlStateNormal];
    
    UIImage *imageSelected = [UIImage imageNamed:@"compose_emotion_table_left_selected"];
    imageSelected = [imageSelected xz_resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, imageSelected.size.width - 1)];
    [btnSpeak setBackgroundImage:imageSelected forState:UIControlStateHighlighted];
    
    /// 加号按钮
    UIButton *btnContactAdd = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnContactAdd addTarget:self action:@selector(didClickVoiceButton:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:btnContactAdd];
    self.btnContactAdd = btnContactAdd;
    btnContactAdd.tag = 122;
    [btnContactAdd setImage:[UIImage imageNamed:@"toolbar_add_background"] forState:UIControlStateNormal];
    [btnContactAdd setImage:[UIImage imageNamed:@"toolbar_add_background_selected"] forState:UIControlStateSelected];
    
    /// 发送按钮
    UIButton *btnSendMsg = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSendMsg addTarget:self action:@selector(didClickVoiceButton:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:btnSendMsg];
    self.btnSendMsg = btnSendMsg;
    btnSendMsg.hidden = YES;
    btnSendMsg.tag = 123;
    btnSendMsg.backgroundColor = XZColor(1, 89, 213);
    btnSendMsg.layer.masksToBounds = YES;
    btnSendMsg.layer.cornerRadius = 10;
    [btnSendMsg setTitle:@"发 送" forState:UIControlStateNormal];
    [btnSendMsg.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    
    /// 输入框
    _textView = [[XZTextView alloc] init];
    _textView.font = [UIFont systemFontOfSize:15];
    _textView.placeholder = @"请简短的描述你的问题";
    _textView.cornerRadius = 17;
    _textView.backgroundColor = XZColor(242, 242, 242);
    WeakSelf;
    [_textView textValueDidChanged:^(NSString *text, CGFloat textHeight) {
//        CGRect frame = _inputView.frame;
//        frame.size.height = textHeight;
//        _inputView.frame = frame;
        [weakSelf.textView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(textHeight));
        }];

        CGFloat H = XZChatToolBarHeight - kToolbarBtnH + textHeight;
        
        [weakSelf.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(H));
        }];
        
        [weakSelf mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(H));
        }];
        
        // 用户输入值时显示“发送”,没有值显示“+”
        self.btnSendMsg.hidden = text.length ? NO:YES;
        self.btnContactAdd.hidden = text.length ? YES:NO;
    }];
    
    // 设置文本框最大行数
    _textView.maxNumberOfLines = 4;
    [topView addSubview:_textView];
    
    [self setupConstraints:topView];
}

/// 设置布局
- (void)setupConstraints:(UIView *)topView {
    /// 底部视图 WithFrame:CGRectMake(0, 0, kScreenWidth, XZChatToolBarHeight)
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.bottom.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@(XZChatToolBarHeight));
    }];
    
    CGFloat bottom = (XZChatToolBarHeight - kToolbarBtnH) / 2.0;
    
    /// 语音聊天
    [self.btnVoice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topView).offset(15);
        make.bottom.equalTo(topView).offset(-bottom);
        make.size.equalTo(@(kToolbarBtnH));
    }];
    
    /// 转人工
    [self.btnTurnArtifical mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topView).offset(5);
        make.bottom.equalTo(topView).offset(-5);
        make.size.equalTo(@45);
    }];
    
    CGFloat width = kScreenWidth - kBtnSpeakLeftX - 10 - 50;
    /// 按住说话
    [self.btnSpeak mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topView).offset(60);
        make.width.equalTo(@(width));
        make.centerY.equalTo(topView);
        make.height.equalTo(@(kToolbarBtnH));
    }];
    
    /// 输入文字 WithFrame:CGRectMake(kBtnSpeakLeftX, bottom, width, kToolbarBtnH)
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topView).offset(kBtnSpeakLeftX);
        make.centerY.equalTo(topView);
        make.width.equalTo(@(width));
        make.height.equalTo(@(kToolbarBtnH));
    }];
    
    /// 加号
    [self.btnContactAdd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(topView).offset(-10);
        make.centerY.equalTo(self.btnVoice);
        make.size.equalTo(@(kToolbarBtnH));
    }];
    
    /// 发送消息
    [self.btnSendMsg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(topView).offset(-10);
        make.bottom.equalTo(topView).offset(-bottom);
        make.height.equalTo(@(kToolbarBtnH));
        make.width.equalTo(@45);
    }];
}

/// 设置底部视图的布局 isBottom:YES 显示，NO 不显示
- (void)makeKeyboardInputViewConstraints:(BOOL)isBottom {
    
    if (isBottom) { // 显示工具栏底部视图
        [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.height.equalTo(@(XZChatToolBarHeight));
            make.right.equalTo(self);
            make.bottom.equalTo(self).offset(-kToolbarBottom);
        }];
        [self.keyboardInputView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.top.equalTo(self.topView.mas_bottom);
            make.height.equalTo(@(kToolbarBottom));
        }];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.viewController.view);
            make.height.equalTo(@(XZChatToolBarHeight + kToolbarBottom));
        }];
        
    }else { // 隐藏工具栏底部视图
        [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.bottom.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(@(XZChatToolBarHeight));
        }];
        [self.keyboardInputView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.bottom.equalTo(self);
            make.height.equalTo(@0);
        }];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.viewController.view);
            make.height.equalTo(@(XZChatToolBarHeight));
        }];
        // 将加号选中状态还原
        self.btnContactAdd.selected = NO;
    }
    
}

// tableView是否滚动上去
- (void)aboveScroll:(BOOL)isScroll {
    if (_aboveView && [_aboveView isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *) _aboveView;
        
        CGPoint off = scrollView.contentOffset;
        off.y = scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom;
        [scrollView setContentOffset:off animated:YES];
//        if (isScroll) {
//            [self.aboveView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.bottom.equalTo(self.mas_top);
//            }];
//        }else{
//            [self.aboveView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.bottom.equalTo(self.viewController.view);
//            }];
//        }
        
    }
}

#pragma mark --- 懒加载
- (XZKeyboardInputView *)keyboardInputView {
    if (!_keyboardInputView) {
        _keyboardInputView = [[XZKeyboardInputView alloc] init];
        _keyboardInputView.hidden = YES;
        [self addSubview:_keyboardInputView];
    }
    return _keyboardInputView;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
