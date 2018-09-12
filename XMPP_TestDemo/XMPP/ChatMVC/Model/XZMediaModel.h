//
//  XZMediaModel.h
//  XMPP_TestDemo
//
//  Created by admin on 2018/7/11.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PHAsset;
@interface XZMediaModel : NSObject
/** 媒体类型
 FMFileManangerOSSFileTypeVoice    = 0,    // 声音
 FMFileManangerOSSFileTypeVideo    = 1,    // 视频
 FMFileManangerOSSFileTypeImage    = 2,    // 图片
 FMFileManangerOSSFileTypeFIle     = 3,    // 文件
 FMFileManangerOSSFileTypeOther    = 4     // 其他
 */
@property (nonatomic, assign) int mediaType;
/** 媒体名字 */
@property (nonatomic, copy) NSString *mediaName;
/** 媒体路径 */
@property (nonatomic, copy) NSString *mediaPath;
/** 媒体照片 */
@property (nonatomic, strong) UIImage *image;
/** 媒体后缀 png、wav、MP4... */
@property (nonatomic, copy) NSString *extension;
/** 媒体照片大小 */
@property (nonatomic, assign) CGSize imageSize;

/** 视频/声音 时长 */
@property (nonatomic, assign) NSTimeInterval mediaDuration;
/** 视频的NSData数据 */
@property (nonatomic, strong) NSData *mediaData;
/** 视频的第一帧图片 */
@property (nonatomic, strong) UIImage *firstImage;
/** 视频的第一帧图片的data数据 */
@property (nonatomic, strong) NSData *dataOfFirstImg;
/** iOS8 之后的媒体属性 */
@property (nonatomic, strong) PHAsset *asset;

/** 文件大小 */
@property (nonatomic, copy) NSString *mediaSize;
/** 是否被选中 */
@property (nonatomic, assign) BOOL isSelected;

@end
