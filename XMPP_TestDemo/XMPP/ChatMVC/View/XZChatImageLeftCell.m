//
//  XZChatImageLeftCell.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/27.
//  Copyright © 2018年 XZ. All rights reserved.
//  纯图片左侧cell

#import "XZChatImageLeftCell.h"
#import "XZChatModel.h"

@interface XZChatImageLeftCell()
/// 图片内容
@property (nonatomic, strong) UIImageView *imgContent;

@end

@implementation XZChatImageLeftCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupChatImageLeftCell];
    }
    return self;
}

- (void)setModelChat:(XZChatModel *)modelChat {
    _modelChat = modelChat;
    
    self.labelTime.text = modelChat.chatTime;
}

- (void)setupChatImageLeftCell {
    
    /// 图片内容
    UIImageView *imgContent = [[UIImageView alloc] init];
    [self.contentView addSubview:imgContent];
    self.imgContent = imgContent;
    UIImage *oriImg = [UIImage imageNamed:@"chat_img_defaultPhoto"];
    imgContent.image = oriImg;
//    imgContent.image = [UIImage imageArrowWithImage:oriImg isSender:NO];
    
    WeakSelf;
    [self.imgIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10);
    }];
    
    [imgContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.imgIcon);
        make.left.equalTo(weakSelf.imgIcon.mas_right).offset(10);
        make.size.mas_equalTo(CGSizeMake(113, 113));
    }];
    
    ///
    
    
}

@end
