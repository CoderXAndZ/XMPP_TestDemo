//
//  XZMacroDefinition.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/28.
//  Copyright © 2018年 XZ. All rights reserved.
//

#ifndef XZMacroDefinition_h
#define XZMacroDefinition_h

/// document目录
#define XZDocumentDir [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

/// cache目录
#define XZCacheDir [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

/// 用户目录(包含聊天目录)
#define XZUserDir [XZDocumentDir stringByAppendingPathComponent:@"1"]

/// 聊天目录 (包括:聊天目录 + 语音目录 + 办公文件目录)
#define XZChatLogDir [XZUserDir stringByAppendingPathComponent:@"ChatLog"]

// 语音目录
#define XZChatRecordDir [XZChatLogDir stringByAppendingPathComponent:@"RecordChat"]

/// 录制音频
#define kRecorderPath @"Chat/Recorder" /// 存储位置
#define kRecorderType @".wav"  /// 录音的格式
#define kAMRType @"amr"   /// 需要的格式

// 文件路径
#define kDocumentPath @"Chat/document" /// 存储位置

/// 工具栏高度
#define XZChatToolBarHeight 55

typedef NS_ENUM(NSInteger, XZVoiceRecordState)
{
    XZVoiceRecordState_Normal,          // 初始状态
    XZVoiceRecordState_Recording,       // 正在录音
    XZVoiceRecordState_ReleaseToCancel, // 上滑取消（也在录音状态，UI显示有区别）
    XZVoiceRecordState_RecordCounting,  // 最后10s倒计时（也在录音状态，UI显示有区别）
    XZVoiceRecordState_RecordTooShort,  // 录音时间太短（录音结束了）
};

#endif /* XZMacroDefinition_h */
