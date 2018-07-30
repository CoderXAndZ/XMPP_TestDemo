//
//  XZXmppManager.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/7/23.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import "XZXmppManager.h"

@implementation XZXmppManager

#pragma mark ---- 单例方法实现
- (instancetype)init {
    if (self = [super init]) {
        // XMPPStream 初始化,登录/注册使用
        self.xmppStream = [[XMPPStream alloc] init];
        // 设置服务器地址
        self.xmppStream.hostName = XMPP_HOST_NAME;
        // 设置端口号
        self.xmppStream.hostPort = [XMPP_HOST_PORT intValue];
        // 设置代理
        [self.xmppStream addDelegate:self delegateQueue: dispatch_get_main_queue()];
        [self.xmppStream setKeepAliveInterval: 30];
//        self.xmppStream.enableBackgroundingOnSocket = YES;
        
        // 断线重连 XMPPReconnect
        self.xmppReconnect = [[XMPPReconnect alloc] init];
        [self.xmppReconnect setAutoReconnect:YES];
        [self.xmppReconnect activate:self.xmppStream];
        
        // 流管理模块
        XMPPStreamManagementMemoryStorage *xmppMemoryStorage = [[XMPPStreamManagementMemoryStorage alloc] init];
        self.xmppStreamManagement = [[XMPPStreamManagement alloc] initWithStorage: xmppMemoryStorage];
        self.xmppStreamManagement.autoResume = YES;
        [self.xmppStreamManagement addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [self.xmppStreamManagement activate: self.xmppStream];
        
        // 消息模块
        self.xmppMsgAchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        // ========= dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 9)
        self.xmppMsgAchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:self.xmppMsgAchivingCoreDataStorage dispatchQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 9)];
        // 激活
        [self.xmppMsgAchiving activate: self.xmppStream];
//        // 上下文
//        self.xmppMsgArchivingContext = _xmppMessageArchivingCoreDataStorage.mainThreadManagedObjectContext;
        
    }
    return self;
}

+ (instancetype)defaultManager {
    
    static XZXmppManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XZXmppManager alloc] init];
    });
    return manager;
}


@end
