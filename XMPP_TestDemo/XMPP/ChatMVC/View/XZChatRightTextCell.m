//
//  XZChatRightTextCell.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/27.
//  Copyright © 2018年 XZ. All rights reserved.
//  普通右侧的纯文本的cell

#import "XZChatRightTextCell.h"
#import <HYBMasonryAutoCellHeight/UITableViewCell+HYBMasonryAutoCellHeight.h>
#import "XZChatModel.h"

@interface  XZChatRightTextCell()

/// 聊天内容
@property (nonatomic, strong) YYLabel *labelContent;
/// 聊天气泡背景
@property (nonatomic, strong) UIImageView *imgBubble;

@end

@implementation XZChatRightTextCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupChatLeftTextCell];
    }
    return self;
}

- (void)setupChatLeftTextCell {
    /// 聊天气泡背景
    UIImageView *imgBubble = [[UIImageView alloc] init];
    [self.contentView addSubview:imgBubble];
    imgBubble.image = [[UIImage imageNamed:@"chat_bubbleRight"] xz_resizableImageWithCapInsets: UIEdgeInsetsMake(30, 15, 30, 30)];
    self.imgBubble = imgBubble;
    
    /// 聊天内容
    YYLabel *labelContent = [[YYLabel alloc] init];
    [imgBubble addSubview:labelContent];
    labelContent.text = @" ";
    labelContent.numberOfLines = 0;
    labelContent.font = [UIFont systemFontOfSize:14.0f];
    labelContent.textColor = [UIColor darkGrayColor];
    self.labelContent = labelContent;
    labelContent.backgroundColor = [UIColor greenColor];
    labelContent.preferredMaxLayoutWidth = KProjectScreenWidth - 133;
    labelContent.ignoreCommonProperties = YES;
    labelContent.displaysAsynchronously = YES;
    
    [self.imgIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-10);
    }];
    
    [imgBubble mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgIcon);
        make.right.equalTo(self.imgIcon.mas_left).offset(-8);
        make.left.equalTo(labelContent).offset(-5);
    }];
    
    [labelContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(imgBubble).offset(-12);
        make.width.mas_lessThanOrEqualTo(KProjectScreenWidth - 133);
        make.top.equalTo(imgBubble).offset(5);
        make.bottom.equalTo(imgBubble).offset(-5);
    }];
    
//    self.hyb_lastViewInCell = imgBubble;
//    self.hyb_bottomOffsetToCell = 10;
}

- (void)setModelChat:(XZChatModel *)modelChat {
    _modelChat = modelChat;
    
    Log(@"%@ ---- %@",modelChat.chatTime,modelChat.chatContent);
    
    self.labelContent.text = modelChat.chatContent;
    self.labelTime.text = modelChat.chatTime;
}


@end
