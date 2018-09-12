//
//  XZFileTools.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/28.
//  Copyright © 2018年 XZ. All rights reserved.
//  文件相关工具

#import "XZFileTools.h"
#import <AVFoundation/AVFoundation.h>
#import "XZMacroDefinition.h"
#import "XZMediaModel.h"
//#import "FMXmppManager.h"

@implementation XZFileTools

+ (NSString *)getAppCacheDirectory {
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [cachesDirectory stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

/// 当前时间作为文件名使用
+ (NSString *)currentFileName:(NSString *)suffix {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *namePath = [NSString stringWithFormat:@"%ld.%@",(long)timeInterval,suffix];
    //    NSString *namePath = [NSString stringWithFormat:@"%@.wav",[[FMXmppManager defaultManager].xmppStream generateUUID]];
    return namePath;
}

/// 当前录音的时间作为文件名使用
+ (NSString *)currentRecordFileName {
    NSString *namePath = [self currentFileName: @"wav"];
    
//    NSString *namePath = [NSString stringWithFormat:@"%@.wav",[[FMXmppManager defaultManager].xmppStream generateUUID]];
    return namePath;
}

/// 获取语音时长
+ (NSTimeInterval)durationWithVoiceURL:(NSURL *)voiceURL {
    NSDictionary *opt = [NSDictionary dictionaryWithObject:@(NO) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    // 初始化媒体文件
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:voiceURL options:opt];
    CMTime audioDuration = audioAsset.duration;
    // 获取总时长，单位秒
    NSTimeInterval second = CMTimeGetSeconds(audioDuration);
    
    return second;
}

/// 根据路径获取文件
+ (NSArray *)getAllDocumentFromFile {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *array = [manager contentsOfDirectoryAtPath:[self mainPathOfDocuments] error:&error];
    NSMutableArray *documents = [NSMutableArray array];
    
    for (NSString *path in array) {
        if (![path isEqualToString:@".DS_Store"]) {
            
            NSString *filePath = [self documentPathWithName:path];
            XZMediaModel *model = [[XZMediaModel alloc] init];
            model.mediaType = 3;
            model.mediaName = path;
            model.mediaSize = [self filesize:filePath];
            model.mediaPath = filePath;
            model.extension = [XZFileTools getTheSuffix:path];
            
            [documents addObject: model];
        }
    }
    return documents;
}

/// 获取后缀
+ (NSString *)getTheSuffix:(NSString *)fileName {
    
    NSArray *array = [fileName componentsSeparatedByString:@"."];
    
    NSString *suffix = (NSString *)array.lastObject;
    return suffix ? suffix : @"";
}

/// 文件路径
+ (NSString *)documentPathWithName:(NSString *)name {
    
    NSString *documentPath = [[self mainPathOfDocuments] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",name]];
    return documentPath;
}

/// 文件夹路径
+ (NSString *)mainPathOfDocuments {
    NSString *path = [[self getAppCacheDirectory] stringByAppendingString: kDocumentPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path]) {
        if (![manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil]) {
            
            Log(@"创建文件夹失败");
            return nil;
        }
    }
    return path;
}

/// 录音文件路径
+ (NSString *)recoderPathWithFileName:(NSString *)fileName {
    
    NSString *recoderPath = [[self mainPathOfRecorder] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
    return recoderPath;
}

/// 录音文件主路径
+ (NSString *)mainPathOfRecorder {
    NSString *path = [[self getAppCacheDirectory] stringByAppendingString: kRecorderPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path]) {
        if (![manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil]) {
            Log(@"创建文件夹失败");
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

/// 返回字节 == 文件大小的字节值
+ (CGFloat)fileSizeWithPath:(NSString *)path {
    if ([self fileExistsAtPath:path]) {
        NSDictionary *outputFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        return [outputFileAttributes fileSize]; //
    }else {
        return 0.0;
    }
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

+ (NSArray *)GetFilesListAtPath:(NSString *)dirPath withType:(NSString *)type
{
    //    NSMutableArray *filenamelist = [NSMutableArray arrayWithCapacity:10];
    NSURL *dirURL = [NSURL fileURLWithPath:dirPath];
    if (!dirURL) {
        Log(@"dirPath can not create URL!");
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

@end
