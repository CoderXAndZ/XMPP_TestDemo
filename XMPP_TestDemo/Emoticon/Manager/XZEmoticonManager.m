//
//  XZEmoticonManager.m
//  表情键盘
//
//  Created by XZ on 16/3/3.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "XZEmoticonManager.h"
#import "NSBundle+XZEmoticon.h"
#import "XZEmoticonAttachment.h"

/// 每页显示的表情数量
static NSInteger kEmoticonsCountOfPage = 20;
/// 命名空间常量
NSString *const XZEmoticonNamespace = @"cn.itcast";
/// 默认用户标识符
NSString *const XZEmoticonDefaultUserIdentifier = @"DefaultUser";
/// 表情文件名
NSString *const XZEmoticonFileName = @".emoticons.json";

@implementation XZEmoticonManager {
    NSMutableArray <XZEmoticon *> *_recentEmoticonList;
}

#pragma mark - 单例 & 构造函数
+ (instancetype)sharedManager {
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _packages = [NSMutableArray array];
        
        [self loadPackages];
    }
    return self;
}

#pragma mark - 字符串转换
- (NSAttributedString *)emoticonStringWithString:(NSString *)string font:(UIFont *)font textColor:(UIColor *)textColor {
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
                                                   initWithString:string
                                                   attributes:@{NSFontAttributeName: font,
                                                                NSForegroundColorAttributeName: textColor}];
    
    NSString *pattern = @"\\[.*?\\]";
    NSRegularExpression *regx = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
    
    NSArray *matches = [regx matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    for (NSTextCheckingResult *result in matches.reverseObjectEnumerator) {
        
        NSRange range = [result rangeAtIndex:0];
        NSString *str = [string substringWithRange:range];
        
        XZEmoticon *emoticon = [self emoticonWithString:str];
        if (emoticon != nil) {
            NSAttributedString *emoticonString = [XZEmoticonAttachment emoticonStringWithEmoticon:emoticon font:font textColor:textColor];
            
            [attributedString replaceCharactersInRange:range withAttributedString:emoticonString];
        }
    }
    
    return attributedString.copy;
}

- (XZEmoticon *)emoticonWithString:(NSString *)string {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chs == %@", string];
    XZEmoticon *emoticon = nil;
    
    for (NSInteger i = 1; i < _packages.count; i++) {
        
        XZEmoticonPackage *package = _packages[i];
        
        NSArray *filter = [package.emoticonsList filteredArrayUsingPredicate:predicate];
        
        if (filter.count == 1) {
            emoticon = filter[0];
            
            break;
        }
    }
    
    return emoticon;
}

#pragma mark - 数据源方法
- (NSInteger)numberOfPagesInSection:(NSInteger)section {
    XZEmoticonPackage *package = _packages[section];
    
    return ((NSInteger)package.emoticonsList.count - 1) / kEmoticonsCountOfPage + 1;
}

- (NSArray *)emoticonsWithIndexPath:(NSIndexPath *)indexPath {
    XZEmoticonPackage *package = self.packages[indexPath.section];
    
    NSInteger location = indexPath.item * kEmoticonsCountOfPage;
    NSInteger length = kEmoticonsCountOfPage;
    
    // 判断是否越界
    if ((location + length) > package.emoticonsList.count) {
        length = package.emoticonsList.count - location;
    }
    
    NSRange range = NSMakeRange(location, length);
    
    return [package.emoticonsList subarrayWithRange:range];
}

#pragma mark - 最近使用表情
- (void)addRecentEmoticon:(XZEmoticon *)emoticon {
    // 0. 表情计数 ++
    emoticon.times++;
    
    // 1. 判断表情是否已经存在
    if (![_recentEmoticonList containsObject:emoticon]) {
        [_recentEmoticonList addObject:emoticon];
    }
    
    // 2. 排序
    [_recentEmoticonList sortUsingComparator:^NSComparisonResult(XZEmoticon *obj1, XZEmoticon *obj2) {
        return obj1.times < obj2.times;
    }];
    
    // 3. 更新最近表情包
    [self updateRecentPackage];
    
    // 4. 保存表情包
    [self saveRecentEmoticonList];
}

/// 更新最近表情包数组
- (void)updateRecentPackage {
    NSInteger length = _recentEmoticonList.count < kEmoticonsCountOfPage ? _recentEmoticonList.count : kEmoticonsCountOfPage;
    
    _packages[0].emoticonsList = [_recentEmoticonList subarrayWithRange:NSMakeRange(0, length)].mutableCopy;
}

/// 保存最近表情数组
- (void)saveRecentEmoticonList {
    
    NSMutableArray *jsonDict = [NSMutableArray array];
    for (XZEmoticon *emoticon in _recentEmoticonList) {
        [jsonDict addObject:[emoticon dictionary]];
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:NULL];
    [data writeToFile:[self filePathForRecentEmoticon] atomically:YES];
}

/// 加载最近表情数组
///
/// @return 最近表情数组
- (NSMutableArray <XZEmoticon *>*)loadRecentEmoticonList {
    
    NSMutableArray *arrayM = [NSMutableArray array];
    NSData *data = [NSData dataWithContentsOfFile:[self filePathForRecentEmoticon]];
    
    if (data == nil) {
        return arrayM;
    }
    
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    
    for (NSDictionary *dict in array) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chs CONTAINS %@ || code CONTAINS %@", dict[@"chs"], dict[@"code"]];
        
        for (NSInteger i = 1; i < _packages.count; i++) {
            XZEmoticonPackage *package = _packages[i];
            
            NSArray *filter = [package.emoticonsList filteredArrayUsingPredicate:predicate];
            
            if (filter.count == 1) {
                [arrayM addObject:filter[0]];
                break;
            }
        }
    }
    
    return arrayM;
}

/// 最近表情文件路径
- (NSString *)filePathForRecentEmoticon {
    NSString *dir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    
    return [[dir stringByAppendingPathComponent:self.userIdentifier] stringByAppendingString:XZEmoticonFileName];
}

#pragma mark - 加载表情包数据
- (void)loadPackages {
    
    // 1. 读取 emoticons.plist
    NSString *path = [[NSBundle xz_emoticonBundle] pathForResource:@"emoticons.plist" ofType:nil];
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    
    // 2. 遍历数组，生成 packages 模型
    for (NSDictionary *dict in array) {
        [_packages addObject:[XZEmoticonPackage packageWithDict:dict]];
    }
    
    // 3. 加载最近使用表情列表
    _recentEmoticonList = [self loadRecentEmoticonList];
    
    // 4. 更新最近表情包
    [self updateRecentPackage];
}

#pragma mark - 用户标识符
@synthesize userIdentifier = _userIdentifier;
- (void)setUserIdentifier:(NSString *)userIdentifier {
    _userIdentifier = userIdentifier.copy;
    
    _recentEmoticonList = [self loadRecentEmoticonList];
    [self updateRecentPackage];
}

- (NSString *)userIdentifier {
    if (_userIdentifier == nil) {
        _userIdentifier = XZEmoticonDefaultUserIdentifier;
    }
    return [NSString stringWithFormat:@"%@.%@", XZEmoticonNamespace, _userIdentifier];;
}

@end
