//
//  XZChatVoiceLeftCell.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/27.
//  Copyright © 2018年 XZ. All rights reserved.
//  声音左侧

#import "XZChatVoiceLeftCell.h"
#import "XZVoicePlayer.h"
#import "XZFileTools.h"
#import "XZChatModel.h"

@interface XZChatVoiceLeftCell()

/// 聊天气泡背景
@property (nonatomic, strong) UIImageView *imgBubble;
/// 声音
@property (nonatomic, strong) UIImageView *imgVoiceIcon;
/// 声音时长
@property (nonatomic, strong) UILabel *labelVoiceDuration;
/// 是否点击播放录音
@property (nonatomic, assign) BOOL isTaped;
@end

@implementation XZChatVoiceLeftCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupChatVoiceLeftCell];
    }
    return self;
}

/// 点击播放语音
- (void)didTapVoiceBubble:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateEnded) {
        self.isTaped = !self.isTaped;
        
        if (self.isTaped) { // 播放
            [self.imgVoiceIcon startAnimating];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(playWithVoicePath: cell:)]) {
                
                [self.delegate playWithVoicePath: [self voicePath] cell:self];
            }
        }else { // 暂停播放
            [[XZVoicePlayer shared] stop];
                
            [self.imgVoiceIcon stopAnimating];
        }
    }
}

/// 声音路径
- (NSString *)voicePath {
//    NSString *path = [XZFileTools recoderPathWithFileName:@"1530602004.wav"];
    NSString *path = @"1530602005.wav";
    return path;
}

/// 播放完成
- (void)setIsCompletedPlay:(BOOL)isCompletedPlay {
    _isCompletedPlay = isCompletedPlay;
    
    [self.imgVoiceIcon stopAnimating];
    self.isTaped = NO;
}

/// 设置值
- (void)setModelChat:(XZChatModel *)modelChat {
    _modelChat = modelChat;
    
    self.labelTime.text = modelChat.chatTime;
}

/// 设置页面
- (void)setupChatVoiceLeftCell {
    /// 聊天气泡背景
    UIImageView *imgBubble = [[UIImageView alloc] init];
    [self.contentView addSubview:imgBubble];
    imgBubble.image = [[UIImage imageNamed:@"chat_bubbleLeft"] xz_resizableImageWithCapInsets: UIEdgeInsetsMake(30, 30, 30, 15)];
    imgBubble.userInteractionEnabled = YES;
    self.imgBubble = imgBubble;
    [imgBubble addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapVoiceBubble:)]];
    
    /// 声音
    UIImageView *imgVoiceIcon = [[UIImageView alloc] init];
    [self.contentView addSubview:imgVoiceIcon];
    imgVoiceIcon.image = [UIImage imageNamed:@"left-3"];
    self.imgVoiceIcon = imgVoiceIcon;
    UIImage *image1 = [UIImage imageNamed:@"left-1"];
    UIImage *image2 = [UIImage imageNamed:@"left-2"];
    UIImage *image3 = [UIImage imageNamed:@"left-3"];
    
    imgVoiceIcon.animationDuration = 0.8;
    imgVoiceIcon.animationImages = @[image1,image2,image3];
    
    // 声音时长
    UILabel *labelVoiceDuration = [[UILabel alloc] init];
    [self.contentView addSubview: labelVoiceDuration];
    labelVoiceDuration.font = [UIFont systemFontOfSize:12.0f];
    self.labelVoiceDuration = labelVoiceDuration;
    
    [self.imgIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10);
    }];
    
    [imgBubble mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgIcon);
        make.left.equalTo(self.imgIcon.mas_right).offset(8);
        make.size.mas_equalTo(CGSizeMake(113, 40));
    }];
    
    [imgVoiceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgBubble).offset(15);
        make.centerY.equalTo(imgBubble);
    }];
    
    [labelVoiceDuration mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgBubble.mas_right).offset(5);
        make.centerY.equalTo(imgBubble);
    }];
    
    //    self.hyb_lastViewInCell = imgBubble;
    //    self.hyb_bottomOffsetToCell = 5;
    
    self.isTaped = NO;
}

@end
