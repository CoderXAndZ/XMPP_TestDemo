//
//  XZVoicePlayer.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/29.
//  Copyright © 2018年 XZ. All rights reserved.
//  声音播放

#import "XZVoicePlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "XZDownloadManager.h"
#import "VoiceConverter.h"
#import "XZFileTools.h"

@interface XZVoicePlayer()<AVAudioPlayerDelegate>

@property (nonatomic,strong) AVAudioPlayer *player;

@property (nonatomic,copy) void(^progress)(CGFloat progress);

@property (nonatomic, strong) NSString *currentPath;
@end

@implementation XZVoicePlayer

+ (instancetype)shared {
    static XZVoicePlayer *player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[XZVoicePlayer alloc] init];
    });
    return player;
}

/// 通过地址播放，回调进度
- (void)playWithURLString:(NSString *)path  progress:(void(^)(CGFloat progress))progress {
    
    self.progress = progress;
    
    // 当点击了别的行，如果当前正在播放，取消当前行的播放
    // 不能使用当前路径判断，因为再次点击相同行的话，是同一个地址；
    if (![self.currentPath isEqualToString:path]) {
        [self stop];
        self.player = nil;
        self.currentPath = path;
    }else {
        if ([self isPlaying]) {
            [self stop];
            self.player = nil;
            self.currentPath = @"";
            return;
        }
    }
    
    NSArray *array = [path componentsSeparatedByString:@"/"];
    NSString *pathName = [array lastObject];
    NSString *voicePath = [XZFileTools recoderPathWithFileName:pathName];
    
    NSString *wavPath = [[voicePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
    
    // 播放本地音频
    if ([XZFileTools fileExistsAtPath:voicePath] || [XZFileTools fileExistsAtPath:wavPath]) {
    
        if ([voicePath containsString:@"amr"]) {
            // amr 转换成 wav
            if ([VoiceConverter ConvertAmrToWav:path wavSavePath:wavPath]) {
                Log(@"转化成功");
                // 移除 .amr 文件
                [XZFileTools removeFileAtPath: path];
            }
        }
        
        NSURL *url = [NSURL URLWithString: wavPath];
        
        [self playWithURL: url];
    }else { // 先下载到本地
//        @"https://60.208.74.58:8343/ptm-manage/ptmcall/ptmCdr/downloadRecord/187834/7854/9AE206D76D45108E1EB8219E846C65BC"
        [XZDownloadManager downloadAudioWithURL:path completion:^(NSURL *url, CGFloat progressValue, NSString *amrPath) {
            
            if (progressValue == 1) {
                
                NSString *wavPath = [amrPath stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"];
                
                if ([amrPath containsString:@"amr"]) {
                    // amr 转换成 wav
                    if ([VoiceConverter ConvertAmrToWav:amrPath wavSavePath:wavPath]) {
                        
                        Log(@"转化成功");
//                        // 移除 .amr 文件
//                        [XZFileTools removeFileAtPath: path];
                    }
                }
                
                NSURL *url = [NSURL URLWithString: wavPath];
                [self playWithURL: url];
            }
        }];
    }

}

/// 通过地址播放
- (void)playWithURL:(NSURL *)url {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        // 增加音量
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        NSError *error = nil;
        // 初始化播放器
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        // 设置属性
        self.player.numberOfLoops = 0; // 不循环
        self.player.delegate = self;
        self.player.meteringEnabled = YES; // 更新音频测量
        // 加载音频文件到缓存
        [self.player prepareToPlay];
        
        if (error) {
            Log(@"初始化播放器过程中发生错误，错误信息：%@",error.localizedDescription);
            if (self.progress) {
                self.progress(0);
            }
        }
        
        [self play];
    });
}

/// 播放
- (void)play {
    if (![self isPlaying]) {
        [self.player play];
    }
}

/// 暂停
- (void)pause {
    if ([self isPlaying]) {
        [self.player pause];
    }
}

/// 停止播放
- (void)stop {
    if ([self isPlaying]) {
        
        [self.player stop];
        
        _player.delegate = nil;
        _player = nil;
    }
}

/// 正在播放
- (BOOL)isPlaying {
    return [self.player isPlaying];
}

#pragma mark ---- AVAudioPlayerDelegate
/// 播放结束时执行的动作
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    Log(@"audioPlayerDidFinishPlaying");
    
    if (self.progress) {
        self.progress(1);
    }
    
    [self stop];
}

// 被来电打断,停止播放
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    [self pause];
}

// 被来电结束，继续播放
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {
    [self play];
}

/// 解码错误执行的动作
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    
    Log(@"audioPlayerDecodeErrorDidOccur");
    
    if (self.progress) {
        self.progress(0);
    }
}

@end
