//
//  XZEmoticonAttachment.m
//  表情键盘
//
//  Created by XZ on 16/3/5.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "XZEmoticonAttachment.h"
#import "XZEmoticon.h"
#import "UIImage+XZEmoticon.h"

@implementation XZEmoticonAttachment

- (instancetype)initWithEmoticon:(XZEmoticon *)emoticon font:(UIFont *)font {
    self = [super init];
    if (self) {
        _text = emoticon.chs;
        
        self.image = [UIImage xz_imageNamed:emoticon.imagePath];
        CGFloat lineHeight = font.lineHeight;
        self.bounds = CGRectMake(0, -4, lineHeight, lineHeight);
    }
    return self;
}

+ (NSAttributedString *)emoticonStringWithEmoticon:(XZEmoticon *)emoticon font:(UIFont *)font textColor:(UIColor * _Nonnull)textColor {
    
    XZEmoticonAttachment *attachment = [[XZEmoticonAttachment alloc] initWithEmoticon:emoticon font:font];
    
    NSMutableAttributedString *emoticonStr = [[NSMutableAttributedString alloc] initWithAttributedString:
                                              [NSAttributedString attributedStringWithAttachment:attachment]];
    
    [emoticonStr addAttributes: @{NSFontAttributeName: font,
                                  NSForegroundColorAttributeName: textColor}
                         range:NSMakeRange(0, 1)];
    
    return emoticonStr.copy;
}

@end
