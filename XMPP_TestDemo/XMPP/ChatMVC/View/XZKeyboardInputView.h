//
//  XZKeyboardInputView.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/7/5.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XZKeyboardInputView : UIView

/// 点击页面
@property (nonatomic, copy) void(^blockClickKeyboardInputViewBtn)(NSInteger tag);

/** 是机器人聊天界面 */
@property (nonatomic, assign) BOOL isRobot;

@end
