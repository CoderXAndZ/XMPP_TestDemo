//
//  XZXMPPManager.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/21.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef  enum : NSUInteger {
    ConnectServerPurposeLogin,
    ConnectServerPurposeRegister
}ConnectServerPurpose;

@class XMPPStream;
@interface XZXMPPManager : NSObject
/// 连接服务器的目的
@property (nonatomic, assign) ConnectServerPurpose connectServerPurposeType;

/// 通信管道，输入输出流
@property (nonatomic, strong) XMPPStream *xmppStream;

/// 单例
+ (XZXMPPManager *)defaultManager;
/// 注销
- (void)logout;
/// 登录
- (void)loginWithName:(NSString *)userName password:(NSString *)password;
/// 注册
-(void)registerWithName:(NSString *)userName andPassword:(NSString *)password;

@end
