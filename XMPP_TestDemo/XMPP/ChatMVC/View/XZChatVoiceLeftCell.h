//
//  XZChatVoiceLeftCell.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/27.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import "XZChatBaseCell.h"

@class XZChatVoiceLeftCell;
@protocol XZChatVoiceLeftCellDelegate<NSObject>

/// 通过路径播放声音
- (void)playWithVoicePath:(NSString *)path cell:(XZChatVoiceLeftCell *)cell;

@end

@class XZChatModel;
@interface XZChatVoiceLeftCell : XZChatBaseCell

@property (nonatomic, weak) id<XZChatVoiceLeftCellDelegate> delegate;

/** model */
@property (nonatomic, strong) XZChatModel *modelChat;

/** 播放完成 */
@property (nonatomic, assign) BOOL isCompletedPlay;
@end
