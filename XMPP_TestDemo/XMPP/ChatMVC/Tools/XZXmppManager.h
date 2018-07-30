//
//  XZXmppManager.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/7/23.
//  Copyright © 2018年 XZ. All rights reserved.
//

#define XMPP_HOST_IP  @"kefu.rongtuojinrong.com"//@"192.168.1.114"//@"qq.rt.com"
#define XMPP_HOST_NAME  @"kefu.rongtuojinrong.com" //@"qq.rt.com"//@"192.168.1.115"
#define XMPP_HOST_PORT  @"5222"
#define XMPP_HOST_RESOURCE @"iPhone"


#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

@interface XZXmppManager : NSObject

#pragma mark ---- XMPP相关
/** 通信管道，输入输出流 */
@property(nonatomic, strong) XMPPStream *xmppStream;
/** 断线重连 */
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;
/** 流管理模块 */
//@property (nonatomic, strong) XMPPStreamManagementMemoryStorage *xmppMemoryStorage;
@property (nonatomic, strong) XMPPStreamManagement *xmppStreamManagement;
/** 消息归档 - 核心数据存储 */
@property (nonatomic, strong) XMPPMessageArchivingCoreDataStorage *xmppMsgAchivingCoreDataStorage;
/** 消息归档 */
@property (nonatomic, strong) XMPPMessageArchiving *xmppMsgAchiving;
/** 信息归档的上下文 */
//@property(nonatomic, strong) NSManagedObjectContext *xmppMsgArchivingContext;

@end
