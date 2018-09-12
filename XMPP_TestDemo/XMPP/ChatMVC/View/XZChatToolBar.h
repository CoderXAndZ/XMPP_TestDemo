//
//  XZChatToolBar.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/27.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XZChatToolBar,XZMediaModel;
@protocol XZChatToolBarDelegate <NSObject>
@required
/// 结束录音
- (void)didStopRecordingVoice:(XZMediaModel *)mediaModel;
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

/// 点击“转人工”和“发送”按钮,  text用户输入数据
@property (nonatomic, copy) void(^blockDidClickButton)(NSInteger,NSString *text);

/// 点击“+”按钮视图
@property (nonatomic, copy) void(^blockClickedKeyboardInputView)(NSInteger,BOOL isRobot);

/** keyboardNotification */
@property (nonatomic, copy) void(^blockKeyboardWillChange)(NSNotification *noti);

/** 将toolbar的高度传递给控制器，修改tableView */
@property (nonatomic, copy) void(^blockTextViwDidChanged)(CGFloat height);

// 转人工成功
@property (nonatomic, assign) BOOL transferSuccessed;
///
- (void)destroyToolBar;

/// 添加 3 分钟页面到视图，将toolBar还原到初始状态
- (void)initializeToolBar;
@end
