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
/// 获取某个路径下的某个类型文件
+ (NSArray *)GetFilesListAtPath:(NSString *)dirPath withType:(NSString *)type;
/// 判断文件是否存在
+ (BOOL)fileExistsAtPath:(NSString *)path;
/// 获取后缀
+ (NSString *)getTheSuffix:(NSString *)fileName;
/// 移除路径path下的文件
+ (BOOL)removeFileAtPath:(NSString *)path;
/// 某个路径下的文件大小字符串值,小于1024显示KB，否则显示MB
+ (NSString *)filesize:(NSString *)path;
/// 文件大小的字节值
+ (CGFloat)fileSizeWithPath:(NSString *)path;
/// 获取语音时长
+ (NSTimeInterval)durationWithVoiceURL:(NSURL *)voiceURL;
/// 当前时间作为文件名使用
+ (NSString *)currentFileName:(NSString *)suffix;
/// 当前录音的时间作为文件名使用
+ (NSString *)currentRecordFileName;
#pragma mark --- 文件存放地址
/// 根据路径获取文件
+ (NSArray *)getAllDocumentFromFile;
/// 文件路径
+ (NSString *)documentPathWithName:(NSString *)name;
/// 文件夹路径
+ (NSString *)mainPathOfDocuments;
#pragma mark --- 录音文件存放地址
/// 录音文件主路径
+ (NSString *)mainPathOfRecorder;
/// 录音文件路径
+ (NSString *)recoderPathWithFileName:(NSString *)fileName;

@end
