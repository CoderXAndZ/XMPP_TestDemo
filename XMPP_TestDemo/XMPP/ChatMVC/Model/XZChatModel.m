//
//  XZChatModel.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/27.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import "XZChatModel.h"
#import "XZFileTools.h"

@interface XZChatModel()
{
    NSString *_chatTime;
    NSString *_chatContent;
}
@end

@implementation XZChatModel

//- (void)setChatTime:(NSString *)chatTime {
//    _chatTime = chatTime;
//}

- (NSString *)audioPath {
    NSString *path = [XZFileTools recoderPathWithFileName:@"1530602004.wav"];
    return path;
}

- (NSUInteger)audioDurations {
    NSString *path = [XZFileTools recoderPathWithFileName:@"1530602004.wav"];
    NSUInteger duration = [XZFileTools durationWithVoiceURL:[NSURL fileURLWithPath:path]];
    return duration;
}

- (NSString *)chatContent {
    _chatContent = @"嗯嗯，好的呢，知道了，以后会注意好的，谢谢，哈哈哈，登录好了之后再来找我吧，你有什么不懂得吧，自己去自学一下，去App学习一下吧";
    return _chatContent;
}

- (NSString *)chatTime {
    _chatTime = @"2018-06-26 16:07:46";
    return _chatTime;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

@end
