//
//  XZVoiceRecorderManager.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/28.
//  Copyright © 2018年 XZ. All rights reserved.
//  声音录制

#import "XZVoiceRecorderManager.h"
#import <AVFoundation/AVFoundation.h>
#import "VoiceConverter.h"
#import "XZFileTools.h"

#define kShortestRecorder 1.0 /// 最短录音

@interface XZVoiceRecorderManager()<AVAudioRecorderDelegate>
{
    /// 音量大小
    void (^recorderPower)(CGFloat progress);
    /// 录制结束
    void (^recorderFinish)(NSString *recordPath);
    /// 开始录音时间
    NSDate *_startRecordDate;
    /// 结束录音时间
    NSDate *_endRecordDate;
}
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) NSTimer *timer;
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

#pragma mark --- 语音录制处理
/// 开始录音
- (void)startRecordWithFileName:(NSString *)fileName completion:(void(^)(NSError *error))completion power:(void(^)(CGFloat progress))power {
    
    self.currentFileName = fileName;
    
    recorderPower = power;
    
    NSError *error = nil;
    
    if (![self canRecord]) { /// 不允许使用麦克风
       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法录音" message:@"请在iPhone的“设置-隐私-麦克风”选项中，允许iCom访问你的手机麦克风。" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        
        if (completion) {
            error = [NSError errorWithDomain:NSLocalizedString(@"error", @"没权限") code:122 userInfo:nil];
            completion(error);
            
            if (recorderPower) {
                recorderPower(0);
            }
        }
        return;
    }else {
        
        // 取消当前录制
        if ([self.audioRecorder isRecording]) {
            [self.audioRecorder stop];
            [self cancelCurrentRecording];
            return;
        }
        
        [self timer]; // 启动定时器
        
        // 设置策略
        NSError *error = nil;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        if (error) {
            Log(@"startRecordWithFileName错误：%@", [error description]);
        }
        
        // 初始化录音设备
        NSURL *url = [NSURL fileURLWithPath:[XZFileTools recoderPathWithFileName: fileName]];
        
        Log(@"初始化录音设备 %@",[XZFileTools recoderPathWithFileName: fileName]);
        
        NSDictionary *settings = [self getAudioSetting];
        self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
        self.audioRecorder.delegate = self;
       
        // 监控声波
        self.audioRecorder.meteringEnabled = YES;
        
        if (!self.audioRecorder || error) {
            _audioRecorder = nil;
            
            if (completion) {
                error = [NSError errorWithDomain:NSLocalizedString(@"error.initRecorderFail", @"Failed to initialize AVAudioRecorder") code:123 userInfo:nil];
                completion(error);
                
                if (recorderPower) {
                    recorderPower(0);
                }
            }
            return;
        }
        _startRecordDate = [NSDate date];
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
    
    // 关闭定时器
    [self.timer invalidate];
    _timer = nil;
    
    _endRecordDate = [NSDate date];
    
    NSTimeInterval recordDuration = [_endRecordDate timeIntervalSinceDate:_startRecordDate];
    
    if ([self.audioRecorder isRecording]) {
        if (recordDuration < kShortestRecorder) {
            if (completion) {
                completion(shortRecord);
            }
            
            if (recorderPower) {
                recorderPower(0);
            }
            
            /// 录音时间太短，不保存
            [self cancelCurrentRecording];
            [self removeCurrentRecordFile];
            Log(@"录制时间太短");
            return;
        }else {
//            if (completion) {
//                completion(@"NOT SHORT RECORD");
//            }
            
            recorderFinish = completion;
            
            FMWeakSelf;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [weakSelf.audioRecorder stop];
                Log(@"录音时长：%f",recordDuration);
            });
        }
    }else {
        Log(@"不是正在录制？？？？");
    }
}

/// 取消当前录制
- (void)cancelCurrentRecording {
    if ([self.audioRecorder isRecording]) {
        [self.audioRecorder stop];
    }
    
    Log(@"cancelCurrentRecording 取消当前录制:%@",_timer);
    
    // 关闭定时器
    [_timer invalidate];
    _timer = nil;
    
    Log(@"cancelCurrentRecording 取消当前录制hou === :%@",_timer);
    
    _audioRecorder.delegate = nil;
    _audioRecorder = nil;
    recorderFinish = nil;
}

/// 移除当前录制文件
- (void)removeCurrentRecordFile {
    [self removeCurrentRecordFile:self.currentFileName];
}

/// 根据路径移除文件
- (void)removeCurrentRecordFile:(NSString *)fileName {
    [self cancelCurrentRecording];
    
    NSString *path = [XZFileTools recoderPathWithFileName:fileName];
   
    [XZFileTools removeFileAtPath:path];
}

/// 获取语音时长
- (NSUInteger)durationWithVoiceURL:(NSURL *)voiceURL {
    NSDictionary *opt = [NSDictionary dictionaryWithObject:@(NO) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    // 初始化媒体文件
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:voiceURL options:opt];
    NSUInteger second = 0;
    // 获取总时长，单位秒
    second = asset.duration.value / asset.duration.timescale;
    
    return second;
}

#pragma mark --- AVAudioRecorderDelegate
/// 录音完成
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    
    [self audioDidFinishRecording:recorder success:flag];
}

/// 录音完成, success 是否成功
- (void)audioDidFinishRecording:(AVAudioRecorder *)recorder success:(BOOL)success {
    
    Log(@"录音完成!");
    
    NSString *recordPath = [[self.audioRecorder url] path];
//    // 音频格式转换 ============= 删除
//    NSString *amrPath = [[recordPath stringByDeletingPathExtension] stringByAppendingPathExtension:kAMRType];
//    Log(@"amrPath ------- %@",amrPath);
//    [VoiceConverter ConvertWavToAmr:recordPath amrSavePath:amrPath];
    
    if (recorderFinish) {
        if (!success) {
            recordPath = nil;
        }
        recorderFinish(recordPath);
    }
    
    _audioRecorder.delegate = nil;
    _audioRecorder = nil;
    recorderFinish = nil;
    
//    // 移除.wav原文件 ============= 删除
//    [self removeCurrentRecordFile:self.currentFileName];
}

/// 录音出现编码问题
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    Log(@"录音出现编码问题 === audioPlayerDecodeErrorDidOccur");
}

#pragma mark --- 时间计时器处理
/// 重新开始
- (void)resumeTimer {
    [self.timer setFireDate:[NSDate distantPast]];
}

/// 暂停计时器
- (void)pauseTimer {
    [self.timer setFireDate:[NSDate distantFuture]];
    
    if (recorderPower) {
        recorderPower(0);
    }
}

/// 声音改变
- (void)powerChanged {
    [self.audioRecorder updateMeters];
    
    // 获取第一通道的音频，范围(-160 ~ 0),声音越大，power值越小
    float power = [self.audioRecorder averagePowerForChannel:0];
    CGFloat progress = (1.0/160.0) * (power + 160);
    if (recorderPower) {
        recorderPower(progress);
    }
    Log(@"语音功率：%f",progress);
}

#pragma mark --- 录音文件设置
- (NSDictionary *)getAudioSetting {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    // 设置录音格式
    [dic setObject:@(kAudioFormatLinearPCM) forKey: AVFormatIDKey];
    // 设置录音采样率，8000是电话采样率，录音足以
    [dic setObject:@(8000) forKey: AVSampleRateKey];
    // 设置通道：单声道
    [dic setObject:@(1) forKey: AVNumberOfChannelsKey];
    // 每个采样点位数，分为8、16、24、32
    [dic setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    // 是否使用浮点数采样
    [dic setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    
    return dic;
}

#pragma mark --- 懒加载
- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(powerChanged) userInfo:nil repeats:YES];
        Log(@"当前录制计时器 ==== %@",_timer);
    }
    return _timer;
}

@end
