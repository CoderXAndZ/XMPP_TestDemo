//
//  XZChatTimeOrStatusLabel.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/26.
//  Copyright © 2018年 XZ. All rights reserved.
//  聊天时间或聊天状态label

#import "XZChatTimeOrStatusLabel.h"

@implementation XZChatTimeOrStatusLabel

- (void)setTextStr:(NSString *)textStr {
    _textStr = textStr;
    
}

- (NSInteger)numberOfLines {
    return 2;
}

@end
