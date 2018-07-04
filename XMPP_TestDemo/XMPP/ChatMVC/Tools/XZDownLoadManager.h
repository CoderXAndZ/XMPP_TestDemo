//
//  XZDownloadManager.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/7/3.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XZDownloadManager : NSObject
/// 根据URL下载语音
/***
 * urlStr:              需要下载的文件链接
 * completion:
 *      url:            下载完的文件存放地址
 *      progressValue : 下载的进度
*/
+ (void)downloadAudioWithURL:(NSString *)urlStr completion:(void(^)(NSURL *url, CGFloat progressValue))completion;

@end
