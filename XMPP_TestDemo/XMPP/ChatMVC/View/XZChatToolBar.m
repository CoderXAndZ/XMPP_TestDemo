//
//  XZChatToolBar.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/27.
//  Copyright © 2018年 XZ. All rights reserved.
//  聊天工具栏

#import "XZChatToolBar.h"
#import "XZTextView.h"
//#import "CMInputView.h"

#define kNaviBarH       64   // 导航栏高度
#define kToolbarBtnH    35   // 顶部工具栏的按钮高度
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
/// 表情按钮
@property (nonatomic, strong) UIButton *btnEmoticon;
/// 加号按钮
@property (nonatomic, strong) UIButton *btnContactAdd;
/// 输入框
@property (nonatomic, strong) XZTextView *textView;

// 被添加到的 控制器 和 父视图
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, weak) UIView *superView;
@property (nonatomic, weak) UIView *aboveView;
/// 最初设置高度
@property (nonatomic, assign) CGFloat originalHeight;
///// 距离底部
//@property (nonatomic, assign) CGFloat offset;

//@property (nonatomic,strong) CMInputView *inputView;
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
//                make.height.equalTo(@(kScreenWidth-XZChatToolBarHeight-kNaviBarH));
                make.top.equalTo(self.superView);
            }];
        }

        // 在控制器中，自定义键盘在父视图中的位置
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.bottom.equalTo(weakSelf.superview).offset(kBotContainerH);
            make.height.equalTo(@(XZChatToolBarHeight));
            make.left.right.bottom.equalTo(weakSelf.superview);
        }];
        
    }
    
    return self;
}

//#pragma mark ---- UITextViewDelegate
//- (void)textViewDidChange:(XZTextView *)textView {
//    /// 内容高度
//    CGFloat heightContent =  textView.contentSize.height;
//
//    if (heightContent > textView.maxHeight) {
//        heightContent = textView.maxHeight;
//    }
//
//    ///
//    CGFloat height = XZChatToolBarHeight - 35 + heightContent;
//
//    NSLog(@"\ntextView.contentSize.height:%f ===== height：%f",heightContent,height);
//
////    CGFloat width = kScreenWidth - (35 * 3) - 20 - 5;
//
////    textView.height = heightContent;
//
////    [textView mas_remakeConstraints:^(MASConstraintMaker *make) {
////        make.left.equalTo(self.btnVoice.mas_right).offset(5);
////        make.width.equalTo(@(width));
////        make.centerY.equalTo(self);
////        make.height.equalTo(@(heightContent));
////    }];
////
////    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
////        make.height.equalTo(@(height));
////        make.left.right.equalTo(self.superview);
////        make.bottom.equalTo(self.superview).offset(-_offset);
////    }];
//
//    [textView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.equalTo(@(heightContent));
//    }];
//
//    [self mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.equalTo(@(height));
//    }];
//
////    [self layoutIfNeeded];
//}

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

    WeakSelf;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.viewController.view);
            make.bottom.equalTo(self.viewController.view).offset(-height);
            make.height.equalTo(@(XZChatToolBarHeight));
        }];
    });

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
        
    }else if (button.tag == 122) { // 加号按钮
        
    }else if (button.tag == 123)  { // 表情按钮
        
    }
}

#pragma mark ---- 设置页面
- (void)setupChatToolBar { // 83 最高
    self.backgroundColor = [UIColor whiteColor];
    
    /// 顶部线
    UIView *line = [[UIView alloc] init];
    line.frame = CGRectMake(0, 0, kScreenWidth, 1);
    [self addSubview:line];
    line.backgroundColor = XZColor(191, 191, 191);
    
    /// 语音聊天按钮 // 35
    UIButton *btnVoice = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:btnVoice];
    self.btnVoice = btnVoice;
    [btnVoice setImage:[UIImage imageNamed:@"compose_toolbar_voice"] forState:UIControlStateNormal];
    [btnVoice setImage:[UIImage imageNamed:@"compose_toolbar_voice"] forState:UIControlStateHighlighted];
    //    btnVoice.exclusiveTouch = YES;
    [btnVoice addTarget:self action:@selector(didClickVoiceButton:) forControlEvents:UIControlEventTouchUpInside];
    btnVoice.tag = 120;
    
    /// 按住说话按钮,默认隐藏
    UIButton *btnSpeak = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:btnSpeak];
    self.btnSpeak = btnSpeak;
    [btnSpeak setTitle:@"按住 说话" forState:UIControlStateNormal];
    [btnSpeak setTitle:@"松开 结束" forState:UIControlStateHighlighted];
    //    btnSpeak.exclusiveTouch = YES;
    [btnSpeak addTarget:self action:@selector(speakerTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [btnSpeak addTarget:self action:@selector(speakerTouchDown) forControlEvents:UIControlEventTouchDown];
    [btnSpeak addTarget:self action:@selector(speakerTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [btnSpeak addTarget:self action:@selector(speakerTouchCancel) forControlEvents:UIControlEventTouchCancel];
    [btnSpeak addTarget:self action:@selector(speakerTouchDragOutside) forControlEvents:UIControlEventTouchDragOutside];
    [btnSpeak addTarget:self action:@selector(speakerTouchDragInside) forControlEvents:UIControlEventTouchDragInside];
    [btnSpeak setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //    btnSpeak.hidden = YES;
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
    //    [btnSpeak addTarget:self action:@selector(pressOnSpeakButton:) forControlEvents:UIControlEventTouchUpInside];
    
    /// 加号按钮
    UIButton *btnContactAdd = [UIButton buttonWithType:UIButtonTypeCustom];
    //    btnContactAdd.exclusiveTouch = YES;
    [btnContactAdd addTarget:self action:@selector(didClickVoiceButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnContactAdd];
    self.btnContactAdd = btnContactAdd;
    btnContactAdd.tag = 122;
    [btnContactAdd setImage:[UIImage imageNamed:@"message_add_background"] forState:UIControlStateNormal];
    [btnContactAdd setImage:[UIImage imageNamed:@"message_add_background_highlighted"] forState:UIControlStateHighlighted];
    
    /// 表情按钮
    UIButton *btnEmoticon = [UIButton buttonWithType:UIButtonTypeCustom];
    //    btnEmoticon.exclusiveTouch = YES;
    [btnEmoticon addTarget:self action:@selector(didClickVoiceButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnEmoticon];
    self.btnEmoticon = btnEmoticon;
    btnEmoticon.tag = 123;
    [btnEmoticon setImage:[UIImage imageNamed:@"compose_emoticonbutton_background"] forState:UIControlStateNormal];
    [btnEmoticon setImage:[UIImage imageNamed:@"compose_emoticonbutton_background_highlighted"] forState:UIControlStateHighlighted];
    
    CGFloat width = kScreenWidth - (35 * 3) - 20 - 5;
    
    /// 输入框
    XZTextView *textView = [[XZTextView alloc] initWithFrame:CGRectMake(45, 14.5, width, 35)];
    [self addSubview:textView];
    self.textView = textView;
//    textView.delegate = self;
    textView.placeholder = @"请简短的描述你的问题";
    textView.font = [UIFont systemFontOfSize:15.0f];
    textView.layer.masksToBounds = YES;
    textView.layer.cornerRadius = 15;
    textView.layer.borderWidth = 1.0f;
    textView.layer.borderColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1.0].CGColor;
//    textView.returnKeyType = UIReturnKeySend;
    textView.numberOfLines = 4;
    
    WeakSelf;
    
    textView.blockChangeHeight = ^(CGFloat height, NSString *text) {

        CGFloat H = XZChatToolBarHeight - 35 + height;

        CGRect frame = weakSelf.textView.frame;
        frame.size.height = height;
        weakSelf.textView.frame = frame;

//        [weakSelf.textView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.equalTo(@(height));
//        }];

        [weakSelf mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(H));
        }];
    };
    
//    _inputView = [[CMInputView alloc]initWithFrame:CGRectMake(45, 14.5, width, 35)];
//
//    _inputView.font = [UIFont systemFontOfSize:15];
//    _inputView.placeholder = @"CrabMan的测试文字";
//
//    _inputView.cornerRadius = 17;
//    _inputView.placeholderColor = [UIColor redColor];
//    // 设置文本框最大行数
//    [_inputView textValueDidChanged:^(NSString *text, CGFloat textHeight) {
//        CGRect frame = _inputView.frame;
//        frame.size.height = textHeight;
//        _inputView.frame = frame;
//
//        CGFloat H = XZChatToolBarHeight - 35 + textHeight;
//
//        [weakSelf mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.equalTo(@(H));
//        }];
//    }];
//
//    _inputView.maxNumberOfLines = 4;
//    [self addSubview:_inputView];
 
    btnSpeak.hidden = YES;
    
    [self setupConstraints];
}

/// 设置布局
- (void)setupConstraints {
    
    [self.btnVoice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(5);
        make.bottom.equalTo(self).offset(-14.5);
        make.size.equalTo(@35);
    }];
    
    CGFloat width = kScreenWidth - (35 * 3) - 20 - 5;
    
    [self.btnSpeak mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.btnVoice.mas_right).offset(5);
        make.width.equalTo(@(width));
        make.centerY.equalTo(self);
        make.height.equalTo(@35);
    }];
    
    [self.btnContactAdd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-5);
        make.centerY.equalTo(self.btnVoice);
        make.size.equalTo(self.btnVoice);
    }];
    
    [self.btnEmoticon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.btnContactAdd.mas_left).offset(-5);
        make.centerY.equalTo(self);
        make.size.equalTo(self.btnVoice);
    }];
    
//    /// 输入框
//    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.btnVoice.mas_right).offset(5);
//        make.width.equalTo(@(width));
//        make.centerY.equalTo(self);
//        make.height.equalTo(@35);
//    }];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
