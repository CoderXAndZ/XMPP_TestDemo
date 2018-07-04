//
//  XZChatVoiceRightCell.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/7/4.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import "XZChatBaseCell.h"

@class XZChatVoiceRightCell;
@protocol XZChatVoiceRightCellDelegate<NSObject>

/// 通过路径播放声音
- (void)playWithVoicePath:(NSString *)path cell:(XZChatVoiceRightCell *)cell;

@end

@class XZChatModel;
@interface XZChatVoiceRightCell : XZChatBaseCell

@property (nonatomic, weak) id<XZChatVoiceRightCellDelegate> delegate;

/** model */
@property (nonatomic, strong) XZChatModel *modelChat;

/** 播放完成 */
@property (nonatomic, assign) BOOL isCompletedPlay;

@end
