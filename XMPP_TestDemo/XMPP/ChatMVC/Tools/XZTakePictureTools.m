//
//  XZTakePictureTools.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/7/9.
//  Copyright © 2018年 XZ. All rights reserved.
//  拍照

#import "XZTakePictureTools.h"
#import "TZImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
// #import <Photos/Photos.h>
//#import "FMFileManangerOSS.h" // 文件存取
#import "XZMediaModel.h" // 图片、视频model
//#import "FMXmppManager.h"
#import "XZFileTools.h"

@interface XZTakePictureTools()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,TZImagePickerControllerDelegate>
{
    NSMutableArray *_selectedAssets; // 选中图片
    NSMutableArray *_selectedPhotos; // 选中图片
    BOOL _isSelectOriginalPhoto; // 是否选择原图
}
// 拍照工具类
 @property (nonatomic, strong) UIImagePickerController *imagePickerVc;
// 图片存储路径
@property (nonatomic, strong) NSString *imageFilePath;
// 模型数组
@property (nonatomic, strong) NSMutableArray *arrayMediaModel;
@end

@implementation XZTakePictureTools
#pragma mark ---- 相册方法
- (void)selectPhotoFromAlbumWithMaxCount:(NSInteger)maxCount controller:(UIViewController *)controller completion:(void(^)(NSMutableArray *photos))completion {
    
    TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initWithMaxImagesCount:maxCount delegate:self];
    // 写上这一句，用户再次点击进入的时候上次选中的图片也是选中状态；
//    imagePicker.selectedAssets = _selectedAssets;
//    imagePicker.isSelectOriginalPhoto = YES;
    imagePicker.allowPickingMultipleVideo = YES;
    imagePicker.allowTakePicture = NO;
    imagePicker.allowTakeVideo = NO;
    
    self.BlockResultMediaModel = completion;
    
    [controller presentViewController:imagePicker animated:YES completion:nil];
}

/// 用户选择好了图片，如果assets非空，则用户选择了原图 。
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    
    [self.arrayMediaModel removeAllObjects];
    
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    
    // 1.打印媒体文件名字
    NSString *fileName = [self printAssetsName:assets];
    
    // 文件后缀名
    NSString *suffix = [XZFileTools getTheSuffix:fileName];
    
    FMWeakSelf;
    // 2.图片位置信息
    if (iOS8Later) {
        for (int i = 0; i < assets.count; i++) {
            PHAsset *phAsset = assets[i];
            // 将视频存储到指定目录下
            NSString *savedPath = [NSString stringWithFormat:@"%@/%@/%@",[XZFileTools getAppCacheDirectory],@"Medias",[XZFileTools currentFileName:suffix]];
            
//            [FMFileManangerOSS getANewPathWithFileType:FMFileManangerOSSFileTypeVideo withSuffix:suffix];
            
            XZMediaModel *modelMedia = [[XZMediaModel alloc] init];
            
            if (phAsset.mediaType == PHAssetMediaTypeVideo) {// 视频
                
                [[TZImageManager manager] getVideoWithAsset:phAsset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
                    
                    NSURL *url = [playerItem valueForKey:@"URL"];
                    // 视频转码并存储
                    [weakSelf convertVideoWithURL:url outputPath:savedPath model:modelMedia assets: assets];
                    // 给model赋值
                    modelMedia.mediaType = 1;
                    modelMedia.mediaPath = savedPath;
                    modelMedia.mediaName = fileName;
                    modelMedia.asset = phAsset;
                    modelMedia.mediaDuration = phAsset.duration;
                    modelMedia.extension = @"mp4";
                }];
                
            }else { // 图片
                [[TZImageManager manager] getPhotoWithAsset:phAsset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                    
                    NSDictionary *dict = infos[i];
                    
                    NSString *imagePath = [NSString stringWithFormat:@"%@",dict[@"PHImageFileURLKey"]];
                    
                    // 给model赋值
                    modelMedia.image = photo;
                    modelMedia.mediaPath = [imagePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                    modelMedia.imageSize = photo.size;
                    modelMedia.mediaType = 2;
                    modelMedia.mediaName = fileName;
                    modelMedia.asset = phAsset;
                    modelMedia.mediaDuration = phAsset.duration;
                    
                    // 图片data数据
                    [[PHImageManager defaultManager] requestImageDataForAsset:phAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                        
                        Log(@"dataUTI ==== %@",dataUTI);
                        if ([dataUTI isEqualToString:@"public.heif"] || [dataUTI isEqualToString:@"public.heic"]) {

                            CIImage *ciimage = [CIImage imageWithData:imageData];
                            CIContext *context = [CIContext context];
                            NSData *jpgData = [context JPEGRepresentationOfImage:ciimage colorSpace:ciimage.colorSpace options:@{}];
                            modelMedia.mediaData = jpgData;
                            modelMedia.extension = @"jpeg";
//                            Log(@"modelMedia.extension ==== %@",modelMedia.extension);
//                            modelMedia.mediaData = imageData;
                        }else {
                            modelMedia.mediaData = imageData;
                            modelMedia.extension = suffix;
                        }
                     
                        [weakSelf.arrayMediaModel addObject: modelMedia];
                        // 回调数据
                        if (weakSelf.arrayMediaModel.count == assets.count) {
                            if (weakSelf.BlockResultMediaModel) {
                                weakSelf.BlockResultMediaModel(weakSelf.arrayMediaModel);
                            }
                        }
                    }];
                }];
            }
        }
    }
}

///// 获取图片的data值
//- (void)getImageDataFromPHAsset:(PHAsset *)phAsset modelMedia:(XZMediaModel *)modelMedia {
//    [[PHImageManager defaultManager] requestImageDataForAsset:phAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//
//        modelMedia.mediaData = imageData;
//    }];
//}

/// 视频转码为MP4
- (void)convertVideoWithURL:(NSURL *)url outputPath:(NSString *)outputPath model:(XZMediaModel *)model assets:(NSArray *)assets {
    // 获取视频的第一帧
    UIImage *firstImg = [self getVideoFirstImage:url];
    model.firstImage = firstImg;
    
    // 第一帧图片的data数据
    NSData *data = UIImagePNGRepresentation(firstImg);
    model.dataOfFirstImg = data;
    
    // 输出
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options: nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputURL = [NSURL fileURLWithPath:outputPath];
    exportSession.outputFileType = AVFileTypeMPEG4;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        int exportStatus = exportSession.status;
        switch (exportStatus) {
            case AVAssetExportSessionStatusFailed:
            {
                NSError *exportError = exportSession.error;
                Log(@"AVAssetExportSessionStatusFailed: %@",exportError);
                break;
            }
            case AVAssetExportSessionStatusCompleted:
            {
                Log(@"视频转码成功");
                NSData *data = [NSData dataWithContentsOfFile:outputPath];
                model.mediaData = data;
                
                [self.arrayMediaModel addObject: model];
                
                // 回调数据
                if (self.arrayMediaModel.count == assets.count) {
                    if (self.BlockResultMediaModel) {
                        self.BlockResultMediaModel(self.arrayMediaModel);
                    }
                }
            }
            default:
                break;
        }
        
    }];
}

/// 获取视频的第一帧
- (UIImage *)getVideoFirstImage:(NSURL *)url {
    // 转码配置
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:opts];
    // 视频生成第一帧
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(1000, 1000);
    NSError *error = nil;
    CGImageRef image = [generator copyCGImageAtTime:CMTimeMake(0, 10) actualTime:NULL error:&error];
    UIImage *firstImg = [UIImage imageWithCGImage:image];
    return firstImg;
}

/// 打印媒体资源名字
- (NSString *)printAssetsName:(NSArray *)assets {
    
    NSString *fileName;
    for (id asset in assets) {
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = (PHAsset *)asset;
            fileName = [phAsset valueForKey:@"filename"];
        } else if ([asset isKindOfClass:[ALAsset class]]) {
            ALAsset *alAsset = (ALAsset *)asset;
            fileName = alAsset.defaultRepresentation.filename;;
        }
    }
    return fileName;
}

#pragma mark ---- 拍照代理方法 - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    NSString *fileName = [NSString stringWithFormat:@"image6.png"];
    // 当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        // 先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        NSData *data = UIImagePNGRepresentation(image);
        
        if (data == nil) {
            data = UIImageJPEGRepresentation(image, 1.0);
        }else {
            data = UIImagePNGRepresentation(image);
        }
        
        if (data) {
            // 图片保存的路径 =================
            // 这里将图片放在沙盒的documents文件夹中
            NSString *DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            // 文件管理器
            NSFileManager *fileManager = [NSFileManager defaultManager];
            // 把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
            [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
            [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:[NSString stringWithFormat:@"/%@",fileName]] contents:data attributes:nil];
            // 得到选择后沙盒中图片的完整路径
            NSString *imageFilePath = [[NSString alloc]initWithFormat:@"%@%@",DocumentsPath,  [NSString stringWithFormat:@"/%@",fileName]];
            self.imageFilePath = imageFilePath;
        }
        
        // 处理本地图像
        UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:self.imageFilePath];
        
        // 文件后缀名
        NSString *suffix = [XZFileTools getTheSuffix:fileName];
        
        XZMediaModel *modelMedia = [[XZMediaModel alloc] init];
        modelMedia.image = savedImage;
        modelMedia.mediaPath = self.imageFilePath;
        modelMedia.imageSize = savedImage.size;
        modelMedia.mediaType = 2;
        modelMedia.mediaName = fileName;
        modelMedia.extension = suffix;
        modelMedia.mediaData = data;
        
        if (self.blockDissmiss) {
            self.blockDissmiss(modelMedia);
        }
        
        [self.imagePickerVc dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

/// 使用代理创建图片选择器
- (void)createImagePickerCompletion:(void(^)(UIImagePickerController *imgPickerVc))completion {
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePickerVc = [[UIImagePickerController alloc] init];
        self.imagePickerVc = imagePickerVc;
        imagePickerVc.delegate = self;
        // 设置拍照后的图片可被编辑
        imagePickerVc.allowsEditing = YES;
        imagePickerVc.sourceType = sourceType;
        if(iOS8Later) {
            imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        completion(imagePickerVc);
    }else
    {
        Log(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

#pragma mark ----- 懒加载
- (NSMutableArray *)arrayMediaModel {
    if (!_arrayMediaModel) {
        _arrayMediaModel = [NSMutableArray array];
    }
    return _arrayMediaModel;
}

@end
