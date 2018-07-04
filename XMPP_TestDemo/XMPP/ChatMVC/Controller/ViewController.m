//
//  ViewController.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/20.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import "ViewController.h"
#import "XZXMPPManager.h"
#import "XMPP.h"
#import "XZEmoticonViewController.h"

@interface ViewController ()<XMPPStreamDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableNotice;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[XZXMPPManager defaultManager] loginWithName:@"t6" password:@"t6"];
   

}

#pragma mark ----- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noticeCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"noticeCell"];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

#pragma mark --- 懒加载
- (UITableView *)tableNotice {
    if (!_tableNotice) {
        _tableNotice = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KProjectScreenWidth, KProjectScreenHeight - 64) style:UITableViewStylePlain];
        _tableNotice.delegate = self;
        _tableNotice.dataSource  = self;
        _tableNotice.backgroundColor = [UIColor whiteColor];
        _tableNotice.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableNotice.showsVerticalScrollIndicator = NO;
    }
    return _tableNotice;
}

#pragma mark ---- 表情界面
- (void)emoticonViewController {
    XZEmoticonViewController *emoticonVc = [[XZEmoticonViewController alloc] init];
    [self.navigationController pushViewController:emoticonVc animated:YES];
}

@end
