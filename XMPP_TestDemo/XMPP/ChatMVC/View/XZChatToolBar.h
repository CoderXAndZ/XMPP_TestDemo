//
//  XZChatToolBar.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/27.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, XZVoiceRecordState)
{
    XZVoiceRecordState_Normal,          // 初始状态
    XZVoiceRecordState_Recording,       // 正在录音
    XZVoiceRecordState_ReleaseToCancel, // 上滑取消（也在录音状态，UI显示有区别）
    XZVoiceRecordState_RecordCounting,  // 最后10s倒计时（也在录音状态，UI显示有区别）
    XZVoiceRecordState_RecordTooShort,  // 录音时间太短（录音结束了）
};

@class XZChatToolBar;
@protocol XZChatToolBarDelegate <NSObject>
@required
/// 开始录音
- (void)didStartRecordingVoice;
/// 结束录音
- (void)didStopRecordingVoice;
/// 取消录音
- (void)didCancelRecordingVoice;
/// 录音时拖拽是否在按钮内部
- (void)didDragInside:(BOOL)inside;

/// 点击发送按钮
- (void)didClickSendBtn:(NSString *)text;

//@optional
///// 根据键盘是否弹起，设置 tableView frame
//- (void)toolBar:(XZChatToolBar *)toolBar changeDuration:(CGFloat)duration;

@end

@interface XZChatToolBar : UIView

/** delegate */
@property (nonatomic, weak) id<XZChatToolBarDelegate> delegate;

/// 最大显示行
@property (nonatomic, assign) int maxNumberOfLines;

/***
 * viewController: 当前视图所在的控制器
 * aboveView 在控制的view中，位于当前视图上方的视图，用于设置aboveView的滚动
 */
- (instancetype)initWithViewController:(UIViewController <XZChatToolBarDelegate>*)viewController aboveView:(UIView *)aboveView;

/// 点击“转人工”和“发送”按钮,
@property (nonatomic, copy) void(^blockDidClickButton)(NSInteger);
/// 点击“+”按钮视图
@property (nonatomic, copy) void(^blockClickedKeyboardInputView)(NSInteger,BOOL isRobot);

/** keyboardNotification */
@property (nonatomic, copy) void(^blockKeyboardWillChange)(NSNotification *noti);

@end
