//
//  XZChatBaseCell.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/26.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import "XZChatBaseCell.h"

@interface XZChatBaseCell()
/// 时间/状态 背景
@property (nonatomic, strong) UIView *bgTime;
@end

@implementation XZChatBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupChatBaseCell];
    }
    return self;
}

- (void)setupChatBaseCell {
    self.contentView.backgroundColor = XZChatBgColor;
    
    /// 时间/状态 背景
    UIView *bgTime = [[UIView alloc] init];
    [self.contentView addSubview:bgTime];
    bgTime.backgroundColor = XZColor(221, 221, 221);
    self.bgTime = bgTime;
    
    /// 时间
    UILabel *labelTime = [[UILabel alloc] init];
    [bgTime addSubview:labelTime];
    labelTime.numberOfLines = 2;
//    labelTime.text = @"2018-06-26 16:07:46";
    labelTime.textColor = [UIColor whiteColor];
    labelTime.font = [UIFont systemFontOfSize:14.0f];
    labelTime.textAlignment = NSTextAlignmentCenter;
    //    labelTime.backgroundColor = XZColor(221, 221, 221);
    self.labelTime = labelTime;
    
    //// 用户头像
    UIImageView *imgIcon = [[UIImageView alloc] init];
    [self.contentView addSubview:imgIcon];
    imgIcon.image = [UIImage imageNamed:@"登录提示小融_03"];
    self.imgIcon = imgIcon;
    imgIcon.backgroundColor = [UIColor blueColor];
    
    [self setupCommonConstraints];
}

/// 设置子视图的布局
- (void)setupCommonConstraints {
    [self.labelTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgTime);
    }];
    
    [self.bgTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.centerX.equalTo(self.contentView);
        make.left.equalTo(self.labelTime).offset(-5);
        make.right.equalTo(self.labelTime).offset(5);
        make.bottom.equalTo(self.labelTime).offset(5);
        make.top.equalTo(self.labelTime).offset(-5);
    }];
    
    [self.imgIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.labelTime.mas_bottom).offset(10);
        make.size.equalTo(@35);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
