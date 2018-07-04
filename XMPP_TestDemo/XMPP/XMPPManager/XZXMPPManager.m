//
//  XZXMPPManager.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/21.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import "XZXMPPManager.h"
#import "XMPPFramework.h"

NSString *const HOSTPORT = @"5222";
NSString *const HOSTNAME = @"39.107.124.1";
NSString *const DOMAINTEXT = @"qq.rt.com";

@interface XZXMPPManager()<XMPPStreamDelegate>
/// 密码
@property (nonatomic, strong) NSString *password;
@end

@implementation XZXMPPManager
/// 单例
+ (XZXMPPManager *)defaultManager {
    static XZXMPPManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XZXMPPManager alloc] init];
    });
    return manager;
}

/// 设置XMPPStream
- (instancetype)init {
    if ([super init]){
        /// 初始化xmppStream
        self.xmppStream = [[XMPPStream alloc] init];
        /// 设置服务器地址
        self.xmppStream.hostName = HOSTNAME;
        /// 设置端口号 5222 9090
        self.xmppStream.hostPort =  [[NSString stringWithFormat:@"%@",HOSTPORT] intValue];
        ///  设置代理
        [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

/// 注销
- (void)logout {
    // 离线不可用
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    // 向服务器发送离线消息
    [self.xmppStream sendElement:presence];
    // 断开连接
    [self.xmppStream disconnect];
}

/// 登录
- (void)loginWithName:(NSString *)userName password:(NSString *)password {
    // 标记连接服务器的目的
    self.connectServerPurposeType = ConnectServerPurposeLogin;
    //
    self.password = password;
    // 创建 xxmppjid（用户0,  @param NSString 用户名，域名，登录服务器的方式（苹果，安卓等）
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:HOSTNAME resource:@"iPhone8"];
    self.xmppStream.myJID = jid;
    // 连接到服务器
    [self connectToServer];
}

/// 连接到服务器
- (void)connectToServer {
    // 如果已存在一个连接，需要断开当前的链接，然后再开始新的链接
    if ([self.xmppStream isConnected]) {
        [self logout];
    }
    NSError *error = nil;
    [self.xmppStream connectWithTimeout:30.0f error:&error];
    if (error) {
        NSLog(@"error = %@",error);
    }
}

/// 注册
-(void)registerWithName:(NSString *)userName andPassword:(NSString *)password {
    self.password = password;
    //0.标记连接服务器的目的
    self.connectServerPurposeType = ConnectServerPurposeRegister;
    //1. 创建一个jid
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:HOSTNAME resource:@"iPhone8"];
    //2.将jid绑定到xmppStream
    self.xmppStream.myJID = jid;
    //3.连接到服务器
    [self connectToServer];
    
}

#pragma mark --- 代理
/// 连接服务器失败
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender {
    NSLog(@"连接服务器失败的方法，请检查网络是否正常");
}

/// 服务器连接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"连接服务器成功的方法");
    //登录
    if (self.connectServerPurposeType == ConnectServerPurposeLogin) {
        NSError *error = nil;
        //向服务器发送密码验证 //验证可能失败或者成功
        [sender authenticateWithPassword:self.password error:&error];
    }
    //注册
    else{
        //向服务器发送一个密码注册（成功或者失败）
        [sender registerWithPassword:self.password error:nil];
    }
}


/// 验证成功的方法
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"验证成功的方法");
    /**
     *  unavailable 离线
     available  上线
     away  离开
     do not disturb 忙碌
     */
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [self.xmppStream sendElement:presence];
}

/// 验证失败的方法
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    NSLog(@"验证失败的方法,请检查你的用户名或密码是否正确,%@",error);
}

/// 注册成功的方法
-(void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"注册成功的方法");
}

/// 注册失败的方法
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    NSLog(@"注册失败执行的方法");
}


@end
