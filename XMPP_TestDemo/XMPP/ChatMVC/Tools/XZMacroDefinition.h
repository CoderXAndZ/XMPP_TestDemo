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

/// 办公文件目录
#define XZOfficeDir [XZChatLogDir stringByAppendingPathComponent:@"OfficeDoc"]

/// 录制音频
#define kRecorderPath @"Chat/Recorder" /// 存储位置
#define kRecorderType @".wav"  /// 录音的格式
#define kAMRType @"amr"   /// 需要的格式

#endif /* XZMacroDefinition_h */
