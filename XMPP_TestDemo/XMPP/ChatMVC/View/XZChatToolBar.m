//
//  XZChatToolBar.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/27.
//  Copyright © 2018年 XZ. All rights reserved.
//  聊天工具栏

#import "XZChatToolBar.h"

@interface XZChatToolBar()
/// 语音聊天按钮 // 35
@property (nonatomic, strong) UIButton *btnVoice;
/// 按住说话按钮,默认隐藏
@property (nonatomic, strong) UIButton *btnSpeak;
/// 表情按钮
@property (nonatomic, strong) UIButton *btnEmoticon;
/// 加号按钮
@property (nonatomic, strong) UIButton *btnContactAdd;
@end;

@implementation XZChatToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupChatToolBar];
    }
    return self;
}

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
    [btnSpeak addTarget:self action:@selector(speakerTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [btnSpeak addTarget:self action:@selector(speakerTouchDown) forControlEvents:UIControlEventTouchDown];
    [btnSpeak addTarget:self action:@selector(speakerTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [btnSpeak addTarget:self action:@selector(speakerTouchCancel) forControlEvents:UIControlEventTouchCancel];
    [btnSpeak addTarget:self action:@selector(speakerTouchDragOutside) forControlEvents:UIControlEventTouchDragOutside];
    [btnSpeak addTarget:self action:@selector(speakerTouchDragInside) forControlEvents:UIControlEventTouchDragInside];
    [btnSpeak setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    btnSpeak.hidden = YES;
    btnSpeak.layer.masksToBounds = YES;
    btnSpeak.layer.cornerRadius = 10;
    btnSpeak.layer.borderWidth = 1.0f;
    btnSpeak.layer.borderColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1.0].CGColor;
    [btnSpeak.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    
    UIImage *image = [UIImage imageNamed:@"compose_emotion_table_left_normal"];
    image = [image xz_resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, image.size.width - 1)];
    [btnSpeak setBackgroundImage:image forState:UIControlStateNormal];
    
    UIImage *imageSelected = [UIImage imageNamed:@"compose_emotion_table_left_selected"];
    imageSelected = [imageSelected xz_resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, imageSelected.size.width - 1)];
    [btnSpeak setBackgroundImage:imageSelected forState:UIControlStateHighlighted];
    [btnSpeak addTarget:self action:@selector(pressOnSpeakButton:) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    [self setupConstraints];
}

/// 设置布局
- (void)setupConstraints {
    
    [self.btnVoice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(5);
        make.centerY.equalTo(self);
        make.size.equalTo(@35);
    }];
    
    CGFloat width = kScreenWidth - (35 * 3) - 20 - 5;
    
    [self.btnSpeak mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.btnVoice.mas_right).offset(5);
        make.width.equalTo(@(width));
        make.centerY.equalTo(self.btnVoice);
        make.height.equalTo(@35);
    }];
    
    [self.btnContactAdd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-5);
        make.centerY.equalTo(self);
        make.size.equalTo(self.btnVoice);
    }];
    
    [self.btnEmoticon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.btnContactAdd.mas_left).offset(-5);
        make.centerY.equalTo(self);
        make.size.equalTo(self.btnVoice);
    }];
    
}

/// 点击 "按住 说话" ==> 变成 “松开 结束”
- (void)pressOnSpeakButton:(UIButton *)button {
    button.selected = !button.selected;
}

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
- (void)speakerTouchUpInside {
    
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

@end
