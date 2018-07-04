//
//  XZVoiceRecorderManager.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/28.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import <Foundation/Foundation.h>

#define shortRecord  @"shortRecord"

@interface XZVoiceRecorderManager : NSObject
/// 录音文件当前存储路径
@property (nonatomic, strong) NSString *currentFileName;

/// 单例
+ (instancetype)sharedManager;

/// 访问录音权限
- (BOOL)canRecord;

/// 开始录音
- (void)startRecordWithFileName:(NSString *)fileName completion:(void(^)(NSError *error))completion power:(void(^)(CGFloat progress))power;
/// 停止录制
- (void)stopRecordingWithCompletion:(void(^)(NSString *recordPath))completion;
/// 取消当前录制
- (void)cancelCurrentRecording;
/// 移除当前录制文件
- (void)removeCurrentRecordFile;

/// 暂停计时器
- (void)pauseTimer;
/// 重新开始计时器
- (void)resumeTimer;

/// 获取语音时长
- (NSUInteger)durationWithVoiceURL:(NSURL *)voiceURL;
@end
