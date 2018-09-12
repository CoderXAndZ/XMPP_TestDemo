//
//  XZDownloadManager.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/7/3.
//  Copyright © 2018年 XZ. All rights reserved.
//  文件下载

#import "XZDownloadManager.h"
#import "XZFileTools.h"

@implementation XZDownloadManager

/// 根据URL下载语音
+ (void)downloadAudioWithURL:(NSString *)urlStr completion:(void(^)(NSURL *url, CGFloat progressValue, NSString *amrPath))completion {
    
    // 1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
//    // 取消证书验证 ==========
//    AFSecurityPolicy *security = [AFSecurityPolicy defaultPolicy];
//    // 客户端信任证书
//    security.allowInvalidCertificates = YES;
//    // 不在证书域字段验证域名
//    security.validatesDomainName = NO;
//    manager.securityPolicy = security;
//    // ===========
    NSString *utf8Str = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString: utf8Str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    __block CGFloat progress = 0.0;
    
    // 2.下载文件
    NSURLSessionDownloadTask *download = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        // 监听下载进度
        Log(@"下载进度 ==== %f", 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
        
        CGFloat progressDownload = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
        
        progress = progressDownload;
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSURL *url = [NSURL fileURLWithPath:[XZFileTools recoderPathWithFileName:[NSString stringWithFormat:@"%@",response.suggestedFilename]]];
        
        Log(@"下载完的url是：========== %@ \n ==== response.suggestedFilename:%@",url ,response.suggestedFilename);
        return url;
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        NSString *amrPath = [XZFileTools recoderPathWithFileName:[NSString stringWithFormat:@"%@",response.suggestedFilename]];
       
        NSURL *url = [NSURL fileURLWithPath: amrPath];
        
        if (progress == 1) {
            completion(url, progress,amrPath);
            
            Log(@"urlFinal = %@",url);
        }
        
        Log(@"filePath = %@ ===== url:%@",filePath, url);
    }];
    
    // 3.执行Task
    [download resume];
}

@end
