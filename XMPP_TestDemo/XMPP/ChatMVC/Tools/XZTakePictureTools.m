//
//  XZTakePictureTools.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/7/9.
//  Copyright © 2018年 XZ. All rights reserved.
//  拍照

#import "XZTakePictureTools.h"
#import <TZImagePickerController.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
//"TZImagePickerController.h"

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

@end

@implementation XZTakePictureTools

#pragma mark ---- 相册方法
- (void)selectPhotoFromAlbumWithMaxCount:(NSInteger)maxCount controller:(UIViewController *)controller completion:(void(^)(NSMutableArray *photos))completion {
    
    TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initWithMaxImagesCount:maxCount delegate:self];
//    imagePicker.selectedAssets = _selectedAssets;
    imagePicker.allowPickingMultipleVideo = YES;
    imagePicker.allowTakePicture = NO;
    imagePicker.allowTakeVideo = NO;
    
//    FMWeakSelf;
    
//    [imagePicker setDidFinishPickingPhotosWithInfosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto, NSArray<NSDictionary *> *infos) {
//
//        Log(@"setDidFinishPickingPhotosWithInfosHandle：\n%@",infos);
//        Log(@"PhotosWithInfosHandle:photos=%@\nassets=%@\nisSelectOriginalPhoto:%d",photos,assets,isSelectOriginalPhoto);
//    }];
//
//    [imagePicker setDidFinishPickingVideoHandle:^(UIImage *coverImage, id asset) {
//        Log(@"coverImage ==== %@,asset ==== %@",coverImage, asset);
//    }];
//
//    // You can get the photos by block, the same as by delegate.
//    [imagePicker setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
//
//        [weakSelf.selectedPhotos removeAllObjects];
//
//        // 用户选择好了图片，如果assets非空，则用户选择了原图。
////        if (assets.count) {
//        [weakSelf.selectedPhotos addObjectsFromArray:assets];
////        }else {
////            [weakSelf.selectedPhotos addObjectsFromArray:photos];
////        }
//
//        completion(weakSelf.selectedPhotos);
//        Log(@"photos : %@ \n assets:%@",photos,assets);
//
//        Log(@"用户当前选择：%@", weakSelf.selectedPhotos);
//    }];
    
    [controller presentViewController:imagePicker animated:YES completion:nil];
}

// 用户选择好了图片，如果assets非空，则用户选择了原图。
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    
    Log(@"_selectedAssets -- infos：%@",infos);
    
    // 1.打印图片名字
    [self printAssetsName:assets];
    
    
    
    // 2.图片位置信息
    if (iOS8Later) {
        for (PHAsset *phAsset in assets) {
            
            Log(@"mediaType:%ld",(long)phAsset.mediaType);
            // PHAssetMediaTypeVideo
            if (phAsset.mediaType == TZAssetModelMediaTypeVideo) {
                NSLog(@"duration: %ld ===== mediaSubtypes:%ld",(long)phAsset.duration,(long)phAsset.mediaSubtypes);
                
                [[TZImageManager manager] getVideoWithAsset:phAsset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
                    
                    NSString *videoPath = [playerItem valueForKey:@"URL"];
                   
                    Log(@"\n URL ==== %@ \n",videoPath);
                    
                    Log(@"playerItem:%@ ====== info:%@",playerItem,info);
                }];
                
            }else {
                [[TZImageManager manager] getPhotoWithAsset:phAsset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                    
                    Log(@"mediaType:%ld ===== photo:%@ ===== info:%@ === isDegraded:%d",(long)phAsset.mediaType,photo,info,isDegraded);
                    
                    NSString *imagePath = info[@"PHImageFileURLKey"];
                   
                    Log(@"\n PHImageFileURLKey === %@ \n",imagePath);
                }];
            }
        }
    }
}

/// 打印图片名字
- (void)printAssetsName:(NSArray *)assets {
    NSString *fileName;
    for (id asset in assets) {
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = (PHAsset *)asset;
            fileName = [phAsset valueForKey:@"filename"];
        } else if ([asset isKindOfClass:[ALAsset class]]) {
            ALAsset *alAsset = (ALAsset *)asset;
            fileName = alAsset.defaultRepresentation.filename;;
        }
        Log(@"图片名字:%@",fileName);
    }
}

/// 从PHAsset中获取图片
- (void)getImageFromPHAsset:(PHAsset *)asset complete:(BlockResult)result {
    
    __block NSData *data;
    
    PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:asset] firstObject];
    
    if (asset.mediaType == PHAssetMediaTypeImage) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                          options:options
                                                    resultHandler:
         ^(NSData *imageData,
           NSString *dataUTI,
           UIImageOrientation orientation,
           NSDictionary *info) {
             data = [NSData dataWithData:imageData];
         }];
    }
    
    if (result) {
        if (data.length <= 0) {
            result(nil, nil);
        } else {
            result(data, resource.originalFilename);
        }
    }
    
}

/// PHAsset获取视频
- (void)getVideoPathFromPHAsset:(PHAsset *)asset Complete:(ResultPath)result {
    
    NSArray *assetResources = [PHAssetResource assetResourcesForAsset:asset];
    PHAssetResource *resource;
    
    for (PHAssetResource *assetRes in assetResources) {
        if (assetRes.type == PHAssetResourceTypePairedVideo ||
            assetRes.type == PHAssetResourceTypeVideo) {
            resource = assetRes;
        }
    }
    NSString *fileName = @"tempAssetVideo.mov";
    if (resource.originalFilename) {
        fileName = resource.originalFilename;
    }
    
    if (asset.mediaType == PHAssetMediaTypeVideo || asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        NSString *PATH_MOVIE_FILE = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE error:nil];
        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource
                                                                    toFile:[NSURL fileURLWithPath:PATH_MOVIE_FILE]
                                                                   options:nil
                                                         completionHandler:^(NSError * _Nullable error) {
                                                             if (error) {
                                                                 result(nil, nil);
                                                             } else {
                                                                 result(PATH_MOVIE_FILE, fileName);
                                                             }
                                                         }];
    } else {
        result(nil, nil);
    }
}

#pragma mark ---- 拍照代理方法 - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    // 当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        // 先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        NSData *data;
        if (UIImagePNGRepresentation(image) == nil)
        {
            data = UIImageJPEGRepresentation(image, 1.0);
        }
        else
        {
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
            [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:@"/image6.png"] contents:data attributes:nil];
            // 得到选择后沙盒中图片的完整路径
            NSString *imageFilePath = [[NSString alloc]initWithFormat:@"%@%@",DocumentsPath,  @"/image6.png"];
            self.imageFilePath = imageFilePath;
        }
        
        // 处理本地图像
        UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:self.imageFilePath];
        
        if (self.blockDissmiss) {
            self.blockDissmiss(self.imageFilePath,savedImage);
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

#pragma mark ---- 懒加载
//- (NSMutableArray *)selectedPhotos {
//    if (!_selectedPhotos) {
//        _selectedPhotos = [NSMutableArray array];
//    }
//    return _selectedPhotos;
//}


@end
