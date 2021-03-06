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
#import "TZImagePickerController.h"
#import "XZVoiceRecorderManager.h" // 声音录制
#import "XZAfterThreeMinutesView.h" // 3分钟后页面
#import "XZTakePictureTools.h" // 拍照
#import "XZChatLeftTextCell.h" // 普通纯文本左侧
#import "XZChatRightTextCell.h" // 普通纯文本右侧
#import "XZChatImageRightCell.h" // 纯图片右侧
#import "XZChatImageLeftCell.h" // 纯图片左侧
#import "XZChatVoiceRightCell.h" // 右侧语音
#import "XZChatVoiceLeftCell.h" // 左侧语音
#import "XZChatToolBar.h" //  聊天工具栏
#import "XZXMPPManager.h"
#import "XZVoicePlayer.h"
#import "XZFileTools.h"
#import "XZChatModel.h"
#import <TZImagePickerController.h>
#import "XMPP.h"

@interface XZChatViewController ()<XMPPStreamDelegate,UITableViewDelegate,UITableViewDataSource,XZChatVoiceRightCellDelegate,XZChatToolBarDelegate>
//
@property (nonatomic, strong) UITableView *tableChat;
/// 底部工具栏
@property (nonatomic, strong) XZChatToolBar *toolBar;
/// 3分钟之后新页面
@property (nonatomic, strong) XZAfterThreeMinutesView *afterThreeMinutes;
/// 拍照控制器
@property (nonatomic, strong) XZTakePictureTools *pictureTool;
@end

@implementation XZChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
//    [[XZXMPPManager defaultManager] loginWithName:@"t6" password:@"t6"];
    
    [self setupChatView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableChat reloadData];
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
    
//    XZChatVoiceLeftCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XZChatVoiceLeftCell"];
    
    XZChatVoiceRightCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XZChatVoiceRightCell"];
    
    if (!cell) {
        cell = [[XZChatVoiceRightCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"XZChatVoiceRightCell"];
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
    Log(@"playWithVoicePath ---- 播放文件：%@",path);
    
    __weak __typeof(&*cell)weakCell = cell;
    [[XZVoicePlayer shared] playWithURLString: path progress:^(CGFloat progress) {
        if (progress == 1) { // 播放完成
            Log(@"播放完成");
            weakCell.isCompletedPlay = YES;
        }
    }];
}

#pragma mark ---- 底部工具栏的代理
/// 停止录制语音
- (void)didStopRecordingVoice:(XZMediaModel *)mediaModel {
    // 发送和上传 ============
    Log(@"录制语音成功");
}

/// 点击发送按钮
- (void)didClickSendBtn:(NSString *)text {
    
}

#pragma mark ---  设置页面
- (void)setupChatView {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: self.tableChat];
    
    // 工具栏
    [self.view addSubview: self.toolBar];
    [self.toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.height.equalTo(@(XZChatToolBarHeight));
    }];
    
//    // 3分钟后新界面
//    [self.view addSubview: self.afterThreeMinutes];
    
    //  /// 关闭手势延迟
    //  self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
}

#pragma mark --- 懒加载
- (UITableView *)tableChat {
    if (!_tableChat) {
        _tableChat = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KProjectScreenWidth, KProjectScreenHeight - XZChatToolBarHeight) style:UITableViewStylePlain];
        _tableChat.delegate = self;
        _tableChat.dataSource  = self;
        _tableChat.backgroundColor = [UIColor whiteColor];
        _tableChat.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableChat.showsVerticalScrollIndicator = NO;
    }
    return _tableChat;
}

/// 底部工具栏
#pragma mark ----- 懒加载
/// 底部工具栏
- (XZChatToolBar *)toolBar {
    if (!_toolBar) {
        _toolBar = [[XZChatToolBar alloc] initWithViewController:self aboveView:self.tableChat];
        _toolBar.delegate = self;
        FMWeakSelf;
        // 键盘的更改
        _toolBar.blockKeyboardWillChange = ^(NSNotification *noti) {
            
        };
        _toolBar.blockTextViwDidChanged = ^(CGFloat height) {
            
        };
        // 点击"发送"和 "转人工"
        _toolBar.blockDidClickButton = ^(NSInteger tagIdx, NSString *text) {
            if (tagIdx == 121) { // 转人工
                Log(@"点击了 转人工");
                
                weakSelf.toolBar.transferSuccessed = YES;
            }else if (tagIdx == 123) { // 发送
                Log(@"点击了 发送: %@",text);
            }
        };
        // 点击 ”+“ 按钮视图
        _toolBar.blockClickedKeyboardInputView = ^(NSInteger tag, BOOL isRobot) {
            if (isRobot) { // 是机器人聊天
                if (tag == 2000) { // 留言
                    Log(@"点击了 留言");
                }else if (tag == 2001) { // 评论
                    Log(@"点击了 评论");
                }else if (tag == 2001) { // 留言
                    Log(@"点击了 留言");
                }else if (tag == 2002) { // 评价
                    Log(@"点击了 评价");
                }else if (tag == 2003)  { // 附件
                    Log(@"点击了 附件");
                    
                }
            }
        };
    }
    return _toolBar;
}

/// 图片处理
- (XZTakePictureTools *)pictureTool {
    if (!_pictureTool) {
        _pictureTool = [[XZTakePictureTools alloc] init];
        
        // 拍照之后的图片和图片路径获取
        _pictureTool.blockDissmiss = ^(XZMediaModel *modelMedia) {
            Log(@"图片路径========== 图片");
        };
        
    }
    return _pictureTool;
}

/// 3分钟后新界面
- (XZAfterThreeMinutesView *)afterThreeMinutes {
    if (!_afterThreeMinutes) {
        _afterThreeMinutes = [[XZAfterThreeMinutesView alloc] initWithFrame:CGRectMake(0, KProjectScreenHeight - XZChatToolBarHeight, KProjectScreenWidth, XZChatToolBarHeight)];
        _afterThreeMinutes.blockClickAfterThreeMBtn = ^(NSInteger tag) {
            if (tag == 1000) { // 1000 满意度评价
                Log(@"满意度评价");
            }else if (tag == 1001) { // 1001 新会话
                Log(@"新会话");
            }else if (tag == 1002) { // 1002 留言
                Log(@"留言");
            }
        };
    }
    return _afterThreeMinutes;
}

#pragma mark ---- 表情界面
- (void)emoticonViewController {
    XZEmoticonViewController *emoticonVc = [[XZEmoticonViewController alloc] init];
    [self.navigationController pushViewController:emoticonVc animated:YES];
}

@end
