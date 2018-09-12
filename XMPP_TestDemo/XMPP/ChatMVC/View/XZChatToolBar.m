//
//  XZChatToolBar.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/27.
//  Copyright © 2018年 XZ. All rights reserved.
//  聊天工具栏

#import "XZChatToolBar.h"
#import "XZKeyboardInputView.h"
#import "XZToolBarTextView.h"
#import "XZButton.h"
#import "UIImage+XZChat.h"
#import "XZMacroDefinition.h"
#import "XZVoiceProgress.h" // 说话音量显示
#import "UIView+Extension.h"
#import "XZVoiceRecorderManager.h" // 录音
#import "XZFileTools.h" // 文件选择
#import "XZMediaModel.h"

#define kToolbarBtnH    35   // 顶部工具栏的按钮高度
#define kToolbarBottom  100  // 底部视图
#define kBtnSpeakLeftX  55   // 按住说话左边距

#define kFakeTimerDuration       1
#define kMaxRecordDuration       60  // 最长录音时长
#define kRemainCountingDuration  10  // 剩余多少秒开始倒计时

@interface XZChatToolBar()
/// 语音聊天按钮
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
/// 输入框
@property (nonatomic, strong) XZToolBarTextView *textView;
/// 键盘视图
@property (nonatomic, strong) XZKeyboardInputView *keyboardInputView;
/// 顶部工具栏
@property (nonatomic, strong) UIView *topView;
/// 用户输入文字
@property (nonatomic, strong) NSString *userInput_text;
/// 当前文字高度
@property (nonatomic, assign) CGFloat currentTextHeight;
/// 60s倒计时
@property (nonatomic, strong) NSTimer *timerReduce;
/// 当前状态
@property (nonatomic, assign) XZVoiceRecordState currentState;

// 取消录制
@property (nonatomic, assign) BOOL canceled;
// 结束录制
@property (nonatomic, assign) BOOL endedRecord;
// 倒计时
@property (nonatomic, assign) int totoalSecond;
/// 录音提示页面
@property (nonatomic, strong) XZVoiceProgress *voiceProgress;
/// 按住说话 normalImage
@property (nonatomic, strong) UIImage *image;
/// 按住说话 highlightedImage
@property (nonatomic, strong) UIImage *highlightedImage;
///
@property (nonatomic, assign) CGFloat progressValue;
@end

@implementation XZChatToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupChatToolBar];
        [self keyboardNotification];
        _totoalSecond = kMaxRecordDuration;
        self.canceled = NO;
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
        
        [self.superView addSubview: self.voiceProgress];
        
        FMWeakSelf
        // 在控制器中，自定义键盘在父视图中的位置
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(XZChatToolBarHeight));
            make.left.right.bottom.equalTo(weakSelf.superview);
        }];
    }
    
    return self;
}

#pragma mark ---- 按钮的点击事件
/// UIControlEventTouchDown === 开始录音
- (void)speakerTouchDown {
    Log(@"开始录音 ============ speakerTouchDown");
    // 停止当前计时器
    [self stopTimer];
    
    self.currentState = XZVoiceRecordState_Recording;
    [self updateButtonState: self.currentState];
    
    FMWeakSelf;
    // 开始录音
    [[XZVoiceRecorderManager sharedManager] startRecordWithFileName:[XZFileTools currentRecordFileName] completion:^(NSError *error) {
        Log(@"===========初始化完时间计时器");
        if (error) {
            if (error.code != 12) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"录音失败，请重新录制" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alert show];
            }
        }
        // 开启时间计时器
        [weakSelf timerReduce];
    }];
    
    // 录音过程中被电话中断
    [XZVoiceRecorderManager sharedManager].audioRecorderInterrupted = ^(NSString *tips) {
         // 停止计时器
         [weakSelf stopTimer];
         weakSelf.currentState = XZVoiceRecordState_Normal;
         [weakSelf updateButtonState: weakSelf.currentState];
     };
}

/// 自定义 button 的 UIControlEventTouchDragInside 事件
- (void)touchDragInside:(UIButton *)button withEvent:(UIEvent *)event {
    
    Log(@"拖拽 ======= %d",_endedRecord);
    if (_endedRecord) {
        return;
    }
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:self.btnSpeak];
    
    // 判断当前触摸点是否在 button 的 bounds 范围内
    BOOL isInside = CGRectContainsPoint(self.btnSpeak.bounds, point);
    
    if (isInside) { // 按钮内
        self.canceled = NO;
        
        if ([self shouldShowCounting]) { // 显示倒计时
            _currentState = XZVoiceRecordState_RecordCounting;
            
        }else {
           _currentState = XZVoiceRecordState_Recording;
        }
        
    }else { // 按钮外
        _currentState = XZVoiceRecordState_ReleaseToCancel;
        self.canceled = YES;
    }
    
    [self updateButtonState: _currentState];
}

/// UIControlEventTouchUpOutside
- (void)speakerTouchUpOutside {
    
    if (self.endedRecord) {// 60s结束录制
        return;
    }
    Log(@"取消录制 ============ speakerTouchUpOutside");
    
    // 取消
    [self stopTimer];
    
    [[XZVoiceRecorderManager sharedManager] cancelCurrentRecording];
    [[XZVoiceRecorderManager sharedManager] removeCurrentRecordFile];
    
    _currentState = XZVoiceRecordState_Normal;
    [self updateButtonState: _currentState];
}

/// UIControlEventTouchUpInside === 松开结束
- (void)speakerTouchUpInside:(UIButton *)button {
    
    if (self.endedRecord) {
        return;
    }
    self.endedRecord = YES;
    
    Log(@"完成录制 ===== 松开结束 ====== speakerTouchUpInside");
    [self stopRecordAndCallback];
}

/// 停止录制并回调
- (void)stopRecordAndCallback {
    [self stopTimer];
    if (!self.canceled) { // 不是取消录制调用，是倒计时结束调用
        FMWeakSelf;
        [[XZVoiceRecorderManager sharedManager] stopRecordingWithCompletion:^(NSString *recordPath) {
                Log(@"recordPath ==== %@",recordPath);
                if (recordPath) {
                    // 录音完成
                    XZMediaModel *modelVioce = [[XZMediaModel alloc] init];
                    // 赋值
                    modelVioce.mediaName = [XZVoiceRecorderManager sharedManager].currentFileName;
                    modelVioce.mediaType = 0;
                    modelVioce.mediaPath = recordPath;
                    NSString *wavPath = [recordPath stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"];
                    NSTimeInterval time = [XZFileTools durationWithVoiceURL:[NSURL fileURLWithPath:wavPath]];
                    modelVioce.mediaDuration = time;
                    // 录制时间大于1秒才进行发送
                    if (modelVioce.mediaDuration > 1.0) {
                        if (self.delegate && [self.delegate respondsToSelector:@selector(didStopRecordingVoice:)]) {
                            [self.delegate didStopRecordingVoice:modelVioce];
                        }
                    }else { // 录制时间太短
                        [XZVoiceRecorderManager sharedManager].isNeedCancelRecording = YES;
                        [[XZVoiceRecorderManager sharedManager] removeCurrentRecordFile];
                        weakSelf.currentState = XZVoiceRecordState_RecordTooShort;
                        [weakSelf updateButtonState: weakSelf.currentState];
                    }
                    Log(@"回调");
                }
        }];
        
        self.currentState = XZVoiceRecordState_Normal;
        [self updateButtonState: _currentState];
    }else { // 取消调用结束
        [[XZVoiceRecorderManager sharedManager] cancelCurrentRecording];
    }
}

/// 开启时间计时器
- (void)timerReduceOneSecond {

    BOOL showCounting = [self shouldShowCounting];
    
    Log(@"开启时间计时器 === %d ---- 开始倒计时:%@ ====== 当前状态: %ld",_totoalSecond, showCounting ? @"YES":@"NO",(long)_currentState);
    
    if (_totoalSecond == 0) { // 60秒倒计时结束,结束录音
        self.endedRecord = YES; // 结束录制
        [self setBtnSpeakHighlighted: 3];
        self.voiceProgress.isHidden = YES;
        // 停止时间计时器
        [self stopTimer];
        // 结束录音,回调录音结果
        [self stopRecordAndCallback];
        return;
    }else if (showCounting) { // 倒计时

        self.currentState = XZVoiceRecordState_RecordCounting;
        self.voiceProgress.time = [NSString stringWithFormat:@"%d",_totoalSecond];
        
        if (self.canceled) { // 当前拖拽到 按钮 外
            self.voiceProgress.voiceRecordState = XZVoiceRecordState_ReleaseToCancel;
        }else {
            self.voiceProgress.voiceRecordState = _currentState;
        }
    }else { // 正常显示声音
        if (_currentState != XZVoiceRecordState_ReleaseToCancel) {
            self.voiceProgress.progress = [[XZVoiceRecorderManager sharedManager] powerChanged];
        }
    }
     _totoalSecond--;
}

/// 关闭计时器
- (void)stopTimer {
    if (_timerReduce) {
        [_timerReduce invalidate];
        _timerReduce = nil;
    }
    _totoalSecond = kMaxRecordDuration;
    self.canceled = NO;
    self.endedRecord = NO;
}

/// 是否倒计时
- (BOOL)shouldShowCounting {
    
    if (_totoalSecond <= kRemainCountingDuration && _totoalSecond > 0 && self.currentState != XZVoiceRecordState_ReleaseToCancel) {
        
        return YES;
    }
    return NO;
}

// 更新按钮状态
- (void)updateButtonState:(XZVoiceRecordState)state {
    Log(@"updateButtonState: === %ld",(long)state);
    if (state == XZVoiceRecordState_Normal) {
        [self setBtnSpeakHighlighted: 2];
        self.voiceProgress.isHidden = YES;
    }else if (state == XZVoiceRecordState_Recording) { // 正在录音
        self.voiceProgress.isHidden = NO;
        self.voiceProgress.voiceRecordState = state;
        [self setBtnSpeakHighlighted: 1];
    }else if (state == XZVoiceRecordState_ReleaseToCancel) { // 取消发送
        [self setBtnSpeakHighlighted: 1];
        self.voiceProgress.isHidden = NO;
        self.voiceProgress.voiceRecordState = state;
    }else if (state == XZVoiceRecordState_RecordCounting) { // 倒计时
        [self setBtnSpeakHighlighted: 1];
        self.voiceProgress.isHidden = NO;
        
        self.voiceProgress.time = [NSString stringWithFormat:@"%d",_totoalSecond];
        
        self.voiceProgress.voiceRecordState = state;
    }else if (state == XZVoiceRecordState_RecordTooShort) { // 时间太短
        
        self.voiceProgress.isHidden = NO;
        self.voiceProgress.voiceRecordState = state;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.voiceProgress.isHidden = YES;
        });
    }
}

/// 设置button的高亮 === YES 高亮 NO 不高亮
- (void)setBtnSpeakHighlighted:(int)value {
    if (value == 1) { // 1 长按状态
        [self.btnSpeak setBackgroundImage:self.highlightedImage forState:UIControlStateNormal];
        [self.btnSpeak setTitle:@"松开 结束" forState:UIControlStateNormal];
    }else if (value == 2) { // 2 正常状态
        [self.btnSpeak setBackgroundImage:self.image forState:UIControlStateNormal];
        [self.btnSpeak setTitle:@"按住 说话" forState:UIControlStateNormal];
    }else { // 3 高亮状态
        [self.btnSpeak setBackgroundImage:self.image forState: UIControlStateHighlighted];
        [self.btnSpeak setTitle:@"按住 说话" forState: UIControlStateHighlighted];
    }
}

// 点击录音按钮
- (void)didClickVoiceButton:(UIButton *)button {
    if (button.tag == 120) { // 语音聊天按钮
        button.selected = !button.selected;
        if (button.selected) {// 语音
            // 回收键盘
            [self.textView resignFirstResponder];
            self.textView.hidden = YES;
            self.btnSpeak.hidden = NO;
           
            // 隐藏”发送“按钮
            if (self.btnSendMsg.hidden == NO) {
                self.btnSendMsg.hidden = YES;
                self.btnContactAdd.hidden = NO;
            }
        }else { // 输入文字
            self.textView.hidden = NO;
            self.btnSpeak.hidden = YES;
            // 成为第一响应者
            [self.textView becomeFirstResponder];
            
            if (self.textView.text) {
                self.btnSendMsg.hidden = NO;
                self.btnContactAdd.hidden = YES;
            }
        }
        
        // 隐藏底部视图
        [self makeKeyboardInputViewConstraints: NO];
    }else if (button.tag == 121) { // 转人工按钮
        if (self.blockDidClickButton) {
            self.blockDidClickButton(button.tag,@"");
        }
        
    }else if (button.tag == 122) { // 加号按钮
        button.selected = !button.selected;
        
        // 回收键盘
        [self.textView resignFirstResponder];
        
        // 显示输入框
        if (self.textView.hidden == YES) {
            self.textView.hidden = NO;
            self.btnSpeak.hidden = YES;
            self.btnVoice.selected = NO;
        }
        [self makeKeyboardInputViewConstraints:button.selected ? YES : NO];
        
    }else if (button.tag == 123)  { // 发送按钮
        if (self.blockDidClickButton) {
            self.blockDidClickButton(button.tag,self.userInput_text);
        }
        // 清空输入框
        self.textView.text = @"";
        // 添加输入框通知
        [[NSNotificationCenter defaultCenter] postNotificationName: UITextViewTextDidChangeNotification object:self.textView];
        self.userInput_text = @"";
    }
}

// 转人工成功修改
- (void)setTransferSuccessed:(BOOL)transferSuccessed {
    _transferSuccessed = transferSuccessed;
    
    if (transferSuccessed) { // 成功
        self.btnTurnArtifical.hidden = YES;
        self.btnVoice.hidden = NO;
        // 设置是跟机器人聊天还是跟客服聊天
        self.keyboardInputView.isRobot = NO;
    }else { // 失败
        self.btnTurnArtifical.hidden = NO;
        self.btnVoice.hidden = YES;
        // 设置是跟机器人聊天还是跟客服聊天
        self.keyboardInputView.isRobot = YES;
    }
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
    
    FMWeakSelf;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(weakSelf.viewController.view);
            make.bottom.equalTo(weakSelf.viewController.view).offset(-height);
            make.height.equalTo(@(XZChatToolBarHeight));
        }];
    });
    
    if (self.blockKeyboardWillChange) {
        self.blockKeyboardWillChange(aNotification);
    }
}

// 当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    FMWeakSelf;
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(weakSelf.viewController.view);
        make.height.equalTo(@(XZChatToolBarHeight));
    }];
    
    if (self.blockKeyboardWillChange) {
        self.blockKeyboardWillChange(aNotification);
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
    line.frame = CGRectMake(0, 0, KProjectScreenWidth, 1);
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
    btnTurnArtifical.tag = 121;
    
    /// 按住说话按钮,默认隐藏
    UIButton *btnSpeak = [UIButton buttonWithType:UIButtonTypeCustom];
    [topView addSubview:btnSpeak];
    self.btnSpeak = btnSpeak;
    [btnSpeak setTitle:@"按住 说话" forState:UIControlStateNormal];
    // 开始录音
    [btnSpeak addTarget:self action:@selector(speakerTouchDown) forControlEvents:UIControlEventTouchDown];
    // 结束录音
    [btnSpeak addTarget:self action:@selector(speakerTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    // 结束录音
    [btnSpeak addTarget:self action:@selector(speakerTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    // 录制过程中拖拽
    [btnSpeak addTarget:self action:@selector(touchDragInside:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
    [btnSpeak addTarget:self action:@selector(touchDragInside:withEvent:) forControlEvents:UIControlEventTouchDragInside];

    [btnSpeak setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnSpeak.hidden = YES;
    btnSpeak.layer.masksToBounds = YES;
    btnSpeak.layer.cornerRadius = 15;
    btnSpeak.layer.borderWidth = 1.0f;
    btnSpeak.layer.borderColor = XZColor(222, 222, 222).CGColor;
    [btnSpeak.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [btnSpeak setBackgroundImage:self.image forState:UIControlStateNormal];

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
    _textView = [[XZToolBarTextView alloc] init];
    _textView.font = [UIFont systemFontOfSize:15];
    _textView.placeholder = @"请简短的描述你的问题";
    _textView.cornerRadius = 15;
    _textView.backgroundColor = XZColor(242, 242, 242);
    FMWeakSelf;
    [_textView textValueDidChanged:^(NSString *text, CGFloat textHeight) {
        
        weakSelf.userInput_text = text;
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
        weakSelf.btnSendMsg.hidden = text.length ? NO:YES;
        weakSelf.btnContactAdd.hidden = text.length ? YES:NO;
        
        if (self.currentTextHeight != textHeight) {
            // 记录当前高度
            self.currentTextHeight = textHeight;
            // 将toolbar的高度传递给控制器，修改tableView
            if (weakSelf.blockTextViwDidChanged) {
                weakSelf.blockTextViwDidChanged([weakSelf toolbar_height]);
            }
        }
    }];
    
    // 设置文本框最大行数
    _textView.maxNumberOfLines = 4;
    [topView addSubview:_textView];
    
    [self setupConstraints:topView];
}

/// 设置布局
- (void)setupConstraints:(UIView *)topView {
    /// 底部视图
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.bottom.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@(XZChatToolBarHeight));
    }];
    
    CGFloat bottom = (XZChatToolBarHeight - kToolbarBtnH) / 2.0;
    
    /// 语音聊天
    [self.btnVoice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topView).offset(10);
        make.bottom.equalTo(topView).offset(-bottom);
        make.size.equalTo(@(kToolbarBtnH));
    }];
    
    /// 转人工
    [self.btnTurnArtifical mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topView).offset(8);
        make.bottom.equalTo(topView).offset(-5);
        make.size.equalTo(@45);
    }];
    
    CGFloat width = KProjectScreenWidth - kBtnSpeakLeftX - 10 - 50;
    /// 按住说话
    [self.btnSpeak mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topView).offset(kBtnSpeakLeftX);
        make.width.equalTo(@(width));
        make.centerY.equalTo(topView);
        make.height.equalTo(@(kToolbarBtnH));
    }];
    
    /// 输入文字
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

/// 高度
- (CGFloat)toolbar_height {
    return self.textView.text_height + XZChatToolBarHeight - kToolbarBtnH;
}

/// 添加 3 分钟页面到视图，将toolBar还原到初始状态
- (void)initializeToolBar {
    // 清空输入框
    if (self.userInput_text.length) {
        self.textView.text = @"";
        // 添加输入框通知
        [[NSNotificationCenter defaultCenter] postNotificationName: UITextViewTextDidChangeNotification object:self.textView];
        self.userInput_text = @"";
    }
    
    [self makeKeyboardInputViewConstraints:NO];
}

/// 设置底部视图的布局 isBottom:YES 显示，NO 不显示
- (void)makeKeyboardInputViewConstraints:(BOOL)isBottom {
    FMWeakSelf;
    CGFloat height = [self toolbar_height];
    
    if (self.textView.hidden) {
        height = XZChatToolBarHeight;
    }
    
    if (isBottom) { // 显示工具栏底部视图
        
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(weakSelf);
            make.height.equalTo(@(height));
            make.bottom.equalTo(weakSelf).offset(-kToolbarBottom);
        }];
        
        self.keyboardInputView.hidden = NO;
        [self.keyboardInputView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(weakSelf);
            make.top.equalTo(weakSelf.topView.mas_bottom);
            make.height.equalTo(@(kToolbarBottom));
        }];
        
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(weakSelf.viewController.view);
            make.height.equalTo(@(height + kToolbarBottom));
        }];
        
        // 将toolbar的高度传递给控制器，修改tableView
        if (self.blockTextViwDidChanged) {
            self.blockTextViwDidChanged(height + 100);
        }
        
        [self.keyboardInputView layoutIfNeeded];
    }else { // 隐藏工具栏底部视图
        
        [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf);
            make.bottom.equalTo(weakSelf);
            make.right.equalTo(weakSelf);
            make.height.equalTo(@(height));
        }];
        
        self.keyboardInputView.hidden = YES;
        [self.keyboardInputView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf);
            make.right.equalTo(weakSelf);
            make.bottom.equalTo(weakSelf);
            make.height.equalTo(@0);
        }];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(weakSelf.viewController.view);
            make.height.equalTo(@(height));
        }];
        
        // 将加号选中状态还原
        self.btnContactAdd.selected = NO;
        
        // 将toolbar的高度传递给控制器，修改tableView
        if (self.blockTextViwDidChanged) {
            self.blockTextViwDidChanged(height);
        }
    }
}

- (void)destroyToolBar {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    for (UIView *subiew in self.subviews) {
        [subiew removeFromSuperview];
    }
    
    self.delegate  = nil;
    [self removeFromSuperview];
}

#pragma mark --- 懒加载
- (XZKeyboardInputView *)keyboardInputView {
    if (!_keyboardInputView) {
        _keyboardInputView = [[XZKeyboardInputView alloc] init];
        _keyboardInputView.hidden = YES;
        [self addSubview:_keyboardInputView];
        // 设置是跟机器人聊天还是跟客服聊天
        _keyboardInputView.isRobot = YES;
        
        FMWeakSelf;
        _keyboardInputView.blockClickKeyboardInputViewBtn = ^(NSInteger tag) {
            if (weakSelf.blockClickedKeyboardInputView) {
                weakSelf.blockClickedKeyboardInputView(tag, weakSelf.keyboardInputView.isRobot);
            }
        };
    }
    return _keyboardInputView;
}

/// 60s倒计时
- (NSTimer *)timerReduce {
    if (!_timerReduce) {
        _timerReduce = [NSTimer scheduledTimerWithTimeInterval:kFakeTimerDuration target:self selector:@selector(timerReduceOneSecond) userInfo:nil repeats:YES];
    }
    return _timerReduce;
}

/// 录音提示页面
- (XZVoiceProgress *)voiceProgress {
    if (!_voiceProgress) {
        _voiceProgress = [[XZVoiceProgress alloc] initWithFrame:CGRectMake(0, 0, 155, 155)];
        _voiceProgress.center = CGPointMake(self.superView.fm_centerX, self.superView.fm_centerY - 64);
        _voiceProgress.isHidden = YES;
    }
    return _voiceProgress;
}

// 正常显示图片
- (UIImage *)image {
    if (!_image) {
        _image = [UIImage imageNamed:@"compose_emotion_table_left_normal"];
        _image = [_image xz_resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, _image.size.width - 1)];
    }
    
    return _image;
}

// 选中图片
- (UIImage *)highlightedImage {
    if (!_highlightedImage) {
        _highlightedImage = [UIImage imageNamed:@"compose_emotion_table_left_selected"];
        _highlightedImage = [_highlightedImage xz_resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, _highlightedImage.size.width - 1)];
    }
    return _highlightedImage;
}

- (void)dealloc
{
    Log(@"XZChatToolBar 消失了");
}

@end
