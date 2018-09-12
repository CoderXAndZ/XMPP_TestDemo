//
//  XZSpeechSynthesizer.h
//  XMPP_TestDemo
//
//  Created by mac on 2018/9/12.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XZSpeechSynthesizer : NSObject
/**
 * Privacy - Microphone Usage Description
 * Privacy - Speech Recognition Usage Description
 */
/// 判断设置是否支持语音识别功能
- (void)requestingUserAuthorization;
/// 开始录音
- (void)startRecording;
/// 停止录音
- (void)endRecording;
/// 识别本地音频文件
- (void)recognizerLocalAudioFile;
/// 单例
+ (instancetype)shared;
@end
