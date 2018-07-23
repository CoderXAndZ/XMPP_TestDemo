//
//  XZFileTools.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/28.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XZFileTools : NSObject
/// 获取缓存路径
+ (NSString *)getAppCacheDirectory;
/// 获取 AppSupport 路径
+ (NSString *)getAppSupportDataDirectory;
/// 获取临时缓存
+ (NSString *)getTempDataCacheDirectory;
/// 获取数据缓存路径
+ (NSString *)getDataCacheDirectory;
/// 获取某个路径下的某个类型文件
+ (NSArray *)GetFilesListAtPath:(NSString *)dirPath withType:(NSString *)type;
/// 获取web路径
+ (NSString *)getWebrootDirectory;
/// 判断文件是否存在
+ (BOOL)fileExistsAtPath:(NSString *)path;
/// 移除路径path下的文件
+ (BOOL)removeFileAtPath:(NSString *)path;

/// 获取文件主目录
+ (NSString *)fileMainPath;
/// 某个路径下的文件大小字符串值,小于1024显示KB，否则显示MB
+ (NSString *)filesize:(NSString *)path;
/// 文件大小的字节值
+ (CGFloat)fileSizeWithPath:(NSString *)path;

/// 获取语音时长
+ (NSTimeInterval)durationWithVoiceURL:(NSURL *)voiceURL;
/// 当前录音的时间作为文件名使用
+ (NSString *)currentRecordFileName;

#pragma mark --- 录音文件存放地址
/// 录音文件主路径
+ (NSString *)mainPathOfRecorder;
/// 录音文件路径
+ (NSString *)recoderPathWithFileName:(NSString *)fileName;

@end
