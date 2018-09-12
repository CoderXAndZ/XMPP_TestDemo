//
//  XZTakePictureTools.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/7/9.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XZMediaModel;
/// 将 PHAsset 转化成模型的结果回调
typedef void(^BlockResultMediaModel)(NSMutableArray *mediaModels);

@interface XZTakePictureTools : NSObject

/// 使用代理创建图片选择器
- (void)createImagePickerCompletion:(void(^)(UIImagePickerController *imgPickerVc))completion;
/// 相册方法
- (void)selectPhotoFromAlbumWithMaxCount:(NSInteger)maxCount controller:(UIViewController *)controller completion:(void(^)(NSMutableArray *photos))completion;
/// 获取视频的第一帧
- (UIImage *)getVideoFirstImage:(NSURL *)url;

/// 关闭图片选择
@property (nonatomic, copy) void(^blockDissmiss)(XZMediaModel *modelMedia);

/// 图片或者视频对象
@property (nonatomic, copy) BlockResultMediaModel BlockResultMediaModel;

@end
