//
//  XZVoiceProgress.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/28.
//  Copyright © 2018年 XZ. All rights reserved.
//  说话音量显示

#import "XZVoiceProgress.h"

@interface XZVoiceProgress()

@property (nonatomic, strong) NSArray *images;

@end

@implementation XZVoiceProgress

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupVoiceProgress];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress {
    _progress = MIN(MAX(progress, 0.0f), 1.0f);
    
    [self setupAnimationImages];
}

- (void)setupAnimationImages {
    if (_progress == 0) {
        self.animationImages = nil;
        [self stopAnimating];
        return;
    }
    
    if (_progress >= 0.8) {
        self.animationImages = @[self.images[3],self.images[4],self.images[5],self.images[4],self.images[3]];
    }else if (_progress >= 0.7) {
        self.animationImages = @[self.images[0],self.images[1],self.images[2]];
    }else {
        self.animationImages = @[self.images[0]];
    }
    
    [self startAnimating];
}

///// 关闭手势延迟
//- (void)didMoveToWindow {
//    [super didMoveToWindow];
//
//    for (UIGestureRecognizer *gesture in self.window.gestureRecognizers) {
//        gesture.delaysTouchesBegan = NO;
//
//        NSLog(@"delaysTouchesBegan = %@",gesture.delaysTouchesBegan ? @"YES":@"NO");
//    }
//}

- (void)setupVoiceProgress {
    self.animationDuration = 0.5;
    self.animationRepeatCount = -1;
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
