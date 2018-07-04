//
//  XZEmoticonPackage.m
//  表情键盘
//
//  Created by XZ on 16/3/3.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "XZEmoticonPackage.h"
#import "XZEmoticon.h"
#import "NSBundle+XZEmoticon.h"

@implementation XZEmoticonPackage

#pragma mark - 构造函数
+ (instancetype)packageWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
        
        // 创建表情数组
        _emoticonsList = [[NSMutableArray alloc] init];
        
        // 判断目录是否为空
        if (_directory != nil) {
            // 加载表情模型
            NSString *fileName = [NSString stringWithFormat:@"%@/info.plist", _directory];
            NSString *path = [[NSBundle xz_emoticonBundle] pathForResource:fileName ofType:nil];
            NSArray *array = [NSArray arrayWithContentsOfFile:path];
            
            for (NSDictionary *dict in array) {
                [_emoticonsList addObject:[XZEmoticon emoticonWithDict:dict]];
                _emoticonsList.lastObject.directory = _directory;
            }
        }
        
    }
    return self;
}

- (NSString *)description {
    NSArray *keys = @[@"groupName", @"directory", @"emoticonsList"];
    
    return [self dictionaryWithValuesForKeys:keys].description;
}

@end
