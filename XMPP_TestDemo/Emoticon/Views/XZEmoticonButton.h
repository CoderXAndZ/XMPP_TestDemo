//
//  XZEmoticonButton.h
//  表情键盘
//
//  Created by XZ on 16/3/5.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XZEmoticon;

/// 表情按钮
@interface XZEmoticonButton : UIButton

+ (nonnull instancetype)emoticonButtonWithFrame:(CGRect)frame tag:(NSInteger)tag;
/// 是否删除按钮
@property (nonatomic, getter=isDeleteButton) BOOL deleteButton;
/// 表情模型
@property (nonatomic, nullable) XZEmoticon *emoticon;

@end
