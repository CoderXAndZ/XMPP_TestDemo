//
//  XZVoiceProgress.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/28.
//  Copyright © 2018年 XZ. All rights reserved.
//  说话音量显示

#import "XZVoiceProgress.h"

@interface XZVoiceProgress()
// 显示静态图片
@property (nonatomic, strong) UIImageView *imageView;
// 显示动画
@property (nonatomic, strong) UIImageView *imageAnimationView;

@property (nonatomic, strong) NSArray *images;

/// 提示
@property (nonatomic, strong) UILabel *labelTip;
/// 时间倒计时
@property (nonatomic, strong) UILabel *labelTime;

@end

@implementation XZVoiceProgress

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self setupVoiceProgress];
    }
    return self;
}

- (void)setVoiceRecordState:(XZVoiceRecordState)voiceRecordState {
    _voiceRecordState = voiceRecordState;
    
     if (voiceRecordState == XZVoiceRecordState_Recording) { // 正在录音
         self.imageAnimationView.hidden = YES;
         self.imageView.hidden = NO;
         self.imageView.image = [UIImage imageNamed: @"voice_1"];
         self.labelTip.text = @"手指上移，取消发送";
         self.labelTip.backgroundColor = [UIColor clearColor];
         self.labelTime.hidden = YES;
         
    }else if (voiceRecordState == XZVoiceRecordState_ReleaseToCancel) { // 取消发送
        self.imageAnimationView.hidden = YES;
        self.imageView.hidden = NO;
        self.imageView.image = [UIImage imageNamed: @"cancelVoice"];
        self.labelTip.text = @"松开手指，取消发送";
        self.labelTip.backgroundColor = XZColor(222, 130, 136);
        self.labelTime.hidden = YES;
        
    }else if (voiceRecordState == XZVoiceRecordState_RecordCounting) { // 倒计时
        
        self.labelTime.hidden = NO;
        self.imageView.hidden = YES;
        self.imageAnimationView.hidden = YES;
        
        self.labelTip.text = @"手指上移，取消发送";
        self.labelTip.backgroundColor = [UIColor clearColor];
        
       self.labelTime.text = self.time;
        
    }else if (voiceRecordState == XZVoiceRecordState_RecordTooShort) {
        // 时间太短
        self.imageAnimationView.hidden = YES;
        self.labelTime.hidden = YES;
        self.imageView.hidden = NO;
        self.imageView.image = [UIImage imageNamed: @"voiceShort"];
        self.labelTip.text = @"说话时间太短";
        self.labelTip.backgroundColor = [UIColor clearColor];
    }
}

// 设置时间
- (void)setTime:(NSString *)time {
    _time = time;
}

//
//// 设置时间
//- (void)setTime:(NSString *)time {
//    _time = time;
//    Log(@"设置时间time: %@",time);
//
//    self.imageView.hidden = YES;
//    self.labelTime.hidden = NO;
//    self.labelTime.text = time;
//
//    self.labelTip.text = @"手指上移，取消发送";
//    self.labelTip.backgroundColor = [UIColor clearColor];
//}
//
//// 设置图片
//- (void)setImage:(NSString *)image {
//
//    if (image.length) {
//        self.imageView.image = [UIImage imageNamed:image];
//    }
//    self.imageView.hidden = NO;
//    self.labelTime.hidden = YES;
//
//    Log(@"设置图片image: %@",image);
//
//    if ([image isEqualToString:@"cancelVoice"]) {// 松开手指，取消发送
//        self.labelTip.text = @"松开手指，取消发送";
//        self.labelTip.backgroundColor = XZColor(222, 130, 136);
//    }else if ([image isEqualToString:@"voiceShort"]) { // 说话时间太短
//        self.labelTip.text = @"说话时间太短";
//        self.labelTip.backgroundColor = [UIColor clearColor];
//    }else {
//        self.labelTip.text = @"手指上移，取消发送";
//        self.labelTip.backgroundColor = [UIColor clearColor];
//    }
//}

// 设置是否隐藏
- (void)setIsHidden:(BOOL)isHidden {
    _isHidden = isHidden;
    
    for (UIView *subiew in self.subviews) {
        if (isHidden) { // 隐藏
            subiew.hidden = YES;
        }else { // 显示
            subiew.hidden = NO;
        }
    }
    
    self.time = nil;
    self.progress = 0;
//    self.hidden = isHidden;
}

// 设置音量
- (void)setProgress:(CGFloat)progress {
    _progress = MIN(MAX(progress, 0.0f), 1.0f);
    
    if (_voiceRecordState == XZVoiceRecordState_Recording) {
        [self setupAnimationImages];
        
        self.imageView.hidden = YES;
        self.imageAnimationView.hidden = NO;
    }
}

// 设置动画
- (void)setupAnimationImages {
    Log(@"设置动画 ========== ");
    
    if (_progress == 0) {
        self.imageAnimationView.animationImages = nil;
        [self.imageAnimationView stopAnimating];
        return;
    }
    
    if (_progress >= 0.8) {
        self.imageAnimationView.animationImages = @[self.images[3],self.images[4],self.images[5],self.images[4],self.images[3]];
    }else if (_progress >= 0.7) {
        self.imageAnimationView.animationImages = @[self.images[0],self.images[1],self.images[2]];
    }else {
        self.imageAnimationView.animationImages = @[self.images[0]];
    }
    
    [self.imageAnimationView startAnimating];
}

///// 关闭手势延迟
//- (void)didMoveToWindow {
//    [super didMoveToWindow];
//
//    for (UIGestureRecognizer *gesture in self.window.gestureRecognizers) {
//        gesture.delaysTouchesBegan = NO;
//
//        Log(@"delaysTouchesBegan = %@",gesture.delaysTouchesBegan ? @"YES":@"NO");
//    }
//}

- (void)setupVoiceProgress {
    FMWeakSelf;
    
    UIView *bgView = [[UIView alloc] init];
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf);
    }];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.5;
    
    // 静态视图
    self.imageView = [[UIImageView alloc] init];
    [self addSubview: self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf);
        make.centerY.equalTo(weakSelf);
    }];
    self.imageView.image = [UIImage imageNamed:@"voice_1"];
   
    // 动画视图
    self.imageAnimationView = [[UIImageView alloc] init];
    [self addSubview: self.imageAnimationView];
    [self.imageAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf);
        make.centerY.equalTo(weakSelf);
    }];
    self.imageAnimationView.animationDuration = 0.5;
    self.imageAnimationView.animationRepeatCount = -1;
    self.imageAnimationView.hidden = YES;
    
    self.labelTime = [[UILabel alloc] init];
    [self addSubview: self.labelTime];
    [self.labelTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf);
        make.centerY.equalTo(weakSelf);
    }];
    self.labelTime.textColor = [UIColor whiteColor];
    self.labelTime.font = [UIFont boldSystemFontOfSize: 50];
    
    self.labelTip = [[UILabel alloc] init];
    [self addSubview: self.labelTip];
    [self.labelTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf).offset(-15);
        make.centerX.equalTo(weakSelf);
    }];
    self.labelTip.text = @"松开手指，取消发送";
    self.labelTip.backgroundColor = [UIColor clearColor];
    self.labelTip.font = [UIFont systemFontOfSize:13];
    self.labelTip.textColor = [UIColor whiteColor];
}

- (NSArray *)images {
    if (!_images) {
        _images = @[
                    [UIImage imageNamed:@"voice_1"],
                    [UIImage imageNamed:@"voice_2"],
                    [UIImage imageNamed:@"voice_3"],
                    [UIImage imageNamed:@"voice_4"],
                    [UIImage imageNamed:@"voice_5"],
                    [UIImage imageNamed:@"voice_6"]
                    ];
    }
    return _images;
}

@end
