//
//  XZAfterThreeMinutesView.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/7/9.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XZAfterThreeMinutesView : UIView

/// 点击页面
@property (nonatomic, copy) void(^blockClickAfterThreeMBtn)(NSInteger tag);

@end
