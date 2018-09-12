//
//  XZAudioToTextController.m
//  XMPP_TestDemo
//
//  Created by mac on 2018/9/12.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import "XZAudioToTextController.h"
#import "XZSpeechSynthesizer.h" // 语音识别

API_AVAILABLE(ios(10.0))
@interface XZAudioToTextController ()

@property (nonatomic, strong) UIButton *swicthBut;
@property (nonatomic, strong) UILabel *labText;
@end

@implementation XZAudioToTextController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"语音转文字";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: self.swicthBut];
    [self.view addSubview: self.labText];
    // 判断是否有权限
    [[XZSpeechSynthesizer shared] requestingUserAuthorization];
}

#pragma mark----显示控件
- (UILabel*)labText {

    if (!_labText){
        _labText = [[UILabel alloc] init];
        _labText.frame = CGRectMake(0, 140, [UIScreen mainScreen].bounds.size.width, 50);
        _labText.font = [UIFont systemFontOfSize: 13.0f];
        _labText.numberOfLines = 0;
        _labText.textAlignment = NSTextAlignmentCenter;
        _labText.textColor = [UIColor blackColor];
        _labText.backgroundColor = [UIColor greenColor];
    }

    return _labText;
}

#pragma mark----开关
- (UIButton *)swicthBut {
    
    if (!_swicthBut) {
        _swicthBut= [[UIButton alloc] init];
        _swicthBut.frame = CGRectMake(50,100,80,30);
        _swicthBut.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_swicthBut setTitleColor: [UIColor orangeColor] forState: UIControlStateNormal];
        // 实时识别
//        [_swicthBut addTarget:self action:@selector(switchOn:) forControlEvents:UIControlEventTouchUpInside];
        // 本地语音转文字
        [_swicthBut addTarget: self action: @selector(recognizeLocalAudioFile) forControlEvents: UIControlEventTouchUpInside];
        [_swicthBut setTitle:@"开始录音" forState: UIControlStateNormal];
    }

    return _swicthBut;
}

- (void)switchOn:(UIButton *)button {
    
    button.selected = !button.selected;
    
    [_swicthBut setTitle:button.selected ? @"关闭":@"开始录音" forState: UIControlStateNormal];
    
    if ([[XZSpeechSynthesizer shared] audioEngineIsRunning]) {
        self.labText.text = @"已经停止录音";
        [[XZSpeechSynthesizer shared] endRecording];
    }else {
        self.labText.text = @"开始录音";
        [[XZSpeechSynthesizer shared] startRecording:^(NSString *transcription) {
            self.labText.text = transcription;
        }];
    }
}

#pragma mark---识别本地音频文件
- (void)recognizeLocalAudioFile {
    
    __weak typeof(self) weakSelf = self;
    [[XZSpeechSynthesizer shared] recognizerLocalAudioFile:@"1536734357.m4a" completion:^(NSString *transcription) {
        weakSelf.labText.text = transcription;
    }];
}

@end
