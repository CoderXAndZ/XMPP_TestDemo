//
//  UIImage+XZEmoticon.m
//  表情键盘
//
//  Created by XZ on 16/3/3.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "UIImage+XZEmoticon.h"
#import "NSBundle+XZEmoticon.h"

@implementation UIImage (XZEmoticon)

+ (UIImage *)xz_imageNamed:(NSString *)name {
    return [UIImage imageNamed:name
                      inBundle:[NSBundle xz_emoticonBundle]
 compatibleWithTraitCollection:nil];
}

- (UIImage *)xz_resizableImage {
    return [self resizableImageWithCapInsets:
            UIEdgeInsetsMake(self.size.height * 0.5,
                             self.size.width * 0.5,
                             self.size.height * 0.5,
                             self.size.width * 0.5)];
}

@end
