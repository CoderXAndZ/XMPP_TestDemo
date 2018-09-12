//
//  XZSpeechSynthesizer.m
//  XMPP_TestDemo
//
//  Created by mac on 2018/9/12.
//  Copyright © 2018年 XZ. All rights reserved.
//  语音识别 -> 语音转文字

#import "XZSpeechSynthesizer.h"
#import "XZAutoHideAlertView.h"
#import <Speech/Speech.h>

API_AVAILABLE(ios(10.0))
@interface XZSpeechSynthesizer()<SFSpeechRecognizerDelegate>
// 语音识别器
@property(nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
// 语音识别请求
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
// 语音任务管理器
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;
// 语音控制器
@property (nonatomic, strong) AVAudioEngine *audioEngine;
/// 是否结束录音
@property (nonatomic, assign) BOOL isStoped;
/// 识别出来的内容
@property (nonatomic, strong) NSString *recoginizerText;
@end

@implementation XZSpeechSynthesizer

/// 单例
+ (instancetype)shared {
    static XZSpeechSynthesizer *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

#pragma mark --- 懒加载
/// 语音识别
- (SFSpeechRecognizer *)speechRecognizer  API_AVAILABLE(ios(10.0)) {
    if (!_speechRecognizer) {
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier: @"zh-CN"];
        _speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale: locale];
        // 设置代理
        _speechRecognizer.delegate = self;
        _isStoped = YES;
    }
    return _speechRecognizer;
}

/// 语音引擎
- (AVAudioEngine*)audioEngine {
    if (!_audioEngine) {
        _audioEngine = [[AVAudioEngine alloc] init];
    }
    return _audioEngine;
}

/// 判断设置是否支持语音识别功能
/**
 * Privacy - Microphone Usage Description
 * Privacy - Speech Recognition Usage Description
 */
- (void)requestingUserAuthorization {
    if (@available(iOS 10.0, *)) {
        [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
            
            bool isEnabled = false;
            switch(status) {
                    
                case SFSpeechRecognizerAuthorizationStatusAuthorized:
                    
                    isEnabled = true;
//                    NSLog(@"可以语音识别");
                    break;
                case SFSpeechRecognizerAuthorizationStatusDenied:
                    
                    isEnabled = false;
                    NSLog(@"用户未授权使用语音识别");
                    break;
                case SFSpeechRecognizerAuthorizationStatusRestricted:
                    isEnabled = false;
                    
                    NSLog(@"语音识别在这台设备上受到限制");
                    break;
                case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                    
                    isEnabled = false;
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

/// 开始录音
- (void)startRecording:(void(^)(NSString *transcription))completion {
    if (self.recognitionTask) {
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
    }
    
    // 每次置空上次识别内容
    self.recoginizerText = @"";
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error;
    [audioSession setCategory: AVAudioSessionCategoryRecord error: &error];
    [audioSession setMode: AVAudioSessionModeMeasurement error: &error];
    [audioSession setActive: true withOptions: AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error: &error];
    
    if (error) {
        NSLog(@"错误信息 === %@",error);
    }else {
        NSLog(@"可以使用");
    }
    
    if (@available(iOS 10.0, *)) {
        self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
        AVAudioInputNode *inputNode = self.audioEngine.inputNode;
        self.recognitionRequest.shouldReportPartialResults = true;
        
        __weak typeof(self) weakSelf = self;
        // 开始识别任务
        self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
            
            __strong typeof(weakSelf)strongSelf = weakSelf;
            bool isFinal = false;
            NSLog(@"开始识别任务 %@", result);
            
            // 手动停止了录音，也会调用这个回调，使用这个参数判断是否结束了
            if (weakSelf.isStoped) {
                completion(weakSelf.recoginizerText);
            }else {
                // 语音转文本
                if(result) {
                    Log(@"现在正在说：%@",[[result bestTranscription] formattedString]);
                    weakSelf.recoginizerText = [[result bestTranscription] formattedString];
                    completion(weakSelf.recoginizerText);
                    
                    isFinal = [result isFinal];
                }else {
                    completion(@"语音转文本，好像失败了");
                }
            }
            
            if(error || isFinal) {
                [strongSelf.audioEngine stop];
                [inputNode removeTapOnBus: 0];
                strongSelf.recognitionRequest = nil;
                strongSelf.recognitionTask = nil;
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
        [self.audioEngine startAndReturnError: &error];
        _isStoped = NO;
//        ShowAutoHideAlertView(@"正在录音。。。");
    } else {
        // Fallback on earlier versions
    }
}

/// 是否正在录音
- (BOOL)audioEngineIsRunning {
    return [self.audioEngine isRunning] ? YES: NO;
}

/// 停止录音
- (void)endRecording {
    _isStoped = YES; // 停止
    
    [self.audioEngine stop];
    
    if (_recognitionRequest) {
        [_recognitionRequest endAudio];
    }
    if (_recognitionTask) {
        [_recognitionTask cancel];
        _recognitionTask = nil;
    }
    
}

/// 识别本地音频文件
- (void)recognizerLocalAudioFile:(NSString *)localFile completion:(void(^)(NSString *transcription))completion {
    NSLocale *local = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
    if (@available(iOS 10.0, *)) {
        SFSpeechRecognizer *localRecognizer = [[SFSpeechRecognizer alloc] initWithLocale: local];
        NSURL *url = [[NSBundle mainBundle] URLForResource: localFile withExtension: nil];
        
        NSLog(@"识别本地音频文件 : %@",url);
        
        if(!url) return;
        
        SFSpeechURLRecognitionRequest *res = [[SFSpeechURLRecognitionRequest alloc] initWithURL: url];
        
        [localRecognizer recognitionTaskWithRequest: res resultHandler:^(SFSpeechRecognitionResult *_Nullable result, NSError *_Nullable error) {
            if(error) {
                ShowAutoHideAlertView([NSString stringWithFormat:@"语音识别解析失败:%@",error]);
            } else { // 语音解析成功
//                ShowAutoHideAlertView(result.bestTranscription.formattedString);
                
                completion(result.bestTranscription.formattedString);
            }
        }];
    } else {
        // Fallback on earlier versions
    }
}

#pragma mark --- SFSpeechRecognizerDelegate
- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available  API_AVAILABLE(ios(10.0)) {
    
    if (available) {
        ShowAutoHideAlertView(@"开始录音");
    }else {
        ShowAutoHideAlertView(@"语音识别不可用");
    }
}

@end
