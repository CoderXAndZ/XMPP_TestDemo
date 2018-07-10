//
//  XZChatImageRightCell.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/27.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import "XZChatImageRightCell.h"
#import "XZChatModel.h"

@interface XZChatImageRightCell()
/// 图片内容
@property (nonatomic, strong) UIImageView *imgContent;

@end

@implementation XZChatImageRightCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupChatImageRightCell];
    }
    return self;
}

- (void)setModelChat:(XZChatModel *)modelChat {
    _modelChat = modelChat;
    
    self.labelTime.text = modelChat.chatTime;
    
    UIImage *img = [UIImage imageNamed:@"宠物网_猫咪"]; // 宠物网_猫咪
    // compose_toolbar_picture_highlighted
    
    [self updateImageCellWith:img maxSize:CGSizeMake(130, 130)];
}

- (void)setupChatImageRightCell {
    /// 图片内容
    UIImageView *imgContent = [[UIImageView alloc] init];
    [self.contentView addSubview:imgContent];
    self.imgContent = imgContent;
    UIImage *oriImg = [UIImage imageNamed:@"chat_img_defaultPhoto"];
    imgContent.image = oriImg;
//    [UIImage imageArrowWithImage:oriImg isSender:NO];
    
    FMWeakSelf;
    [self.imgIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-10);
    }];
    
    [imgContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.imgIcon);
        make.right.equalTo(weakSelf.imgIcon.mas_left).offset(-10);
        make.size.mas_equalTo(CGSizeMake(113, 113));
    }];
    
}

/// 更新图片cell的大小
- (void)updateImageCellWith:(UIImage *)image maxSize:(CGSize)maxSize {
    
    CGSize size = [UIImage changeImgSize:image.size maxSize:maxSize];
    
    self.imgContent.image = image;
    
    FMWeakSelf;
    [self.imgContent mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.imgIcon);
        make.right.equalTo(weakSelf.imgIcon.mas_left).offset(-10);
        make.size.mas_equalTo(size);
    }];
}

@end
