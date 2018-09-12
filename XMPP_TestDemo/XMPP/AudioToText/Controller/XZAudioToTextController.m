//
//  XZAudioToTextController.m
//  XMPP_TestDemo
//
//  Created by mac on 2018/9/12.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import "XZAudioToTextController.h"
#import<AVFoundation/AVFoundation.h>
#import<Speech/Speech.h>

API_AVAILABLE(ios(10.0))
@interface XZAudioToTextController ()<SFSpeechRecognizerDelegate>

@property (nonatomic,strong) UIButton *swicthBut;
@property (nonatomic,strong) UILabel *labText;
// 语音识别器
@property(nonatomic,strong) SFSpeechRecognizer *speechRecognizer;
// 语音识别请求
@property (nonatomic,strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
// 语音任务管理器
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;
// 语音控制器
@property (nonatomic,strong) AVAudioEngine *audioEngine;

@end

@implementation XZAudioToTextController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"测试";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: self.swicthBut];
    [self.view addSubview: self.labText];
    
    // 发送语音认证请求(首先要判断设备是否支持语音识别功能)
    if (@available(iOS 10.0, *)) {
        [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
            
            bool isButtonEnabled = false;
            switch(status) {
                    
                case SFSpeechRecognizerAuthorizationStatusAuthorized:
                    
                    isButtonEnabled = true;
                    NSLog(@"可以语音识别");
                    break;
                case SFSpeechRecognizerAuthorizationStatusDenied:
                    
                    isButtonEnabled = false;
                    NSLog(@"用户未授权使用语音识别");
                    break;
                case SFSpeechRecognizerAuthorizationStatusRestricted:
                    isButtonEnabled = false;
                    
                    NSLog(@"语音识别在这台设备上受到限制");
                    break;
                case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                    
                    isButtonEnabled = false;
                    NSLog(@"语音识别未授权");
                    break;
                default:
                    break;
            }
        }];
    } else {
        // Fallback on earlier versions
    }
}

- (void)speechRecognizer:(SFSpeechRecognizer*)speechRecognizer availabilityDidChange:(BOOL)available API_AVAILABLE(ios(10.0)) {
    if(available) {
        self.swicthBut.enabled = YES;
        [self.swicthBut setTitle: @"开始录音" forState: UIControlStateNormal];
    }else{
        self.swicthBut.enabled = NO;
        [self.swicthBut setTitle: @"语音识别不可用" forState: UIControlStateNormal];
    }
}

#pragma mark----语音识别
- (SFSpeechRecognizer*)speechRecognizer  API_AVAILABLE(ios(10.0)){
    if (!_speechRecognizer) {
        NSLocale *cale = [[NSLocale alloc] initWithLocaleIdentifier: @"zh-CN"];
        _speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale: cale];
        // 设置代理
        _speechRecognizer.delegate = self;
    }
    return _speechRecognizer;
}

#pragma mark---停止录音

- (void)endRecording {
    
    [self.audioEngine stop];

    if (_recognitionRequest) {
        [_recognitionRequest endAudio];
    }
    if (_recognitionTask) {
        [_recognitionTask cancel];
        _recognitionTask = nil;
    }
    self.swicthBut.enabled = NO;
}

#pragma mark---开始录音

- (void)startRecording {
    
    if (self.recognitionTask) {
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
    }

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];

    NSError *error;

    bool audioBool = [audioSession setCategory: AVAudioSessionCategoryRecord error: &error];

    bool audioBool1= [audioSession setMode: AVAudioSessionModeMeasurement error: &error];

    bool audioBool2 = [audioSession setActive: true withOptions: AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error: &error];


    if(audioBool || audioBool1|| audioBool2) {
        NSLog(@"可以使用");
    }else{
        Log(@"错误信息 === %@",error);
        Log(@"这里说明有的功能不支持");
    }

    if (@available(iOS 10.0, *)) {
        self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
        AVAudioInputNode *inputNode = self.audioEngine.inputNode;
//        NSAssert(inputNode,@"录入设备没有准备好");
//        NSAssert(self.recognitionRequest, @"请求初始化失败");
        self.recognitionRequest.shouldReportPartialResults = true;
        __weak typeof(self) weakSelf = self;
        // 开始识别任务
        self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
            __strong typeof(weakSelf)strongSelf = weakSelf;
            bool isFinal = false;
            NSLog(@"开始识别任务 %@", result);
            if(result) {
                strongSelf.labText.text = @"";
                strongSelf.labText.text = [[result bestTranscription] formattedString]; // 语音转文本
                isFinal = [result isFinal];
            }else {
                strongSelf.labText.text = @"好像失败了";
            }
            
            if(error || isFinal) {
                [strongSelf.audioEngine stop];
                [inputNode removeTapOnBus: 0];
                strongSelf.recognitionRequest = nil;
                strongSelf.recognitionTask = nil;
                [strongSelf.swicthBut setTitle:@"开始录音" forState: UIControlStateNormal];
                strongSelf.swicthBut.enabled = true;
            }
        }];
        
        AVAudioFormat *recordingFormat = [inputNode outputFormatForBus: 0];
        // 在添加tap之前先移除上一个  不然有可能报"Terminating app due to uncaught exception 'com.apple.coreaudio.avfaudio',"之类的错误
        [inputNode removeTapOnBus:0];
        [inputNode installTapOnBus:0 bufferSize: 1024 format: recordingFormat block:^(AVAudioPCMBuffer*_Nonnull buffer,AVAudioTime*_Nonnull when) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if(strongSelf.recognitionRequest) {
                [strongSelf.recognitionRequest appendAudioPCMBuffer: buffer];
            }
        }];
        
        [self.audioEngine prepare];
        
        bool audioEngineBool = [self.audioEngine startAndReturnError: &error];
        
//        NSParameterAssert(!error);
        self.labText.text = @"正在录音。。。";
        NSLog(@"%d",audioEngineBool);
    } else {
        // Fallback on earlier versions
    }
}

#pragma mark---创建录音引擎
- (AVAudioEngine*)audioEngine{
    if (!_audioEngine) {
        _audioEngine = [[AVAudioEngine alloc] init];
    }
    return _audioEngine;
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
//        [_swicthBut addTarget:self action:@selector(switchOn:) forControlEvents:UIControlEventTouchUpInside];
        [_swicthBut addTarget: self action: @selector(recognizeLocalAudioFile) forControlEvents: UIControlEventTouchUpInside];
        [_swicthBut setTitle:@"开始录音" forState: UIControlStateNormal];
    }

    return _swicthBut;
}

- (void)switchOn:(id)sender{
    
    if([self.audioEngine isRunning]) {
        [self endRecording];
        [_swicthBut setTitle:@"开始录音" forState: UIControlStateNormal];
    }else {
        [self startRecording];
        [_swicthBut setTitle:@"关闭" forState: UIControlStateNormal];
    }
}

#pragma mark---识别本地音频文件
- (void)recognizeLocalAudioFile{
    
    NSLocale *local = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];

    if (@available(iOS 10.0, *)) {
        SFSpeechRecognizer *localRecognizer = [[SFSpeechRecognizer alloc] initWithLocale: local];
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"1536734357.m4a" withExtension: nil];
        NSLog(@"识别本地音频文件 : %@",url);
        
        if(!url) return;
        
        SFSpeechURLRecognitionRequest *res = [[SFSpeechURLRecognitionRequest alloc] initWithURL: url];
        
        __weak typeof(self) weakSelf = self;
        
        [localRecognizer  recognitionTaskWithRequest: res resultHandler:^(SFSpeechRecognitionResult *_Nullable result, NSError *_Nullable error) {
           if(error) {
               NSLog(@"语音识别解析失败,%@",error);
           } else {
               weakSelf.labText.text = result.bestTranscription.formattedString;
                }
        }];
    } else {
        // Fallback on earlier versions
    }
}

@end
