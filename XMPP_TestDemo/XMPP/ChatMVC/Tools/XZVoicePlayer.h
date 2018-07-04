//
//  XZVoicePlayer.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/29.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XZVoicePlayer : NSObject

+ (instancetype)shared;
/// 停止播放
- (void)stop;
/// 正在播放
- (BOOL)isPlaying;

/// 根据路径播放语音，回调进度
- (void)playWithURLString:(NSString *)path progress:(void(^)(CGFloat progress))progress;

@end
