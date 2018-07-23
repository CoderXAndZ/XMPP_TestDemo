//
//  XZTakePictureTools.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/7/9.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 将 PHAsset 转化成图片的结果回调
typedef void(^BlockResult)(NSData *data,NSString *originalFilename);
/// 将 PHAsset 转化成视频的结果回调
typedef void(^ResultPath)(NSString *filePath, NSString *fileName);

@interface XZTakePictureTools : NSObject

/// 使用代理创建图片选择器
- (void)createImagePickerCompletion:(void(^)(UIImagePickerController *imgPickerVc))completion;
/// 相册方法
- (void)selectPhotoFromAlbumWithMaxCount:(NSInteger)maxCount controller:(UIViewController *)controller completion:(void(^)(NSMutableArray *photos))completion;

/// 关闭图片选择
@property (nonatomic, copy) void(^blockDissmiss)(NSString *imgPath,UIImage *saveImg);

// 图片
@property (nonatomic, copy) BlockResult BlockResult;
// 视频
@property (nonatomic, copy) ResultPath ResultPath;

@end
