//
//  NSBundle+XZEmoticon.m
//  表情键盘
//
//  Created by XZ on 16/3/3.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "NSBundle+XZEmoticon.h"
#import "XZEmoticonInputView.h"

NSString *const XZEmoticonBundleName = @"Emoticon.bundle";

@implementation NSBundle (XZEmoticon)

+ (instancetype)xz_emoticonBundle {
    
    NSBundle *bundle = [NSBundle bundleForClass:[XZEmoticonInputView class]];
    NSString *bundlePath = [bundle pathForResource:XZEmoticonBundleName ofType:nil];
    
    return [NSBundle bundleWithPath:bundlePath];
}

@end
