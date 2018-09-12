//
//  XZVoiceRecorderManager.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/28.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XZVoiceRecorderManager : NSObject
/// 单例
+ (instancetype)sharedManager;
/// 开始录音
- (void)startRecordWithFileName:(NSString *)fileName completion:(void(^)(NSError *error))completion;
/// 停止录制
- (void)stopRecordingWithCompletion:(void(^)(NSString *recordPath))completion;
/// 录制被中断，录制过程中来电话
@property (nonatomic, copy) void(^audioRecorderInterrupted)(NSString *tips);

/// 取消当前录制
- (void)cancelCurrentRecording;
/// 移除当前录制文件
- (void)removeCurrentRecordFile;
/// 录音文件当前存储路径
@property (nonatomic, strong) NSString *currentFileName;
/** 是否需要取消录音 */
@property (nonatomic, assign) BOOL isNeedCancelRecording;
/// 声音改变
- (CGFloat)powerChanged;

@end
