//
//  XZChatBaseCell.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/26.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XZChatBaseCell : UITableViewCell
/// 时间
@property (nonatomic, strong) UILabel *labelTime;
//// 用户头像
@property (nonatomic, strong) UIImageView *imgIcon;
/// 方向 0-右侧 1-左侧
@property (nonatomic, assign) int direction;

/// 设置子视图的布局
- (void)setupCommonConstraints;
@end
