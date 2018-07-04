//
//  XZChatToolBar.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/27.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import <UIKit/UIKit.h>

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

@end

@interface XZChatToolBar : UIView

/** delegate */
@property (nonatomic, weak) id<XZChatToolBarDelegate> delegate;

@end
