//
//  XZTakePictureTools.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/7/9.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XZTakePictureTools : NSObject

/// 使用代理创建图片选择器 WithDelegate:(id)delegate
- (void)createImagePickerCompletion:(void(^)(UIImagePickerController *imgPickerVc))completion;

/// 关闭图片选择
@property (nonatomic, copy) void(^blockDissmiss)(NSString *imgPath,UIImage *saveImg);
@end
