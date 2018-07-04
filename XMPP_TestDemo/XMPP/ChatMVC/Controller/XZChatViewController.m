//
//  XZChatViewController.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/20.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import "XZChatViewController.h"
#import <HYBMasonryAutoCellHeight/UITableViewCell+HYBMasonryAutoCellHeight.h>
#import "XZEmoticonViewController.h"
#import "XZVoiceRecorderManager.h" // 声音录制
#import "XZChatLeftTextCell.h" // 普通纯文本左侧
#import "XZChatRightTextCell.h" // 普通纯文本右侧
#import "XZChatImageRightCell.h" // 纯图片右侧
#import "XZChatImageLeftCell.h" // 纯图片左侧
#import "XZVoiceProgress.h" // 说话音量显示
#import "XZChatVoiceLeftCell.h" // 左侧语音
#import "XZChatToolBar.h" //  聊天工具栏
#import "XZXMPPManager.h"
#import "XZVoicePlayer.h"
#import "XZChatModel.h"
#import "XMPP.h"


@interface XZChatViewController ()<XMPPStreamDelegate,UITableViewDelegate,UITableViewDataSource,XZChatToolBarDelegate,XZChatVoiceLeftCellDelegate>

@property (nonatomic, strong) UITableView *tableChat;
@property (nonatomic, strong) XZChatToolBar *toolBar;
@property (nonatomic, strong) XZVoiceProgress *voiceProgress;
@end

@implementation XZChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [[XZXMPPManager defaultManager] loginWithName:@"t6" password:@"t6"];
   
    [self setupChatView];
    
}

#pragma mark ----- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    XZChatLeftTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XZChatLeftTextCell"];
//    XZChatRightTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XZChatRightTextCell"];
//    XZChatImageLeftCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XZChatImageLeftCell"];
    
//    XZChatImageRightCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XZChatImageRightCell"];
    
    XZChatVoiceLeftCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XZChatVoiceLeftCell"];
    
    if (!cell) {
        cell = [[XZChatVoiceLeftCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"XZChatVoiceLeftCell"];
    }
    
    cell.delegate = self;
    
    XZChatModel *modelChat = [[XZChatModel alloc] init];
    cell.modelChat = modelChat;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    XZChatModel *modelChat = [[XZChatModel alloc] init];
//
//    CGFloat height = [XZChatRightTextCell hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
//
//        XZChatRightTextCell *cell = (XZChatRightTextCell *)sourceCell;
//        // 设置数据
//        cell.modelChat = modelChat;
//    }];
    
    return 150;
}

#pragma mark --- XZChatVoiceLeftCellDelegate
- (void)playWithVoicePath:(NSString *)path cell:(XZChatVoiceLeftCell *)cell {
    NSLog(@"playWithVoicePath ---- 播放文件：%@",path);
    
    __weak __typeof(&*cell)weakCell = cell;
    [[XZVoicePlayer shared] playWithURLString: path progress:^(CGFloat progress) {
        if (progress == 1) { // 播放完成
            NSLog(@"播放完成");
            weakCell.isCompletedPlay = YES;
        }
    }];
}

#pragma mark ---- 底部工具栏的代理
- (void)didStartRecordingVoice {
    self.voiceProgress.hidden = NO;
    
    [[XZVoiceRecorderManager sharedManager] startRecordWithFileName:[self currentRecordFileName] completion:^(NSError *error) {
        if (error) {
            if (error.code != 12) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error.localizedDescription delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alert show];
            }
        }
    } power:^(CGFloat progress) {
        NSLog(@"didStartRecordingVoice 正在录音 ==== %f",progress);
        self.voiceProgress.progress = progress;
    }];
    
}

- (void)didCancelRecordingVoice {
    self.voiceProgress.hidden = YES;
    
    [[XZVoiceRecorderManager sharedManager] removeCurrentRecordFile];
    
    self.voiceProgress.image = [UIImage imageNamed:@"voice_1"];
}

- (void)didDragInside:(BOOL)inside {
    if (inside) {
        [[XZVoiceRecorderManager sharedManager] resumeTimer];
        self.voiceProgress.image = [UIImage imageNamed:@"voice_1"];
        self.voiceProgress.hidden = NO;
    } else {
        [[XZVoiceRecorderManager sharedManager] pauseTimer];
        self.voiceProgress.image = [UIImage imageNamed:@"cancelVoice"];
        self.voiceProgress.hidden = NO;
    }
}

- (void)didStopRecordingVoice {
    self.voiceProgress.hidden = YES;
    
    WeakSelf;
    [[XZVoiceRecorderManager sharedManager] stopRecordingWithCompletion:^(NSString *recordPath) {
        NSLog(@"didStopRecordingVoice === recordPath:%@",recordPath);
        
        if ([recordPath isEqualToString:shortRecord]) {
            [weakSelf showShortRecordProgress];
        } else {
            NSLog(@"录音完成，地址是：\n%@",recordPath);
            
//            NSString *voiceMsg = [NSString stringWithFormat:@"voice[local://%@]",recordPath];
            // =========
//            [weakSelf.dataArray addObject:[XZChatHelper creatMessage:voiceMsg msgType:YHMessageType_Voice toID:@"1"]];
//            [weakSelf.tableChat reloadData];
//            [weakSelf.tableChat scrollToBottomAnimated:NO];
        }
    }];
}

/// 录音太短提示
- (void)showShortRecordProgress {
    self.voiceProgress.hidden = NO;
    
    self.voiceProgress.image = [UIImage imageNamed:@"voiceShort"];
    
    WeakSelf;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        weakSelf.voiceProgress.hidden = YES;
    });
}

/// 当前录音存放地址
- (NSString *)currentRecordFileName {
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%ld.wav",(long)timeInterval];
    
    NSLog(@"音频存放地址：%@",fileName);
    
    return fileName;
}

#pragma mark ---  设置页面
- (void)setupChatView {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: self.tableChat];
    [self.view addSubview: self.toolBar];
    [self.view addSubview: self.voiceProgress];
    
//    /// 关闭手势延迟
//    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
}

#pragma mark --- 懒加载
- (UITableView *)tableChat {
    if (!_tableChat) {
        _tableChat = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KProjectScreenWidth, KProjectScreenHeight - 64) style:UITableViewStylePlain];
        _tableChat.delegate = self;
        _tableChat.dataSource  = self;
        _tableChat.backgroundColor = [UIColor whiteColor];
        _tableChat.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableChat.showsVerticalScrollIndicator = NO;
    }
    return _tableChat;
}

- (XZChatToolBar *)toolBar {
    if (!_toolBar) {
        _toolBar = [[XZChatToolBar alloc] initWithFrame:CGRectMake(0, kScreenHeight - 64, kScreenWidth, 64)];
        _toolBar.delegate = self;
    }
    return _toolBar;
}

- (XZVoiceProgress *)voiceProgress {
    if (!_voiceProgress) {
        _voiceProgress = [[XZVoiceProgress alloc] initWithFrame:CGRectMake(0, 0, 155, 155)];
        _voiceProgress.center = CGPointMake(self.view.centerX, self.view.centerY - 64);
    }
    return _voiceProgress;
}

#pragma mark ---- 表情界面
- (void)emoticonViewController {
    XZEmoticonViewController *emoticonVc = [[XZEmoticonViewController alloc] init];
    [self.navigationController pushViewController:emoticonVc animated:YES];
}


@end
