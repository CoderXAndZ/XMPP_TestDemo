//
//  XZChatModel.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/27.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XZChatModel : NSObject

/** cell方向：0 - 右侧 1 - 左侧 */
@property (nonatomic, assign) int direction;

/** 聊天内容 */
@property (nonatomic, copy) NSString *chatContent;

/** 聊天时间 */
@property (nonatomic, copy) NSString *chatTime;

/** 聊天图片 */
@property (nonatomic, copy) NSString *imgUrl;

/** 语音路径 */
@property (nonatomic, copy) NSString *audioPath;

/** 语音时长 */
@property (nonatomic, assign) NSUInteger audioDurations;

/** 当前行的点击状态 */
@property (nonatomic, assign) BOOL isSelected;

@end
