//
//  XZVoiceProgress.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/28.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XZMacroDefinition.h"

@interface XZVoiceProgress : UIView

@property (nonatomic, assign) CGFloat progress;

/// 时间倒计时
@property (nonatomic, strong) NSString *time;

// 是否隐藏
@property (nonatomic, assign) BOOL isHidden;

@property (nonatomic, assign) XZVoiceRecordState voiceRecordState;

@end
