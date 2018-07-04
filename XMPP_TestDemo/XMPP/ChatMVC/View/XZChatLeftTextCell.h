//
//  XZChatLeftTextCell.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/26.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import "XZChatBaseCell.h"

@class XZChatModel;
@interface XZChatLeftTextCell : XZChatBaseCell

///// 计算cell的高度
//- (CGFloat)calculateCellHeight;

/** model */
@property (nonatomic, strong) XZChatModel *modelChat;

@end
