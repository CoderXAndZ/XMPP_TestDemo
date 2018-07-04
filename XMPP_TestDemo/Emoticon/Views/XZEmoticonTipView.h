//
//  XZEmoticonTipView.h
//  表情键盘
//
//  Created by XZ on 16/3/5.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XZEmoticon;

/// 表情提示视图
@interface XZEmoticonTipView : UIImageView
/// 表情模型
@property (nonatomic, nullable) XZEmoticon *emoticon;
@end
