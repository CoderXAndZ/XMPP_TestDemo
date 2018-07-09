//
//  XZDownloadManager.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/7/3.
//  Copyright © 2018年 XZ. All rights reserved.
//  文件下载

#import "XZDownloadManager.h"
#import <AFNetworking/AFNetworking.h>
#import "XZFileTools.h"

@implementation XZDownloadManager

/// 根据URL下载语音 (void (^)(NSProgress *downloadProgress)) downloadProgressBlock
+ (void)downloadAudioWithURL:(NSString *)urlStr completion:(void(^)(NSURL *url, CGFloat progressValue))completion {
    // 1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 取消证书验证 ==========
    AFSecurityPolicy *security = [AFSecurityPolicy defaultPolicy];
    // 客户端信任证书
    security.allowInvalidCertificates = YES;
    // 不在证书域字段验证域名
    security.validatesDomainName = NO;
    manager.securityPolicy = security;
    // ===========
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    __block CGFloat progress = 0.0;
    
    // 2.下载文件
    NSURLSessionDownloadTask *download = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        // 监听下载进度
        Log(@"下载进度 ==== %f", 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
        
        CGFloat progressDownload = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
        
        progress = progressDownload;
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        // ================
        NSURL *url = [NSURL fileURLWithPath:[XZFileTools recoderPathWithFileName:[NSString stringWithFormat:@"%@",response.suggestedFilename]]];
        // [response.suggestedFilename stringByReplacingOccurrencesOfString:@"WAV" withString:@"wav"]
        
        NSString *urlStr = [url.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        
//        Log(@"下载完的url是：========== %@ \n ==== targetPath:%@",url ,targetPath);
//
//        Log(@"\n urlStr:%@\n\n 修改完的url ===  %@\n",urlStr,[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]);
        
        // ================
        return [NSURL fileURLWithPath:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        NSURL *url = [NSURL fileURLWithPath:[XZFileTools recoderPathWithFileName:[NSString stringWithFormat:@"%@",response.suggestedFilename]]];
        
        NSString *urlStr = [url.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        
        NSURL *urlFinal = [NSURL fileURLWithPath:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        if (progress == 1) {
            completion(urlFinal, progress);
            
            Log(@"urlFinal = %@",urlFinal);
        }
        
        Log(@"filePath = %@",filePath);
    }];
    
    // 3.执行Task
    [download resume];
}

@end
