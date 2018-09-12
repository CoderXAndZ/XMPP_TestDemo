//
//  XZVoiceRecorderManager.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/28.
//  Copyright © 2018年 XZ. All rights reserved.
//  声音录制

#import "XZVoiceRecorderManager.h"
#import <AVFoundation/AVFoundation.h>
#import "XZMacroDefinition.h"
#import "VoiceConverter.h"
#import "XZFileTools.h"
#import<Speech/Speech.h>

//#define kShortestRecorder 1.0 /// 最短录音

@interface XZVoiceRecorderManager()<AVAudioRecorderDelegate,SFSpeechRecognizerDelegate>
{
    /// 录制结束
    void (^recorderFinish)(NSString *recordPath);
    // 当前录音文件地址
    NSString *_currentPath;
}
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;

@end

@implementation XZVoiceRecorderManager

/// 单例
+ (instancetype)sharedManager {
    static XZVoiceRecorderManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

#pragma mark --- 语音录制处理
/// 开始录音
- (void)startRecordWithFileName:(NSString *)fileName
                     completion:(void(^)(NSError *error))completion
                           {
    // 将需要取消录制还原
    self.isNeedCancelRecording = NO;
                               
    self.currentFileName = fileName;
    _currentPath = fileName;
    
    NSError *error = nil;
    
    if (![self canRecord]) { /// 不允许使用麦克风
       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法录音" message:@"请在iPhone的“设置-隐私-麦克风”选项中，允许融托金融访问你的手机麦克风。" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        
        if (completion) {
            error = [NSError errorWithDomain:NSLocalizedString(@"error", @"没权限") code:122 userInfo:nil];
            completion(error);
        }
        return;
    }else {
        // 取消当前录制
        if ([self.audioRecorder isRecording]) {
            [self.audioRecorder stop];
            [self cancelCurrentRecording];
            return;
        }
        
        // 设置策略
        NSError *error = nil;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        
        if (error) {
            Log(@"startRecordWithFileName错误：%@", [error description]);
        }
        NSURL *url = [NSURL fileURLWithPath:[XZFileTools recoderPathWithFileName: fileName]];
        
        // 录音设备的设置需要跟VoiceConverter一样 [self getAudioSetting]
        NSDictionary *settings = [VoiceConverter GetAudioRecorderSettingDict];
        // 初始化录音设备
        self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
        self.audioRecorder.delegate = self;
        // 监控声波
        self.audioRecorder.meteringEnabled = YES;
        
        if (!self.audioRecorder || error) {
            _audioRecorder = nil;
            
            if (completion) {
                error = [NSError errorWithDomain:NSLocalizedString(@"error.initRecorderFail", @"Failed to initialize AVAudioRecorder") code:123 userInfo:nil];
                completion(error);
            }
            return;
        }
        [self.audioRecorder prepareToRecord];
        // 开始录音
        [self.audioRecorder record];
        if (completion) {
            completion(error);
        }
    }
}

/// 停止录制
- (void)stopRecordingWithCompletion:(void(^)(NSString *recordPath))completion {

    if ([self.audioRecorder isRecording]) {
        [self.audioRecorder stop];
        
        recorderFinish = completion;
        Log(@"回调音频");
    }else {
        Log(@"不是正在录制？？？？");
    }
}

/// 取消当前录制
- (void)cancelCurrentRecording {
//    if ([self.audioRecorder isRecording]) {
    [self.audioRecorder stop];
//    }
    [self.audioRecorder deleteRecording];
    
    _audioRecorder.delegate = nil;
    _audioRecorder = nil;
    recorderFinish = nil;
}

/// 声音改变获取
- (CGFloat)powerChanged {
    [self.audioRecorder updateMeters];
    
    // 获取第一通道的音频，范围(-160 ~ 0),声音越大，power值越小
    float power = [self.audioRecorder averagePowerForChannel:0];
    CGFloat progress = (1.0/160.0) * (power + 160);
    
    return progress;
}

#pragma mark --- AVAudioRecorderDelegate
/// 录音完成
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    
    
    NSString *recordPath = [[self.audioRecorder url] path];
    
    Log(@"录音完成! recordPath: %@",recordPath);
    [self changeWAVToM4a: recordPath];
    
//    // 音频格式转换
//    NSString *amrPath = [[recordPath stringByDeletingPathExtension] stringByAppendingPathExtension:kAMRType];
//
//    [VoiceConverter ConvertWavToAmr:recordPath amrSavePath:amrPath];
//
//    if (recorderFinish) {
//        if (!flag) {
//            recordPath = nil;
//        }
//        recorderFinish(amrPath);
//    }
//    // 取消时，删除当前录制
//    if (self.isNeedCancelRecording) {
//        Log(@"取消时，删除当前录制");
//        [self.audioRecorder deleteRecording];
//    }
//
//    if (_audioRecorder) {
//        _audioRecorder.delegate = nil;
//        _audioRecorder = nil;
//    }
//    if (recorderFinish) {
//       recorderFinish = nil;
//    }
    
//    // 移除.wav原文件 ============= 删除
//    [self removeCurrentRecordFile:self.currentFileName];
}

// 录制过程中造成录音中断
- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder {
    // 取消录制，回调控制器
    [self cancelCurrentRecording];
    
    if (self.audioRecorderInterrupted) {
        self.audioRecorderInterrupted(@"来电话了");
    }
    Log(@"录制过程中造成录音中断");
}

/// 录音出现编码问题
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    Log(@"录音出现编码问题 === audioPlayerDecodeErrorDidOccur");
}

// 设置是否需要取消录音
- (void)setIsNeedCancelRecording:(BOOL)isNeedCancelRecording {
    _isNeedCancelRecording = isNeedCancelRecording;
}

#pragma mark --- 文件操作
/// 移除当前录制文件
- (void)removeCurrentRecordFile {
    [self removeCurrentRecordFile:self.currentFileName];
}

/// 根据路径移除文件
- (void)removeCurrentRecordFile:(NSString *)fileName {
    NSString *path = [XZFileTools recoderPathWithFileName:fileName];
    
    if ([XZFileTools fileExistsAtPath:path]) {
        [XZFileTools removeFileAtPath:path];
    }
}

/// 当前文件名
- (NSString *)currentFileName {
    
    return [_currentPath stringByReplacingOccurrencesOfString:@"wav" withString:@"amr"];
}

/// 访问录音权限
- (BOOL)canRecord {
    __block BOOL canRecorder = YES;
    // 判读是否是系统 8.0 以后
    if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending) {
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        if ([session respondsToSelector:@selector(requestRecordPermission:)]) {
            [session requestRecordPermission:^(BOOL granted) {
                canRecorder = granted;
            }];
        }
    }
    return canRecorder;
}

#pragma mark --- 录音文件设置
- (NSDictionary *)getAudioSetting {

    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    // 设置录音格式
//    [dic setObject:@(kAudioFormatLinearPCM) forKey: AVFormatIDKey];
    [dic setValue:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
    // 设置录音采样率，8000是电话采样率，录音足以
    [dic setObject:@(8000) forKey: AVSampleRateKey];
    // 设置通道：单声道
    [dic setObject:@(1) forKey: AVNumberOfChannelsKey];
    // 每个采样点位数，分为8、16、24、32
    [dic setObject:@(16) forKey:AVLinearPCMBitDepthKey];
    // 是否使用浮点数采样
    [dic setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    // 录音的质量
    [dic setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];

    return dic;
}

// wav 转 m4a 格式
- (void)changeWAVToM4a:(NSString *)path {
    NSURL *audioPath = [NSURL fileURLWithPath:path];
    
    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioPath options:nil];

    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:audioAsset presetName:AVAssetExportPresetAppleM4A];

    NSURL *destinationURL = [NSURL fileURLWithPath:[[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"m4a"]];
    
    exportSession.outputURL = destinationURL;

    exportSession.outputFileType = AVFileTypeAppleM4A;

    [exportSession exportAsynchronouslyWithCompletionHandler:^{
    
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
        }else if (AVAssetExportSessionStatusFailed == exportSession.status) {
        } else {}
    
//            didFinish();
        
        NSString *m4aPath = [[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"m4a"];
        Log(@"已完成转码 === %@",m4aPath);
        [self translationm4a: m4aPath];
    }];

}

// m4a 翻译
- (void)translationm4a:(NSString *)path  {

    NSURL *destinationURL = [NSURL fileURLWithPath: path];
    
    NSLocale *local = [[NSLocale alloc] initWithLocaleIdentifier: @"zh_CN"];
    
    if (@available(iOS 10.0, *)) {
        // 语音识别器
        SFSpeechRecognizer *localRecognizer = [[SFSpeechRecognizer alloc] initWithLocale: local];
        
        localRecognizer.delegate = self;
        
        NSURL *url = destinationURL;
        
        if (!url) {
            Log(@"转换失败");
            return;
        }
        
        SFSpeechURLRecognitionRequest *res = [[SFSpeechURLRecognitionRequest alloc] initWithURL:url];
        
        __weak typeof(self) weakSelf = self;
        [localRecognizer recognitionTaskWithRequest:res resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
            if (error) {
                
                NSLog(@"------------------------语音识别解析======失败,%@",error);
                //                [AlertUtil showAlertWithText:@"转换失败"];
            } else {
                
                NSLog(@"------------------------语音识别解析======成功,%@",result.bestTranscription.formattedString);
                //              [weakSelf showWord:result.bestTranscription.formattedString];
            }
            
        }];
    } else {
        // Fallback on earlier versions
    }
    
}
@end
