//
//  XZFileTools.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/28.
//  Copyright © 2018年 XZ. All rights reserved.
//  文件相关工具

#import "XZFileTools.h"
#import <AVFoundation/AVFoundation.h>

@implementation XZFileTools

+ (NSString *)getTempDataCacheDirectory {
    return [[self getAppCacheDirectory] stringByAppendingPathComponent:@"appdata"];         // 1.5.3 修改，之前是 tempData目录
}

+ (NSString *)getAppCacheDirectory {
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [cachesDirectory stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (NSString *)getDataCacheDirectory {
    NSString *path = [[self getAppCacheDirectory] stringByAppendingPathComponent:@"appdata"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (NSString *)getAppSupportDataDirectory {
    NSString *libPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    NSString *appsupport = [libPath stringByAppendingPathComponent:@"AppSupport"];
    return appsupport;
}

+ (NSString *)getWebrootDirectory {
    return [[self getAppSupportDataDirectory] stringByAppendingPathComponent:@"web"];
}

/// 当前录音的时间作为文件名使用
+ (NSString *)currentRecordFileName {
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%ld.wav",(long)timeInterval];
    
    NSLog(@"音频存放名称：%@",fileName);
    
    return fileName;
}

/// 获取语音时长
+ (NSUInteger)durationWithVoiceURL:(NSURL *)voiceURL {
    NSDictionary *opt = [NSDictionary dictionaryWithObject:@(NO) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    // 初始化媒体文件
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:voiceURL options:opt];
    NSUInteger second = 0;
    // 获取总时长，单位秒
    second = asset.duration.value / asset.duration.timescale;
    
    return second;
}

/// 判断文件是否存在
+ (BOOL)fileExistsAtPath:(NSString *)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

/// 移除 path 路径下的文件
+ (BOOL)removeFileAtPath:(NSString *)path
{
    return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

/// 录音文件路径
+ (NSString *)recoderPathWithFileName:(NSString *)fileName {
    
    NSString *recoderPath = [[self mainPathOfRecorder] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
    
    NSLog(@"recoderPathWithFileName-录音文件路径:%@", recoderPath);
    
    return recoderPath;
}

/// 录音文件主路径
+ (NSString *)mainPathOfRecorder {
    NSString *path = [[self getAppCacheDirectory] stringByAppendingString: kRecorderPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path]) {
        if (![manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil]) {
            
            NSLog(@"创建文件夹失败");
            return nil;
        }
    }
    return path;
}

+ (NSArray *)GetFilesListAtPath:(NSString *)dirPath withType:(NSString *)type
{
    //    NSMutableArray *filenamelist = [NSMutableArray arrayWithCapacity:10];
    NSURL *dirURL = [NSURL fileURLWithPath:dirPath];
    if (!dirURL) {
        NSLog(@"dirPath can not create URL!");
        return @[];
    }
    //    NSArray *tmplist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    NSFileManager *localFileManager=[[NSFileManager alloc] init];
    
    // Enumerate the directory (specified elsewhere in your code)
    // Request the two properties the method uses, name and isDirectory
    // Ignore hidden files
    // The errorHandler: parameter is set to nil. Typically you'd want to present a panel
    NSDirectoryEnumerator *dirEnumerator = [localFileManager enumeratorAtURL:dirURL
                                                  includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLNameKey,
                                                                              NSURLIsDirectoryKey,nil]
                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                                                errorHandler:nil];
    
    // An array to store the all the enumerated file names in
    //    NSMutableArray *theArray=[NSMutableArray array];
    NSMutableArray *fileNames = [NSMutableArray arrayWithCapacity:10];
    // Enumerate the dirEnumerator results, each value is stored in allURLs
    for (NSURL *theURL in dirEnumerator) {
        
        // Retrieve the file name. From NSURLNameKey, cached during the enumeration.
        NSString *fileName;
        [theURL getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
        
        // Retrieve whether a directory. From NSURLIsDirectoryKey, also
        // cached during the enumeration.
        NSNumber *isDirectory;
        [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
        
        // Ignore files directory
        if ( ([isDirectory boolValue] == YES) )
        {
            [dirEnumerator skipDescendants];
        }
        else
        {
            // Add full path for non directories
            if ([isDirectory boolValue]==NO) {
                if (type) {
                    if ([[fileName pathExtension] isEqualToString:type]) {
                        [fileNames addObject:fileName];
                    }
                }
                else
                    [fileNames addObject:fileName];
                //                [theArray addObject:theURL];
            }
            
            
        }
    }
    
    return fileNames;
}

// 文件主目录
+ (NSString *)fileMainPath
{
    
    NSString *path = XZOfficeDir;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirExist = [fileManager fileExistsAtPath:path];
    if (!isDirExist) {
        BOOL isCreatDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isCreatDir) {
            NSLog(@"create folder failed");
            return nil;
        }
    }
    return path;
}

/// 某个路径下的文件大小字符串值 小于1024显示KB，否则显示MB
+ (NSString *)filesize:(NSString *)path {
    CGFloat size = [self fileSizeWithPath:path];
    if ( size > 1000.0) { // 以1000为标准
        return [NSString stringWithFormat:@"%.1fMB",size / 1024.0];
    } else {
        return [NSString stringWithFormat:@"%.1fKB",size];
    }
}

/// 字节值转换成字符串值
+ (NSString *)fileSizeWithInteger:(NSUInteger)integer {
    CGFloat size = integer/1024.0;
    if ( size > 1000.0) { // 以1000为标准
        return [NSString stringWithFormat:@"%.1fMB",size/1024.0];
    } else {
        return [NSString stringWithFormat:@"%.1fKB",size];
    }
}

/// 返回字节 == 文件大小的字节值
+ (CGFloat)fileSizeWithPath:(NSString *)path {
    NSDictionary *outputFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return [outputFileAttributes fileSize]/1024.0;
}

@end
