//
//  XZTakePictureTools.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/7/9.
//  Copyright © 2018年 XZ. All rights reserved.
//  拍照

#import "XZTakePictureTools.h"

@interface XZTakePictureTools()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

 @property (nonatomic, strong) UIImagePickerController *imagePickerVc;

@property (nonatomic, strong) NSString *imageFilePath;

@end

@implementation XZTakePictureTools

#pragma mark ---- 代理方法
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

/// 使用代理创建图片选择器 WithDelegate:(id)delegate
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

@end
